// Created by Alex Yaro on 2023-02-26.

import Combine
import UIKit

final class LoadStateView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .appTextSecondary
        return indicator
    }()

    private var disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        backgroundColor = .appBackground

        addSubview(activityIndicator)
        activityIndicator.constrainInCenterOfSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(loadState: some Publisher<LoadState<some UserFacingError>, Never>) {
        disposeBag = DisposeBag()

        UIView.performWithoutAnimation {
            loadState
                .map(\.isLoading)
                .sink { [weak activityIndicator] isLoading in
                    if isLoading {
                        activityIndicator?.startAnimating()
                    } else {
                        activityIndicator?.stopAnimating()
                    }
                }
                .store(in: &disposeBag)

            loadState
                .map(\.isLoaded)
                .sink { [weak self] isLoaded in
                    if isLoaded {
                        self?.fadeOut()
                    } else {
                        self?.fadeIn()
                    }
                }
                .store(in: &disposeBag)

            // TODO: error view
        }
    }
}
