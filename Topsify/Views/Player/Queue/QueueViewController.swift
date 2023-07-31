// Created by Alex Yaro on 2023-07-10.

import UIKit

final class QueueViewController: UIViewController {

    private let topBar = PlayerTopBarView(
        viewModel: .init(dependencies: .live()),
        dismissButtonIcon: "Icons/x",
        showOptionsButton: false
    )

    private let queueListView: QueueListView
    private let selectionMenuView: QueueSelectionMenuView

    private let controlsBackgroundView = CubicGradientView(color: .appBackground)

    private let controlsView = PlayerControlsView(
        // TODO: inject elsewhere
        viewModel: .init(dependencies: .init(playbackQueue: Environment.current.playbackQueue))
    )

    private let viewModel: QueueViewModel
    private var disposeBag = DisposeBag()

    init(viewModel: QueueViewModel) {
        self.viewModel = viewModel

        queueListView = .init(viewModel: viewModel.listViewModel)
        selectionMenuView = .init(viewModel: viewModel.selectionMenuViewModel)

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        queueListView.setBottomInset(controlsView.bounds.height)
    }

    private func setUpView() {
        view.backgroundColor = .appBackground

        view.addSubview(topBar)
        topBar.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .bottom)

        view.addSubview(queueListView)
        queueListView.constrainEdgesToSuperview(excluding: .top)
        queueListView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true

        view.addSubview(controlsView)
        controlsView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top)

        view.insertSubview(controlsBackgroundView, belowSubview: controlsView)
        controlsBackgroundView.constrainEdgesToSuperview(excluding: .top)
        controlsBackgroundView.topAnchor.constraint(equalTo: controlsView.topAnchor, constant: -80).isActive = true

        view.addSubview(selectionMenuView)
        selectionMenuView.constrainEdgesToSuperview(excluding: .top)

    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init())

        let selectionMenuTransitionDuration: CGFloat = 0.1

        outputs.showPlaybackControls
            .sink { [weak self] showPlaybackControls in
                guard let self else { return }
                if showPlaybackControls {
                    controlsView.fadeIn(withDuration: selectionMenuTransitionDuration)
                } else {
                    controlsView.fadeOut(withDuration: selectionMenuTransitionDuration)
                }
            }
            .store(in: &disposeBag)

        outputs.showSelectionMenu
            .sink { [weak self] showSelectionMenu in
                if showSelectionMenu {
                    self?.selectionMenuView.fadeIn(withDuration: selectionMenuTransitionDuration)
                } else {
                    self?.selectionMenuView.fadeOut(withDuration: selectionMenuTransitionDuration)
                }
            }
            .store(in: &disposeBag)
    }
}
