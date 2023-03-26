// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerViewController: UIViewController {
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
        view.addSubview(controlsView)
        controlsView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top)
    }
}
