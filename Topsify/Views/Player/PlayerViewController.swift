// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerViewController: UIViewController {
    private let titleView = PlayerTitleView()
    private let controlsView = PlayerControlsView()

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
            titleView,
            OverhangingView(controlsView, horizontalOverhang: PlayerControlsView.inset)
        ])
        mainStackView.axis = .vertical
        mainStackView.directionalLayoutMargins = .init(horizontal: 24, vertical: 0)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.setCustomSpacing(16, after: titleView)

        view.addSubview(mainStackView)
        mainStackView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top)
    }
}
