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
        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(titleView, overhang: PlayerTitleView.insets),
            OverhangingView(controlsView, overhang: PlayerControlsView.insets),
            OverhangingView(subMenuView, overhang: PlayerSubMenuView.insets)
        ])
        mainStackView.axis = .vertical
        mainStackView.directionalLayoutMargins = .init(horizontal: 24, vertical: 16)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.spacing = 12
        mainStackView.setCustomSpacing(20, after: controlsView.superview ?? UIView())

        view.addSubview(mainStackView)
        mainStackView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top, withInsets: .bottom(24))
    }
}
