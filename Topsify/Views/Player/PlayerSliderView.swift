// Created by Alex Yaro on 2023-03-26.

import UIKit

final class PlayerSliderView: UIView {
    private static let indeterminateTimeText = NSLocalizedString("-:--", comment: "Placeholder used for when the real time value (e.g. 1:23) is not available")

    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = []
        return formatter
    }()

    private let slider = PlayerSlider()

    private let leadingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        return label
    }()

    private let trailingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        return label
    }()

    private let viewModel: PlayerSliderViewModel
    private var disposeBag = DisposeBag()

    init(viewModel: PlayerSliderViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        semanticContentAttribute = .playback

        let extraSliderSidePadding = PlayerViewConstants.contentSidePadding - PlayerSlider.padding

        addSubview(slider)
        slider.useAutoLayout()
        slider.topAnchor.constraint(equalTo: topAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: extraSliderSidePadding).isActive = true
        slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -extraSliderSidePadding).isActive = true
        slider.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true

        let timeLabelsStackView = UIStackView(arrangedSubviews: [leadingTimeLabel, trailingTimeLabel])
        timeLabelsStackView.axis = .horizontal
        timeLabelsStackView.distribution = .equalSpacing
        timeLabelsStackView.alignment = .center

        addSubview(timeLabelsStackView)
        timeLabelsStackView.constrainEdges(to: slider, excluding: .vertical, withInsets: .horizontal(PlayerSlider.padding))
        timeLabelsStackView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 3 - PlayerSlider.padding).isActive = true
        timeLabelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor).priority(.justLessThanRequired).isActive = true

        // Bring slider to front so it gets priority on touch events:
        bringSubviewToFront(slider)
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(
            inputs: .init(
                movedThumbToPercentage: slider.controlEventPublisher(for: .valueChangedByUser)
                    .compactMap { [weak self] in
                        self?.slider.valuePercentage
                    }
                    .map(Double.init)
                    .eraseToAnyPublisher()
            )
        )

        outputs.thumbPositionPercentage
            .sink { [weak self] valuePercentage in
                guard let self else { return }
                if let valuePercentage {
                    slider.valuePercentage = CGFloat(valuePercentage)
                    slider.isEnabled = true
                } else {
                    slider.valuePercentage = nil
                    slider.isEnabled = false
                }
            }
            .store(in: &disposeBag)

        outputs.elapsedSongDuration
            .reEmit(onOutputFrom: slider.controlEventPublisher(for: PlayerSlider.dragValueChangedEvent))
            .withLatestFrom(outputs.songDuration) { ($0, $1) }
            .sink { [weak self] elapsedSongDuration, songDuration in
                guard let self else { return }
                guard let elapsedSongDuration else {
                    leadingTimeLabel.text = Self.indeterminateTimeText
                    return
                }
                var durationValue = elapsedSongDuration
                if let dragValuePercentage = slider.dragValuePercentage, let songDuration {
                    durationValue = songDuration * Double(dragValuePercentage)
                }
                leadingTimeLabel.text = timeFormatter.string(from: durationValue)
            }
            .store(in: &disposeBag)

        outputs.songDuration
            .sink { [weak self] songDuration in
                guard let self else { return }
                guard let songDuration else {
                    trailingTimeLabel.text = Self.indeterminateTimeText
                    return
                }
                trailingTimeLabel.text = timeFormatter.string(from: songDuration)
            }
            .store(in: &disposeBag)
    }
}
