// Created by Alex Yaro on 2023-08-08.

import Combine
import UIKit

final class TopBar: UIView {
    static let safeAreaHeight: CGFloat = 56

    // MARK: Subviews

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

    // MARK: Public Properties

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var accentColor: UIColor = .clear {
        didSet {
            backgroundView.backgroundColor = accentColor.mixed(withColor: .appBackground, weight: 0.3)
        }
    }

    // MARK: Private State

    private let playButton: PlayButton?
    private var playButtonConstrainsApplied = false
    private var visibilityOffsetCancellable: AnyCancellable?
    private let viewSizeDeterminedSubject = PassthroughSubject<Void, Never>()

    // MARK: Init

    /// - Parameters:
    ///   - playButton: The play button active alongside this top bar. Constraints will be added to position the play button.
    ///   - visibilityManagingViewPublisher:
    ///     If this publisher emits a view, the nav bar visibility will be controlled by the position of that view.
    ///     - If the view is below the nav bar, the nav bar is transparent.
    ///     - If the view is at or above the nav bar, the nav bar is opaque.
    ///     - As the view transitions from below to above the nav bar, the nav bar smoothly fades in/out.
    ///
    ///     The visibility of the nav bar based on the position of the view is updated whenever this publisher emits.
    init(
        playButton: PlayButton?,
        visibilityManagingViewPublisher: some Publisher<UIView?, Never>
    ) {
        self.playButton = playButton

        super.init(frame: .zero)

        setUpLayout()
        setUpVisibilityReactivity(
            viewPublisher: visibilityManagingViewPublisher.eraseToAnyPublisher()
        )
    }

    static func createForBannerCollectionView<BannerType: BannerView & TopBarVisibilityManagingViewProviding>(
        _ collectionView: LayoutCallbackCollectionView,
        bannerType: BannerType.Type,
        playButton: PlayButton?
    ) -> TopBar {
        let visibilityManagingViewPublisher = Publishers.Merge(
            collectionView.didLayoutSubviewsPublisher.prefix(1),
            collectionView.didScrollPublisher
        ).map { () -> UIView? in
            guard let banner = collectionView.bannerView(type: bannerType) else { return nil }

            /// The view returned should always have an accurate frame (have been laid out before).
            /// UIKit doesn't seem to layout supplementary views as part of the UICollectionView's `layoutSubviews`
            /// invocation (despite setting the view's frame), so we perform a manual layout here if necessary.
            banner.layoutIfNeeded()

            return banner.topBarVisibilityManagingView
        }

        return TopBar(
            playButton: playButton,
            visibilityManagingViewPublisher: visibilityManagingViewPublisher
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

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

    // MARK: Public Functions

    func constrainToSuperview() {
        constrainEdgesToSuperview(excluding: .bottom)
    }

    // MARK: Private Functions

    private func setUpLayout() {
        addSubview(backgroundView)
        backgroundView.constrainEdgesToSuperview()

        addSubview(contentView)
        contentView.constrainEdges(to: safeAreaLayoutGuide)
        contentView.constrainHeight(to: Self.safeAreaHeight)

        contentView.addSubview(backButton)
        backButton.useAutoLayout()
        backButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        backButton.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true

        contentView.addSubview(titleLabel)
        titleLabel.constrainInCenter(of: contentView.layoutMarginsGuide)
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8).isActive = true
    }

    private func setUpVisibilityReactivity(
        viewPublisher: AnyPublisher<UIView?, Never>
    ) {
        visibilityOffsetCancellable = viewPublisher
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
    }

    private static func easeOutQuad(x: CGFloat) -> CGFloat {
        1 - pow(1 - x, 2)
    }
}
