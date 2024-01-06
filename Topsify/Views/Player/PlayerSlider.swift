// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerSlider: UIControl {
    static let padding: CGFloat = 16
    static let dragValueChangedEvent = CustomControlEvent.playerSlider_dragValueChanged.event

    private let trackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        view.backgroundColor = .seekSliderTrack
        return view
    }()

    private let progressOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryIcon
        return view
    }()

    private let thumbView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private var activeTouch: UITouch? {
        didSet {
            if oldValue != activeTouch {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                updateThumbSize(isPressed: activeTouch != nil)
            }
        }
    }
    private var activeTouchOffsetFromThumb: CGPoint?

    private(set) var dragValuePercentage: CGFloat? {
        didSet {
            dragValuePercentage = dragValuePercentage?.clamped(to: 0...1)
            updateProgressDisplay()
            if dragValuePercentage != oldValue {
                sendActions(for: Self.dragValueChangedEvent)
            }
        }
    }

    var valuePercentage: CGFloat? {
        didSet {
            valuePercentage = valuePercentage?.clamped(to: 0...1)
            updateProgressDisplay()
            if valuePercentage != oldValue {
                sendActions(for: .valueChanged)
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.7
        }
    }

    init() {
        super.init(frame: .zero)
        setupView()
        updateThumbSize(isPressed: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func endActiveDrag() {
        activeTouch = nil
        activeTouchOffsetFromThumb = nil
        dragValuePercentage = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressDisplay()
    }

    private func setupView() {
        semanticContentAttribute = .playback

        addSubview(trackView)
        trackView.constrainEdgesToSuperview(withInsets: .init(uniform: Self.padding))

        trackView.addSubview(progressOverlayView)

        addSubview(thumbView)

        // User interaction needs to be disabled as otherwise these subviews will
        // consume touch events & we won't get the UIControl touch tracking calls below
        trackView.isUserInteractionEnabled = false
        thumbView.isUserInteractionEnabled = false
    }

    // MARK: - Touch Tracking

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard valuePercentage != nil else {
            return false
        }

        let offsetFromThumb = touch.location(in: thumbView)
        let expandedThumbRegion = thumbView.bounds.expanded(by: 16)

        if expandedThumbRegion.contains(offsetFromThumb) {
            activeTouch = touch
            activeTouchOffsetFromThumb = offsetFromThumb
            return true
        } else {
            return false
        }
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let activeTouch, let activeTouchOffsetFromThumb else { return false }

        /// Note that this is for the leading edge of the thumb, not the center.
        let targetThumbPosition = activeTouch.location(in: trackView).x - activeTouchOffsetFromThumb.x

        let thumbSize = thumbView.frame.width
        let adjustedTrackWidth = trackView.frame.width - thumbSize

        let pct = (targetThumbPosition / adjustedTrackWidth).clamped(to: 0...1)

        let lastPct = dragValuePercentage ?? valuePercentage

        // When hitting either end of the slider, emit a vibration
        if (pct == 0 || pct == 1) && pct != lastPct {
            UISelectionFeedbackGenerator().selectionChanged()
        }

        dragValuePercentage = pct
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let dragValuePercentage {
            valuePercentage = dragValuePercentage
        }
        endActiveDrag()
        sendActions(for: .valueChangedByUser)
    }

    override func cancelTracking(with event: UIEvent?) {
        endActiveDrag()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if activeTouch != nil {
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    // MARK: - Layout Helpers

    private func updateThumbSize(isPressed: Bool) {
        let size: CGFloat = isPressed ? 18 : 13
        thumbView.frame.size = .init(width: size, height: size)
        thumbView.layer.cornerRadius = size / 2
        updateProgressDisplay()
    }

    private func updateProgressDisplay() {
        let thumbSize = thumbView.frame.width
        let adjustedTrackWidth = trackView.frame.width - thumbSize

        let thumbPosition = adjustedTrackWidth * (dragValuePercentage ?? valuePercentage ?? 0)

        thumbView.isHidden = valuePercentage == nil
        progressOverlayView.isHidden = valuePercentage == nil

        thumbView.frame.origin = .init(
            x: trackView.frame.minX + thumbPosition,
            y: trackView.frame.minY + trackView.frame.height / 2 - thumbSize / 2
        )

        progressOverlayView.frame.origin = .zero
        progressOverlayView.frame.size.height = trackView.frame.height
        progressOverlayView.frame.size.width = thumbView.frame.midX - trackView.frame.minX
    }
}
