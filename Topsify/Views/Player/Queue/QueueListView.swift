// Created by Alex Yaro on 2023-07-11.

import Combine
import Reusable
import UIKit

final class QueueListView: UIView {

    enum Section: Int, CaseIterable, Hashable {
        case nowPlaying
        case nextInQueue
        case nextFromSource

        static func from(indexPath: IndexPath) -> Self? {
            Section(rawValue: indexPath.section)
        }

        var index: Int {
            rawValue
        }
    }

    /// A type of combined properties that make up a unique item in the collection view.
    private struct ItemID: Hashable {
        let id: UUID
        let isActiveItem: Bool
    }

    private typealias DataSnapshot = NSDiffableDataSourceSnapshot<Section, ItemID>

    private let collectionViewLayout = QueueListLayout()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        collectionView.backgroundColor = .clear
        collectionView.indicatorStyle = .white
        collectionView.directionalLayoutMargins = .horizontal(16)
        collectionView.isEditing = true
        collectionView.allowsSelectionDuringEditing = true
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.delegate = self

        collectionView.registerEmptyCell()
        collectionView.registerEmptySupplementaryView(ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.registerEmptySupplementaryView(ofKind: QueueListLayout.topEmptySpacerViewKind)
        collectionView.register(cellType: SongListCell.self)
        collectionView.register(supplementaryViewType: QueueListHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)

        return collectionView
    }()

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self, let content else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }

            var viewModel: SongViewModel?
            switch Section.from(indexPath: indexPath) {
            case .nowPlaying:
                viewModel = content.nowPlaying?.viewModel
            case .nextInQueue:
                viewModel = content.nextInQueue[safe: indexPath.item]?.viewModel
            case .nextFromSource:
                viewModel = content.nextFromSource[safe: indexPath.item]?.viewModel
            case .none:
                break
            }

            guard let viewModel else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }

            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SongListCell.self)
            cell.configure(
                with: viewModel,
                delegate: self,
                options: indexPath.section == Section.nowPlaying.index ? .init(thumbnailStyle: .currentlyPlaying) : .init(includeEditingAccessories: true)
            )
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indexPath in
            guard let self, let section = Section.from(indexPath: indexPath) else {
                return collectionView.dequeueEmptySupplementaryView(ofKind: elementKind, for: indexPath)
            }

            if elementKind == UICollectionView.elementKindSectionHeader {
                let headerView: QueueListHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, for: indexPath)
                headerView.configure(withText: headerText(for: section))
                return headerView
            }

            return collectionView.dequeueEmptySupplementaryView(ofKind: elementKind, for: indexPath)
        }

        dataSource.moveItemAtTo = { [weak self] from, to in
            let fromIndex = Self.vmIndex(for: from)
            let toIndex = Self.vmIndex(for: to)

            guard let fromIndex, let toIndex else {
                assertionFailure("Could not get indices for \(from) -> \(to) = \(String(describing: fromIndex)) -> \(String(describing: toIndex))")
                /// As a fail-safe, re-apply the current snapshot if we couldn't grab indices for some reason:
                dataSource.apply(dataSource.snapshot(), animatingDifferences: false)
                return
            }

            self?.movedItemSubject.send((from: fromIndex, to: toIndex))
        }

        return dataSource
    }()

    private let viewModel: QueueListViewModel
    private var content: QueueListViewModel.Content?
    private var sourceName: String?
    private let movedItemSubject = PassthroughSubject<QueueListViewModel.ItemMovement, Never>()
    private let selectionChangedSubject = PassthroughSubject<Void, Never>()
    private let tappedItemSubject = PassthroughSubject<QueueListViewModel.ItemIndex, Never>()
    private var disposeBag = DisposeBag()

    init(viewModel: QueueListViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setUpView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBottomInset(_ inset: CGFloat) {
        collectionView.contentInset.bottom = inset
        collectionView.verticalScrollIndicatorInsets.bottom = inset
    }

    private func setUpView() {
        addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            movedItem: movedItemSubject.eraseToAnyPublisher(),
            selectedItemIndices: selectionChangedSubject
                .prepend(())
                // Debounce while bulk selection/deselection occurs in the collection view's delegate:
                .debounce(for: .microseconds(1), scheduler: DispatchQueue.main)
                .map { [weak self] in
                    self?.collectionView.indexPathsForSelectedItems?.compactMap(Self.vmIndex(for:)) ?? []
                }
                .eraseToAnyPublisher(),
            tappedItem: tappedItemSubject.eraseToAnyPublisher()
        ))

        outputs.content
            .sink { [weak self] content in
                guard let self else { return }

                self.content = content

                var snapshot = DataSnapshot()
                /// All sections must always be present to ensure section indices remain stable.
                /// The custom layout object will hide the header of an empty section.
                snapshot.appendSections(Section.allCases)

                if let nowPlaying = content.nowPlaying {
                    snapshot.appendItems([ItemID(id: nowPlaying.id, isActiveItem: true)], toSection: .nowPlaying)
                }
                if !content.nextInQueue.isEmpty {
                    snapshot.appendItems(content.nextInQueue.map { ItemID(id: $0.id, isActiveItem: false) }, toSection: .nextInQueue)
                }
                if !content.nextFromSource.isEmpty {
                    snapshot.appendItems(content.nextFromSource.map { ItemID(id: $0.id, isActiveItem: false) }, toSection: .nextFromSource)
                }
                dataSource.apply(snapshot)

                /// If the data source is removing selected items, the delegate doesn't seem to get called, hense this:
                selectionChangedSubject.send()
            }
            .store(in: &disposeBag)

        outputs.sourceName
            .sink { [weak self] sourceName in
                guard let self else { return }

                self.sourceName = sourceName

                updateNextFromSourceHeaderText()
            }
            .store(in: &disposeBag)

        outputs.deselectAllItems
            .sink { [weak self] in
                guard let self else { return }
                for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
                    collectionView.deselectItem(at: indexPath, animated: false)
                }
                /// `collectionView.deselectItem` does not call the deselection delegate method, hense this:
                selectionChangedSubject.send()
            }
            .store(in: &disposeBag)
    }

    private func headerText(for section: Section) -> String {
        switch section {
        case .nowPlaying:
            return NSLocalizedString("Now Playing", comment: "Queue screen header")
        case .nextInQueue:
            return NSLocalizedString("Next in Queue", comment: "Queue screen header")
        case .nextFromSource:
            if let sourceName {
                let format = NSLocalizedString("Next From: %@", comment: "Queue screen header. The variable is the name of the album/playlist/etc the music is coming from.")
                return String(format: format, sourceName)
            } else {
                return NSLocalizedString("Next Up", comment: "Queue screen header")
            }
        }
    }

    private func updateNextFromSourceHeaderText() {
        guard
            let headerView = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: Section.nextFromSource.index)
            ) as? QueueListHeaderView
        else {
            return
        }

        headerView.configure(withText: headerText(for: .nextFromSource))
    }

    private static func vmIndex(for indexPath: IndexPath) -> QueueListViewModel.ItemIndex? {
        guard let section = Section.from(indexPath: indexPath) else {
            return nil
        }
        switch section {
        case .nowPlaying:
            return nil
        case .nextInQueue:
            return .nextInQueue(index: indexPath.item)
        case .nextFromSource:
            return .nextFromSource(index: indexPath.item)
        }
    }
}

extension QueueListView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
        atCurrentIndexPath currentIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        // Prevent moving any items to or from the "Now Playing" section (first section):
        let isMovingFromNowPlayingSection = currentIndexPath.section == Section.nowPlaying.index
        let isMovingToNowPlayingSection = proposedIndexPath.section == Section.nowPlaying.index
        if isMovingFromNowPlayingSection || isMovingToNowPlayingSection {
            return currentIndexPath
        }
        return proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return indexPath.section > Section.nowPlaying.index
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section > Section.nowPlaying.index
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionChangedSubject.send()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectionChangedSubject.send()
    }
}

extension QueueListView: SongListCellDelegate {

    func songListCellTapped(_ cell: SongListCell) {
        guard
            let indexPath = collectionView.indexPath(for: cell),
            let index = Self.vmIndex(for: indexPath)
        else { return }
        tappedItemSubject.send(index)
    }
}

private extension QueueListView {

    /// Subclass of the diffable data source, with easy access to `collectionView(_:moveItemAt:to:)`
    /// to avoid juggling with the convoluted `reorderingHandlers`.
    private final class DataSource: UICollectionViewDiffableDataSource<Section, ItemID> {
        var moveItemAtTo: (_ from: IndexPath, _ to: IndexPath) -> Void = { _, _ in }

        override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            super.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)

            /// This callback **must** be called *after* super call, or buggy behaviour and possible crashes will ensue!
            /// Presumably, if data source is updated as a result of this callback & before it can process the movement, things go haywire.
            moveItemAtTo(sourceIndexPath, destinationIndexPath)
        }
    }
}
