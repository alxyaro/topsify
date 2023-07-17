// Created by Alex Yaro on 2023-07-11.

import Reusable
import UIKit

final class QueueListView: UIView {

    private typealias DataSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>

    private enum Section: Hashable {
        case nowPlaying
        case nextInQueue
        case nextFromSource

        static func from(indexPath: IndexPath, for snapshot: DataSnapshot) -> Self? {
            snapshot.sectionIdentifiers[safe: indexPath.section]
        }

        func index(for snapshot: DataSnapshot) -> Int? {
            guard let sectionIndex = snapshot.sectionIdentifiers.firstIndex(of: self) else {
                return nil
            }
            return sectionIndex
        }
    }

    private let collectionViewLayout = QueueListLayout()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        collectionView.backgroundColor = .clear
        collectionView.isEditing = true
        collectionView.delegate = self

        collectionView.registerEmptyCell()
        collectionView.registerEmptySupplementaryView(ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.register(cellType: SongListCell.self)
        collectionView.register(supplementaryViewType: QueueListHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)

        collectionView.contentInset.bottom = 60

        return collectionView
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self, let content else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }

            var viewModel: SongListCellViewModel?
            switch Section.from(indexPath: indexPath, for: self.dataSource.snapshot()) {
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
            cell.configure(with: viewModel)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indexPath in
            guard let self, let section = Section.from(indexPath: indexPath, for: self.dataSource.snapshot()) else {
                return collectionView.dequeueEmptySupplementaryView(ofKind: elementKind, for: indexPath)
            }

            if elementKind == UICollectionView.elementKindSectionHeader {
                let headerView: QueueListHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, for: indexPath)
                headerView.configure(withText: headerText(for: section))
                return headerView
            }

            return collectionView.dequeueEmptySupplementaryView(ofKind: elementKind, for: indexPath)
        }

        dataSource.reorderingHandlers.canReorderItem = { _ in true }

        return dataSource
    }()

    private let viewModel: QueueListViewModel
    private var content: QueueListViewModel.Content?
    private var sourceName: String?
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

    private func setUpView() {
        addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init())

        outputs.content
            .sink { [weak self] content in
                guard let self else { return }

                self.content = content

                var snapshot = DataSnapshot()
                if let nowPlaying = content.nowPlaying {
                    snapshot.appendSections([.nowPlaying])
                    snapshot.appendItems([nowPlaying.id])
                }
                /// The "Next in Queue" section is always present, so as to allow users to interactively move items into it.
                /// The custom layout object itself hides the header of the section if there are no items in it.
                snapshot.appendSections([.nextInQueue])
                if !content.nextInQueue.isEmpty {
                    snapshot.appendItems(content.nextInQueue.map(\.id))
                }
                if !content.nextFromSource.isEmpty {
                    snapshot.appendSections([.nextFromSource])
                    snapshot.appendItems(content.nextFromSource.map(\.id))
                }
                dataSource.apply(snapshot)
            }
            .store(in: &disposeBag)

        outputs.sourceName
            .sink { [weak self] sourceName in
                guard let self else { return }

                self.sourceName = sourceName

                updateNextFromSourceHeaderText()
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
            let nextFromSourceSectionIndex = Section.nextFromSource.index(for: dataSource.snapshot()),
            let headerView = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: nextFromSourceSectionIndex)
            ) as? QueueListHeaderView
        else {
            return
        }

        headerView.configure(withText: headerText(for: .nextFromSource))
    }
}

extension QueueListView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
        atCurrentIndexPath currentIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        // Prevent moving any items to the "Now Playing" section (first section):
        if proposedIndexPath.section == Section.nowPlaying.index(for: dataSource.snapshot()) {
            return currentIndexPath
        }
        return proposedIndexPath
    }

}
