// Created by Alex Yaro on 2023-10-29.

import Combine
import UIKit

final class ArtistViewController: BannerCollectionViewController<ArtistViewController.Section, ArtistViewController> {

    enum Section: Int, CaseIterable {
        case popularSongs
        case popularAlbums

        var title: String? {
            switch self {
            case .popularSongs:
                NSLocalizedString("Popular", comment: "Header text for list of popular songs")
            case .popularAlbums:
                NSLocalizedString("Popular releases", comment: "Header text for list of popular releases (albums)")
            }
        }
    }

    private let loadStateView = LoadStateView()
    private let playButton = PlayButton()

    private let viewModel: ArtistViewModel
    private let titleSubject = CurrentValueSubject<String?, Never>(nil)
    private let accentColorSubject = CurrentValueSubject<UIColor?, Never>(nil)
    private var bannerViewModel: ProminentBannerViewModel?
    private var popularSongs = [SongViewModel]()
    private var popularAlbums = [AlbumRowViewModel]()
    private var disposeBag = DisposeBag()

    init(viewModel: ArtistViewModel) {
        self.viewModel = viewModel

        super.init()
        delegate = self

        collectionView.registerBannerViewType(ProminentBannerView.self)
        collectionView.register(supplementaryViewType: LabelHeaderCell.self, ofKind: LabelHeaderCell.kind)
        collectionView.register(cellType: SongListCell.self)
        collectionView.register(cellType: AlbumRowCell.self)
        collectionView.registerEmptyCell()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bindViewModel()
    }

    private func setUpView() {
        view.addSubview(loadStateView)
        loadStateView.constrainEdgesToSuperview()
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            reloadRequested: loadStateView.retryButtonTapPublisher
        ))

        loadStateView.configure(loadState: outputs.loadState)
        playButton.setDynamicVisibility(basedOn: outputs.loadState)

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
            .sink { [weak self] in
                self?.bannerViewModel = $0
                self?.collectionViewLayout.reloadBanner()
            }
            .store(in: &disposeBag)

        Publishers.CombineLatest(
            outputs.popularSongs.prepend([]),
            outputs.popularAlbums.prepend([])
        )
        .throttle(for: .milliseconds(1), scheduler: DispatchQueue.main, latest: true)
        .sink { [weak self] popularSongs, popularAlbums in
            guard let self else { return }

            self.popularSongs = popularSongs.map(\.value)
            self.popularAlbums = popularAlbums.map(\.value)

            var snapshot = DataSnapshot()
            if popularSongs.isNotEmpty {
                snapshot.appendSections([.popularSongs])
                snapshot.appendItems(popularSongs.enumerated().map { index, song in AnyHashable.from(index, song.id) })
            }
            if popularAlbums.isNotEmpty {
                snapshot.appendSections([.popularAlbums])
                snapshot.appendItems(popularAlbums.map(\.id))
            }

            dataSource.apply(snapshot)
        }
        .store(in: &disposeBag)
    }
}

extension ArtistViewController: BannerCollectionViewControllerDelegate {

    func layoutSection(for section: Section, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let sectionObject: NSCollectionLayoutSection
        switch section {
        case .popularSongs:
            sectionObject = SongListCell.compositionalLayoutSection(layoutEnvironment: layoutEnvironment)
        case .popularAlbums:
            sectionObject = AlbumRowCell.compositionalLayoutSection()
        }
        sectionObject.boundarySupplementaryItems = [LabelHeaderCell.compositionalLayoutSupplementaryItem()]
        return sectionObject
    }

    func headerView(collectionView: UICollectionView, ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case BannerView.kind:
            guard let bannerViewModel else {
                return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
            }
            let banner = collectionView.dequeueBannerView(for: indexPath, type: ProminentBannerView.self)
            banner.configure(
                with: bannerViewModel,
                scrollAmountPublisher: collectionView.scrollAmountPublisher,
                topInset: view.safeAreaInsets.top - additionalSafeAreaInsets.top,
                playButton: playButton
            )
            return banner
        case LabelHeaderCell.kind:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: LabelHeaderCell.self)
            if let title = section(for: indexPath.section)?.title {
                header.configure(text: title, topPadding: 16)
            }
            return header
        default:
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
    }

    func cell(collectionView: UICollectionView, forSection section: Section, at indexPath: IndexPath) -> UICollectionViewCell {
        switch section {
        case .popularSongs:
            guard let viewModel = popularSongs[safe: indexPath.item] else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SongListCell.self)
            cell.configure(
                with: viewModel,
                delegate: nil,
                options: .init(
                    thumbnailStyle: .regular,
                    songNumberPrefix: indexPath.item + 1
                )
            )
            return cell
        case .popularAlbums:
            guard let viewModel = popularAlbums[safe: indexPath.item] else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: AlbumRowCell.self)
            cell.configure(with: viewModel)
            return cell
        }
    }
}

extension ArtistViewController: TopBarConfiguring {

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
        .controlledByBanner(in: collectionView)
    }

    var topBarButtonStyle: TopBarButtonStyle? {
        .prominent
    }

    var topBarScrollAmountPublisher: AnyPublisher<CGFloat, Never> {
        collectionView.scrollAmountPublisher
    }
}
