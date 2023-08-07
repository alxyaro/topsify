// Created by Alex Yaro on 2023-08-05.

import Combine
import Reusable
import UIKit

class BannerView: UICollectionReusableView, Reusable {
    static let kind = "BannerView"

    private var lastSize = CGSize.zero
    private var scrollDownAmount = CGFloat.zero

    private let backgroundGradientView = GradientFadeView(
        color: .clear,
        direction: .down,
        easing: .quadOut,
        redrawOnBoundsChange: false
    )

    private var disposeBag = DisposeBag()

    required override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(backgroundGradientView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if lastSize != bounds.size {
            updateBackgroundGradient()
        }
    }

    func configure(gradientColor: UIColor, scrollDownAmountPublisher: AnyPublisher<CGFloat, Never>) {
        disposeBag = DisposeBag()

        backgroundGradientView.color = gradientColor

        scrollDownAmountPublisher
            .sink { [weak self] scrollDownAmount in
                guard let self else { return }
                self.scrollDownAmount = scrollDownAmount
                updateBackgroundGradient()
            }
            .store(in: &disposeBag)
    }

    private func updateBackgroundGradient() {
        let scrollUpAmount = -scrollDownAmount

        backgroundGradientView.frame = bounds.expanded(top: max(0, scrollUpAmount))
        backgroundGradientView.frame.size.height += 100
        backgroundGradientView.alpha = 1 - scrollDownAmount.pctInRange(bounds.height * 0.7 ... bounds.height)
    }
}

extension UICollectionView {

    func registerBannerViewType(_ type: BannerView.Type) {
        register(supplementaryViewType: type, ofKind: BannerView.kind)
        registerEmptySupplementaryView(ofKind: BannerView.kind)
    }

    func dequeueBannerView<BV: BannerView>(type: BV.Type = BV.self) -> BV {
        dequeueReusableSupplementaryView(ofKind: BannerView.kind, for: IndexPath(item: 0, section: 0), viewType: type)
    }
}
