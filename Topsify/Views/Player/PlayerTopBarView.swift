// Created by Alex Yaro on 2023-07-06.

import Combine
import UIKit

final class PlayerTopBarView: UIView {

    private let dismissButton: AppIconButton

    private let optionsButton = createSideButton(icon: "Icons/options")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 13, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var titleLabelMarquee = MarqueeView(titleLabel)

    var dismissButtonTapPublisher: AnyPublisher<Void, Never> {
        dismissButton.tapPublisher
    }
    var optionsButtonTapPublisher: AnyPublisher<Void, Never> {
        optionsButton.tapPublisher
    }

    private let viewModel: PlayerTopBarViewModel
    private var disposeBag = DisposeBag()

    init(
        viewModel: PlayerTopBarViewModel,
        dismissButtonIcon: String,
        showOptionsButton: Bool
    ) {
        self.viewModel = viewModel

        dismissButton = Self.createSideButton(icon: dismissButtonIcon)
        if !showOptionsButton {
            optionsButton.isHidden = true
        }

        super.init(frame: .zero)

        setUpView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        useAutoLayout()
        heightAnchor.constraint(equalToConstant: 55).isActive = true

        directionalLayoutMargins = .init(horizontal: 4, vertical: 0)

        addSubview(dismissButton)
        dismissButton.constrainEdges(to: layoutMarginsGuide, excluding: .trailing)

        addSubview(optionsButton)
        optionsButton.constrainEdges(to: layoutMarginsGuide, excluding: .leading)

        addSubview(titleLabelMarquee)
        titleLabelMarquee.constrainInCenterOfSuperview()
        titleLabelMarquee.widthAnchor.constraint(equalTo: widthAnchor).priority(.justLessThanRequired).isActive = true
        titleLabelMarquee.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        titleLabelMarquee.leadingAnchor.constraint(greaterThanOrEqualTo: dismissButton.trailingAnchor).isActive = true
        titleLabelMarquee.trailingAnchor.constraint(lessThanOrEqualTo: optionsButton.leadingAnchor).isActive = true
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: ())

        outputs.title
            .sink { [weak self] in
                guard let self else { return }
                titleLabel.text = $0
                titleLabelMarquee.reset()
            }
            .store(in: &disposeBag)
    }

    static private func createSideButton(icon: String) -> AppIconButton {
        let button = AppIconButton(icon: icon, expandedTouchBoundary: .zero)
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        return button
    }
}
