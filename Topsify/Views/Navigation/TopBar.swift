// Created by Alex Yaro on 2023-08-08.

import Combine
import UIKit

final class TopBar: UIView {
    static let safeAreaHeight: CGFloat = 56

    private lazy var backgroundView: UIView = {
        let view = UIView()
        let gradientView = GradientFadeView(color: .appBackground.withAlphaComponent(0.4), direction: .up, easing: .linear)
        view.addSubview(gradientView)
        gradientView.constrainEdgesToSuperview()
        return view
    }()

    private let backButton: AppIconButton = {
        let button = AppIconButton(icon: "Icons/chevronLeft", scale: 0.8, expandedTouchBoundary: .init(uniform: 12))
        // TODO: have navigation controller manage visibility:
        button.isHidden = false // true
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.directionalLayoutMargins = .horizontal(16)
        view.clipsToBounds = true
        return view
    }()

    private let playButton: PlayButton?
    private var playButtonConstrainsApplied = false
    private var visibilityOffsetCancellable: AnyCancellable?
    private let viewSizeDeterminedSubject = PassthroughSubject<Void, Never>()
    private var disposeBag = DisposeBag()

    init(configurator: TopBarConfiguring) {
        self.playButton = configurator.topBarPlayButton

        super.init(frame: .zero)

        setUpLayout()
        bindState(configurator: configurator)
        setUpVisibilityReactivity(visibility: configurator.topBarVisibility)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if let playButton, !playButtonConstrainsApplied {
            playButton.useAutoLayout()
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            playButton.centerYAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -8).isActive = true
            playButtonConstrainsApplied = true
        }
        super.updateConstraints()
    }

    override func layoutSubviews() {
        contentView.directionalLayoutMargins.bottom = safeAreaInsets.top > 0 ? 6 : 0
        super.layoutSubviews()
        viewSizeDeterminedSubject.send()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if backgroundView.alpha == 0 {
            if result == self || result == contentView {
                return nil
            }
        }
        return result
    }

    private func setUpLayout() {
        addSubview(backgroundView)
        backgroundView.constrainEdgesToSuperview()

        addSubview(contentView)
        contentView.constrainEdgesToSuperview(excluding: .top)
        contentView.constrainHeight(to: Self.safeAreaHeight)
        contentView.insetsLayoutMarginsFromSafeArea = false
        contentView.topAnchor.constraint(equalTo: topAnchor).priority(.justLessThanRequired).isActive = true

        contentView.addSubview(backButton)
        backButton.useAutoLayout()
        backButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        backButton.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true

        contentView.addSubview(titleLabel)
        titleLabel.constrainInCenter(of: contentView.layoutMarginsGuide)
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8).isActive = true
    }

    private func bindState(configurator: TopBarConfiguring) {
        configurator.topBarTitlePublisher
            .assign(to: \.text, on: titleLabel)
            .store(in: &disposeBag)

        configurator.topBarAccentColorPublisher
            .assign(to: \.backgroundColor, on: backgroundView)
            .store(in: &disposeBag)
    }

    private func setUpVisibilityReactivity(visibility: TopBarVisibility) {
        visibility.viewPublisher
            .prepend(nil)
            .combineLatest(viewSizeDeterminedSubject)
            .map(\.0)
            .map { [weak self] visibilityManagingView in
                guard let self, let visibilityManagingView else {
                    return CGFloat.greatestFiniteMagnitude
                }
                let viewMidYPositionInLocalCoordinateSpace = visibilityManagingView.convert(
                    CGPoint(x: 0, y: visibilityManagingView.frame.midY),
                    to: self
                ).y
                return -(viewMidYPositionInLocalCoordinateSpace - self.frame.height)
            }
            .removeDuplicates()
            .sink { [weak self] visibilityValue in
                guard let self else { return }

                let backgroundOpacity = visibilityValue.pctInRange(-50...0)
                backgroundView.alpha = backgroundOpacity

                let titleOpacity = visibilityValue.pctInRange(0...80)
                titleLabel.alpha = titleOpacity

                let titleOffset = 1 - Self.easeOutQuad(x: titleOpacity)
                titleLabel.transform = .init(translationX: 0, y: titleOffset * Self.safeAreaHeight / 4)
            }
            .store(in: &disposeBag)
    }

    private static func easeOutQuad(x: CGFloat) -> CGFloat {
        1 - pow(1 - x, 2)
    }
}

private extension TopBarVisibility {

    var viewPublisher: AnyPublisher<UIView?, Never> {
        switch self {
        case .alwaysVisible:
            return .just(nil)
        case .controlledByView(let viewPublisher):
            return viewPublisher
        }
    }
}
