// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerViewController: UIViewController {
    private let titleView = PlayerTitleView()
    private let controlsView = PlayerControlsView()
    private let subMenuView = PlayerSubMenuView()

    init() {
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
        let wrappedControlsView = OverhangingView(controlsView, overhang: PlayerControlsView.insets)
        let wrappedSubMenuView = OverhangingView(subMenuView, horizontalOverhang: PlayerSubMenuView.horizontalInset)

        let mainStackView = UIStackView(arrangedSubviews: [
            titleView,
            wrappedControlsView,
            wrappedSubMenuView
        ])
        mainStackView.axis = .vertical
        mainStackView.directionalLayoutMargins = .init(horizontal: 24, vertical: 0)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.spacing = 16
        mainStackView.setCustomSpacing(18, after: wrappedControlsView)

        view.addSubview(mainStackView)
        mainStackView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top)
    }
}
