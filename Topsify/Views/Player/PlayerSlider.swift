// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerSlider: UIControl {
    static let inset: CGFloat = 15

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

    var progressPercent: CGFloat = 0.5 {
        didSet {
            if progressPercent < 0 {
                progressPercent = 0
            }
            if progressPercent > 1 {
                progressPercent = 1
            }
            updateProgressDisplay()
            sendActions(for: .valueChanged)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressDisplay()
    }

    private func setupView() {
        semanticContentAttribute = .playback

        addSubview(trackView)
        trackView.constrainEdgesToSuperview(withInsets: .init(uniform: Self.inset))

        trackView.addSubview(progressOverlayView)

        addSubview(thumbView)

        // User interaction needs to be disabled as otherwise these subviews will
        // consume touch events & we won't get the UIControl touch tracking calls below
        trackView.isUserInteractionEnabled = false
        thumbView.isUserInteractionEnabled = false
    }

    // MARK: - Touch Tracking

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let offsetFromThumb = touch.location(in: thumbView)
        let expandedThumbRegion = thumbView.bounds.expanded(by: 15)

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

        let progress = targetThumbPosition / adjustedTrackWidth

        let lastProgress = progressPercent
        progressPercent = progress

        // When hitting either end of the slider, emit a vibration
        if (progressPercent == 0 || progressPercent == 1) && progressPercent != lastProgress {
            UISelectionFeedbackGenerator().selectionChanged()
        }

        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        cancelTracking(with: event)
    }

    override func cancelTracking(with event: UIEvent?) {
        activeTouch = nil
        activeTouchOffsetFromThumb = nil
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

        let thumbProgressPosition = adjustedTrackWidth * progressPercent

        thumbView.frame.origin = .init(
            x: trackView.frame.minX + thumbProgressPosition,
            y: trackView.frame.minY + trackView.frame.height / 2 - thumbSize / 2
        )

        progressOverlayView.frame.origin = .zero
        progressOverlayView.frame.size.height = trackView.frame.height
        progressOverlayView.frame.size.width = thumbView.frame.midX - trackView.frame.minX
    }
}
