// Created by Alex Yaro on 2023-08-08.

import Combine
import UIKit

final class TopsifyNavigationBar: UIView {
    static let contentHeight: CGFloat = 56

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
        button.isHidden = false
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
    private var playButtonConstraints = [NSLayoutConstraint]()
    private var visibilityOffsetCancellable: AnyCancellable?
    private let viewSizeDeterminedSubject = PassthroughSubject<Void, Never>()

    convenience init(
        title: String,
        configurator: NavBarConfiguring
    ) {
        self.init(
            title: title,
            accentColor: configurator.navBarAccentColor,
            playButton: configurator.navBarPlayButton,
            visibilityManagingViewGetter: { configurator.navBarVisibilityManagingView },
            visibilityManagingViewMovedPublisher: configurator.navBarVisibilityManagingViewMovedPublisher
        )
    }

    init(
        title: String,
        accentColor: UIColor,
        playButton: PlayButton?,
        visibilityManagingViewGetter: @escaping () -> UIView?,
        visibilityManagingViewMovedPublisher: AnyPublisher<Void, Never>
    ) {
        self.playButton = playButton

        super.init(frame: .zero)

        backgroundView.backgroundColor = accentColor.mixed(withColor: .appBackground, weight: 0.3)
        titleLabel.text = title

        setUpLayout()
        setUpVisibilityReactivity(
            viewGetter: visibilityManagingViewGetter,
            viewMovedPublisher: visibilityManagingViewMovedPublisher
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        playButtonConstraints.forEach { $0.isActive = superview != nil && playButton?.superview != nil }
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
        contentView.constrainEdges(to: safeAreaLayoutGuide)
        contentView.constrainHeight(to: Self.contentHeight)

        contentView.addSubview(backButton)
        backButton.useAutoLayout()
        backButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        backButton.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true

        contentView.addSubview(titleLabel)
        titleLabel.constrainInCenter(of: contentView.layoutMarginsGuide)
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8).isActive = true

        if let playButton {
            playButtonConstraints += [
                playButton.centerYAnchor.constraint(greaterThanOrEqualTo: bottomAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playButton.leadingAnchor, constant: -8)
            ]
        }
    }

    private func setUpVisibilityReactivity(
        viewGetter: @escaping () -> UIView?,
        viewMovedPublisher: AnyPublisher<Void, Never>
    ) {
        visibilityOffsetCancellable = viewMovedPublisher
            .prepend(())
            .combineLatest(viewSizeDeterminedSubject)
            .map(\.0)
            .map(viewGetter)
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
                titleLabel.transform = .init(translationX: 0, y: titleOffset * Self.contentHeight / 4)
            }
    }

    private static func easeOutQuad(x: CGFloat) -> CGFloat {
        1 - pow(1 - x, 2)
    }
}
