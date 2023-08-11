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

    private lazy var collectionView: CollectionWithLayoutCallback = {
        let collectionView = CollectionWithLayoutCallback(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.indicatorStyle = .white

        collectionView.registerBannerViewType(ArtworkBannerView.self)
        collectionView.register(cellType: SongListCell.self)
        collectionView.registerEmptyCell()

        return collectionView
    }()

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let section = Section(rawValue: indexPath.section) else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            switch section {
            case .songs:
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SongListCell.self)
                cell.configure(with: .init(song: FakeSongs.selfish), delegate: nil)
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
                let view = collectionView.dequeueBannerView(type: ArtworkBannerView.self)
                view.configure(
                    scrollAmountPublisher: collectionView.scrollAmountPublisher,
                    topInset: collectionView.safeAreaInsets.top,
                    playButton: playButton
                )
                return view
            default:
                return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
            }
        }

        return dataSource
    }()

    private let playButton = PlayButton()

    init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()

        // TODO: remove temp:
        var snapshot = DataSnapshot()
        snapshot.appendSections([.songs])
        snapshot.appendItems(Array(0..<20), toSection: .songs)
        dataSource.apply(snapshot)
        title = FakeAlbums.catchTheseVibes.title
    }

    private func setUpView() {
        view.backgroundColor = .appBackground

        view.addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()
    }
}

extension AlbumViewController: NavBarConfiguring {

    var navBarAccentColor: UIColor {
        .init(hexString: FakeAlbums.catchTheseVibes.accentColorHex)
    }

    var navBarPlayButton: PlayButton? {
        playButton
    }

    var navBarVisibilityManagingView: UIView? {
        bannerView?.viewManagingNavBarVisibility
    }

    var navBarVisibilityManagingViewMovedPublisher: AnyPublisher<Void, Never> {
        Publishers.Merge(
            collectionView.didLayoutSubviewsPublisher.prefix(1),
            collectionView.didScrollPublisher
        )
        .handleEvents(receiveOutput: { [weak self] in
            /// UIKit doesn't seem to layout the supplementary view as part of the UICollectionView's `layoutSubviews`
            /// (despite setting its frame), so we perform a manual layout here if necessary.
            self?.bannerView?.layoutIfNeeded()
        })
        .eraseToAnyPublisher()
    }

    private var bannerView: ArtworkBannerView? {
        collectionView.bannerView(type: ArtworkBannerView.self)
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
