// Created by Alex Yaro on 2023-08-06.

import Combine
import UIKit

final class AlbumViewController: UIViewController {

    enum Section: Int, Hashable, CaseIterable {
        case songs
        case releaseInfo
        case artists
        // TODO: case recommended
        case legal
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias DataSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>

    private let loadStateView = LoadStateView()

    private let collectionViewLayout: BannerLayout = {
        return BannerLayout { sectionIndex, layoutEnvironment in
            guard let section = Section(rawValue: sectionIndex) else {
                return nil
            }
            switch section {
            case .songs:
                return .songs(layoutEnvironment: layoutEnvironment)
            case .releaseInfo:
                return nil
            case .artists:
                return nil
            case .legal:
                return nil
            }
        }
    }()

    private lazy var collectionView: LayoutCallbackCollectionView = {
        let collectionView = LayoutCallbackCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.indicatorStyle = .white

        collectionView.registerBannerViewType(ArtworkBannerView.self)
        collectionView.register(cellType: SongListCell.self)
        collectionView.registerEmptyCell()

        return collectionView
    }()

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self, let section = Section(rawValue: indexPath.section) else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            switch section {
            case .songs:
                guard let viewModel = songListViewModels[safe: indexPath.item] else {
                    return collectionView.dequeueEmptyCell(for: indexPath)
                }
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SongListCell.self)
                cell.configure(with: viewModel, delegate: nil)
                return cell
            case .releaseInfo:
                return nil
            case .artists:
                return nil
            case .legal:
                return nil
            }
        }
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else {
                return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
            }
            switch kind {
            case ArtworkBannerView.kind:
                let view = collectionView.dequeueBannerView(for: indexPath, type: ArtworkBannerView.self)
                configureBanner(view)
                return view
            default:
                return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
            }
        }

        return dataSource
    }()

    private let playButton = PlayButton()

    private let titleSubject = CurrentValueSubject<String?, Never>(nil)
    private let accentColorSubject = CurrentValueSubject<UIColor?, Never>(nil)

    private let viewModel: AlbumViewModel
    private var bannerViewModel: ArtworkBannerViewModel?
    private var songListViewModels = [SongListCellViewModel]()
    private var disposeBag = DisposeBag()

    init(viewModel: AlbumViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpInitialDataSourceSnapshot()
        bindViewModel()
    }

    private func setUpView() {
        view.backgroundColor = .appBackground

        view.addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()

        view.addSubview(loadStateView)
        loadStateView.constrainEdgesToSuperview()
    }

    private func setUpInitialDataSourceSnapshot() {
        // The initial snapshot contains all the sections, but they are empty. Once the VM
        // returns items pertaining to a given section, the current snapshot is updated accordingly.
        var snapshot = DataSnapshot()
        snapshot.appendSections([.songs])
        dataSource.apply(snapshot)
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            reloadRequested: loadStateView.retryButtonTapPublisher
        ))

        UIView.performWithoutAnimation {
            outputs.loadState
                .map(\.isLoaded)
                .sink { [weak self] isLoaded in
                    guard let self else { return }
                    if isLoaded {
                        playButton.fadeIn()
                    } else {
                        playButton.fadeOut()
                    }
                }
                .store(in: &disposeBag)
        }

        loadStateView.configure(loadState: outputs.loadState)

        outputs.title
            .mapOptional()
            .subscribe(titleSubject)
            .store(in: &disposeBag)

        outputs.accentColor
            .map(\.uiColor)
            .mapOptional()
            .subscribe(accentColorSubject)
            .store(in: &disposeBag)

        outputs.bannerViewModel
            .sink { [weak self] bannerViewModel in
                guard let self else { return }
                self.bannerViewModel = bannerViewModel
                if let bannerView = collectionView.bannerView(type: ArtworkBannerView.self) {
                    configureBanner(bannerView)
                }
                collectionViewLayout.reloadBannerSize()
            }
            .store(in: &disposeBag)

        outputs.songListViewModels
            .sink { [weak self] songListViewModels in
                guard let self else { return }
                self.songListViewModels = songListViewModels

                var snapshot = dataSource.snapshot()
                snapshot.reloadIDIndependentSection(.songs, itemCount: songListViewModels.count)
                dataSource.apply(snapshot)
            }
            .store(in: &disposeBag)
    }

    private func configureBanner(_ bannerView: ArtworkBannerView) {
        guard let bannerViewModel else { return }
        bannerView.configure(
            with: bannerViewModel,
            scrollAmountPublisher: collectionView.scrollAmountPublisher,
            topInset: view.safeAreaInsets.top - additionalSafeAreaInsets.top,
            playButton: playButton
        )
    }
}

extension AlbumViewController: TopBarConfiguring {

    var topBarTitlePublisher: AnyPublisher<String?, Never> {
        titleSubject.eraseToAnyPublisher()
    }

    var topBarAccentColorPublisher: AnyPublisher<UIColor?, Never> {
        accentColorSubject.eraseToAnyPublisher()
    }

    var topBarPlayButton: PlayButton? {
        playButton
    }

    var topBarVisibility: TopBarVisibility {
        .controlledByBannerInCollectionView(collectionView, bannerType: ArtworkBannerView.self)
    }
}

private extension NSCollectionLayoutSection {

    static func songs(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = .clear
        return .list(using: config, layoutEnvironment: layoutEnvironment)
    }
}
