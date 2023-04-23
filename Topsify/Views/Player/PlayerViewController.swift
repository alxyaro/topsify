// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerViewController: UIViewController {

    private lazy var stageView = PlayerStageView(
        viewModel: viewModel.stageViewModel,
        contentAreaLayoutGuide: stageContentAreaLayoutGuide
    )

    private lazy var titleView = PlayerTitleView(
        viewModel: viewModel.titleViewModel
    )
    private lazy var controlsView = PlayerControlsView(
        viewModel: viewModel.controlsViewModel
    )
    private let subMenuView = PlayerSubMenuView()

    private let stageContentAreaLayoutGuide = UILayoutGuide()

    private let viewModel: PlayerViewModel

    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
    }

    private func setupView() {
        view.addSubview(stageView)
        stageView.constrainEdgesToSuperview()

        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(titleView, overhang: PlayerTitleView.insets),
            OverhangingView(controlsView, overhang: PlayerControlsView.insets),
            OverhangingView(subMenuView, overhang: PlayerSubMenuView.insets)
        ])
        mainStackView.axis = .vertical
        mainStackView.directionalLayoutMargins = .init(horizontal: 24, vertical: 16)
        mainStackView.directionalLayoutMargins.top = 0 // to improve stage swiping
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.spacing = 12
        mainStackView.setCustomSpacing(20, after: controlsView.superview ?? UIView())

        view.addSubview(mainStackView)
        mainStackView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top, withInsets: .bottom(24))

        stageView.addLayoutGuide(stageContentAreaLayoutGuide)
        stageContentAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stageContentAreaLayoutGuide.bottomAnchor.constraint(equalTo: mainStackView.topAnchor, constant: mainStackView.directionalLayoutMargins.top).isActive = true
        stageContentAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stageContentAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
