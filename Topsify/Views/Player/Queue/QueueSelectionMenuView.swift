// Created by Alex Yaro on 2023-07-21.

import UIKit

final class QueueSelectionMenuView: UIView {
    private let removeButton = createButton(text: NSLocalizedString("REMOVE", comment: "Button text for queue list selection menu."))
    private let moveToQueueButton = createButton(text: NSLocalizedString("MOVE TO QUEUE", comment: "Button text for queue list selection menu."))

    private let viewModel: QueueSelectionMenuViewModel
    private var disposeBag = DisposeBag()

    init(viewModel: QueueSelectionMenuViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setUpView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        backgroundColor = .init(named: "Player/Queue/SelectionMenuBackgroundColor")

        let mainStackView = UIStackView(arrangedSubviews: [removeButton, SpacerView(), moveToQueueButton])
        mainStackView.axis = .horizontal

        addSubview(mainStackView)
        mainStackView.constrainEdges(to: safeAreaLayoutGuide)
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            tappedRemoveButton: removeButton.tapPublisher,
            tappedMoveToQueueButton: moveToQueueButton.tapPublisher
        ))

        outputs.showMoveToQueueButton
            .sink { [weak self] showMoveToQueueButton in
                guard let self else { return }
                if showMoveToQueueButton {
                    moveToQueueButton.fadeIn(withDuration: 0.1)
                } else {
                    moveToQueueButton.fadeOut(withDuration: 0.1)
                }
            }
            .store(in: &disposeBag)
    }

    private static func createButton(text: String) -> AppButton {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        label.text = text

        let button = AppButton()
        button.contentView.addSubview(label)
        label.constrainInCenterOfSuperview()
        label.constrainEdgesToSuperview(excluding: .vertical, withInsets: .horizontal(16))
        button.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: 32).isActive = true

        return button
    }
}
