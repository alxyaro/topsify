// Created by Alex Yaro on 2023-02-26.

import Combine
import UIKit

final class LoadStateView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .appTextSecondary
        indicator.hidesWhenStopped = false
        return indicator
    }()

    private let errorIconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Icons/caution")
        view.tintColor = .primaryIcon
        view.constrainDimensions(uniform: 80)
        return view
    }()

    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 0
        label.text = NSLocalizedString("Something went wrong", comment: "Generic error message title")
        label.requireIntrinsicHeight()
        return label
    }()

    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 16)
        label.textColor = .appTextSecondary
        label.numberOfLines = 0
        label.requireIntrinsicHeight()
        return label
    }()

    private let retryButton = AppTextButton(
        title: NSLocalizedString("Retry", comment: "Button text"),
        style: .primaryOutlined
    )

    private lazy var errorStackView: UIStackView = {
        let spacerView = SpacerView()
        spacerView.useAutoLayout()
        spacerView.heightAnchor.constraint(equalToConstant: 50).priority(.justLessThanRequired).isActive = true
        spacerView.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true

        let stackView = UIStackView(arrangedSubviews: [
            errorIconView,
            errorTitleLabel,
            errorMessageLabel,
            retryButton,
            spacerView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.setCustomSpacing(16, after: errorIconView)
        stackView.setCustomSpacing(24, after: errorMessageLabel)
        stackView.alignment = .center
        return stackView
    }()

    var retryButtonTapPublisher: AnyPublisher<Void, Never> {
        retryButton.tapPublisher
    }

    private var disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        backgroundColor = .appBackground

        addSubview(activityIndicator)
        activityIndicator.constrainInCenterOfSuperview()

        addSubview(errorStackView)
        errorStackView.constrainEdges(to: safeAreaLayoutGuide, excluding: .vertical, withInsets: .horizontal(24))
        errorStackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        errorStackView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(loadState: some Publisher<LoadState<some UserFacingError>, Never>) {
        disposeBag = DisposeBag()

        UIView.performWithoutAnimation {
            loadState
                .map(\.isLoading)
                .removeDuplicates()
                .sink { [weak self] isLoading in
                    guard let self else { return }
                    if isLoading {
                        activityIndicator.startAnimating()
                        activityIndicator.fadeIn()
                    } else {
                        activityIndicator.fadeOut() { [activityIndicator] completed in
                            if completed {
                                activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
                .store(in: &disposeBag)

            loadState
                .map(\.isLoaded)
                .removeDuplicates()
                .sink { [weak self] isLoaded in
                    if isLoaded {
                        self?.fadeOut()
                    } else {
                        self?.fadeIn()
                    }
                }
                .store(in: &disposeBag)

            loadState
                .map(\.error)
                .removeDuplicates()
                .sink { [weak self] error in
                    guard let self else { return }
                    if let error {
                        errorMessageLabel.text = error.message
                        errorStackView.fadeIn()
                    } else {
                        errorStackView.fadeOut()
                    }
                }
                .store(in: &disposeBag)
        }
    }
}
