// Created by Alex Yaro on 2023-07-10.

import UIKit

final class QueueViewController: UIViewController {

    private let topBar = PlayerTopBarView(
        viewModel: .init(dependencies: .live()),
        dismissButtonIcon: "Icons/x",
        showOptionsButton: false
    )

    private let queueListView = QueueListView(
        // TODO: inject elsewhere
        viewModel: .init(dependencies: .live())
    )

    private let controlsBackgroundView = CubicGradientView(color: .appBackground)

    private let controlsView = PlayerControlsView(
        // TODO: inject elsewhere
        viewModel: .init(dependencies: .init(playbackQueue: Environment.current.playbackQueue))
    )

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
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
    }
}
