// Created by Alex Yaro on 2023-01-29.

import Combine
import UIKit

final class RemoteImageView: UIImageView {
    private let imageProvider: ImageProviderType

    private var loadCancellable: AnyCancellable?

    init(imageProvider: ImageProviderType = Environment.current.imageProvider) {
        self.imageProvider = imageProvider
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        reset()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        layer.removeAllAnimations()
        backgroundColor = .black
        image = nil
    }

    func configure(with url: URL) {
        reset()
        applyLoadingStyle()

        // disable animations for the publisher subscription call in case an image is available immediately
        UIView.performWithoutAnimation {
            loadCancellable = imageProvider.image(for: url).sink { [weak self] completion in
                if case .failure = completion {
                    self?.applyErrorStyle()
                }
            } receiveValue: { [weak self] image in
                self?.applyImage(image)
            }
        }
    }

    // MARK: - Private Helpers

    private func applyLoadingStyle() {
        backgroundColor = .loadingGlimmerFirst
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat]) { [weak self] in
            self?.backgroundColor = .loadingGlimmerSecond
        }
    }

    private func applyErrorStyle() {
        layer.removeAllAnimations()
        performWithAnimation {
            self.backgroundColor = .black
        }
    }

    private func applyImage(_ image: UIImage) {
        layer.removeAllAnimations()
        performWithAnimation {
            self.image = image
        }
    }

    private func performWithAnimation(_ action: @escaping () -> Void) {
        if UIView.areAnimationsEnabled {
            /// `UIView.transition` doesn't seem to respect `performWithoutAnimation` on its own.
            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: action)
        } else {
            action()
        }
    }
}
