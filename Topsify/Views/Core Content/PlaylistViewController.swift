// Created by Alex Yaro on 2023-10-02.

import Combine
import UIKit

final class PlaylistViewController: BannerCollectionViewController<PlaylistViewController.Section, PlaylistViewController> {

    enum Section: Int {
        case songs
        case youMightAlsoLike
    }

    private let loadStateView = LoadStateView()
    private let playButton = PlayButton()

    private let viewModel: PlaylistViewModel
    private let titleSubject = CurrentValueSubject<String?, Never>(nil)
    private let accentColorSubject = CurrentValueSubject<UIColor?, Never>(nil)
    private var bannerViewModel: ArtworkBannerViewModel?
    private var songListViewModels = [SongListCellViewModel]()
    private var disposeBag = DisposeBag()

    init(viewModel: PlaylistViewModel) {
        self.viewModel = viewModel

        super.init()
        delegate = self

        collectionView.registerBannerViewType(ArtworkBannerView.self)
        collectionView.register(cellType: SongListCell.self)
        collectionView.registerEmptySupplementaryView(ofKind: ArtworkBannerView.kind)
        collectionView.registerEmptyCell()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpInitialDataSourceSnapshot()
        bindViewModel()
    }

    private func setUpView() {
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

extension PlaylistViewController: BannerCollectionViewControllerDelegate {

    func layoutSection(for section: Section, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        switch section {
        case .songs:
            return SongListCell.compositionalLayoutSection(layoutEnvironment: layoutEnvironment)
        case .youMightAlsoLike:
            return nil
        }
    }

    func headerView(collectionView: UICollectionView, ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case ArtworkBannerView.kind:
            let view = collectionView.dequeueBannerView(for: indexPath, type: ArtworkBannerView.self)
            configureBanner(view)
            return view
        default:
            return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
        }
    }

    func cell(collectionView: UICollectionView, forSection section: Section, at indexPath: IndexPath) -> UICollectionViewCell {
        switch section {
        case .songs:
            guard let viewModel = songListViewModels[safe: indexPath.item] else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: SongListCell.self)
            cell.configure(with: viewModel, delegate: nil)
            return cell
        case .youMightAlsoLike:
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
    }
}

extension PlaylistViewController: TopBarConfiguring {

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
