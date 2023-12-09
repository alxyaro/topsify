// Created by Alex Yaro on 2023-08-06.

import Combine
import UIKit

final class PlayButton: AppIconButton {
    static let size: CGFloat = 48

    private static let playIcon = "Icons/playCentered"
    private static let pauseIcon = "Icons/pause"

    private var verticalConstraint: NSLayoutConstraint?
    private var disposeBag = DisposeBag()

    init() {
        super.init(icon: Self.playIcon)

        constrainDimensions(uniform: Self.size)

        tintColor = .appBackground
        contentView.backgroundColor = .accent
        contentView.layer.cornerRadius = Self.size / 2

        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowPath = UIBezierPath(roundedRect: .init(origin: .zero, size: .uniform(Self.size)), cornerRadius: Self.size / 2).cgPath
    }

    func constrainVertically(in view: UIView) {
        if superview == nil {
            // If we don't have a TopBar, the PlayButton won't be in the view hierarchy
            assertionFailure(
                """
                PlayButton wasn't already in the view heirarchy!
                Ensure that you're pushing the corresponding VC onto a \(NewAppNavigationController.self).
                """
            )
            view.addSubview(self)
        }
        verticalConstraint?.isActive = false
        verticalConstraint = centerYAnchor.constraint(greaterThanOrEqualTo: view.centerYAnchor).isActive(true)
    }

    func setDynamicVisibility(basedOn loadState: AnyPublisher<LoadState<some UserFacingError>, Never>) {
        UIView.performWithoutAnimation {
            loadState
                .map(\.isLoaded)
                .sink { [weak self] isLoaded in
                    guard let self else { return }
                    if isLoaded {
                        fadeIn()
                    } else {
                        fadeOut()
                    }
                }
                .store(in: &disposeBag)
        }
    }
}
