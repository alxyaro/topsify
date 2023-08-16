// Created by Alex Yaro on 2023-08-05.

import Combine
import Reusable
import UIKit

class BannerView: UICollectionReusableView, Reusable {
    static let kind = "BannerView"
    static let indexPath = IndexPath(index: 0)

    private var lastSize = CGSize.zero
    private var scrollAmount = CGFloat.zero

    private let backgroundGradientView = GradientFadeView(
        color: .clear,
        direction: .down,
        easing: .quadOut,
        distanceBetweenEasingStops: 100,
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

    func configure(gradientColor: UIColor, scrollAmountPublisher: AnyPublisher<CGFloat, Never>) {
        disposeBag = DisposeBag()

        backgroundGradientView.color = gradientColor

        scrollAmountPublisher
            .sink { [weak self] scrollAmount in
                guard let self else { return }
                self.scrollAmount = scrollAmount
                updateBackgroundGradient()
            }
            .store(in: &disposeBag)
    }

    private func updateBackgroundGradient() {
        let bounceAmount = -scrollAmount

        backgroundGradientView.frame = bounds.expanded(top: max(0, bounceAmount))
        backgroundGradientView.frame.size.height += 150 // extend gradient a bit below banner
        backgroundGradientView.alpha = 1 - scrollAmount.pctInRange(bounds.height * 0.7 ... bounds.height)
    }
}

extension UICollectionView {

    func registerBannerViewType(_ type: BannerView.Type) {
        register(supplementaryViewType: type, ofKind: BannerView.kind)
        registerEmptySupplementaryView(ofKind: BannerView.kind)
    }

    func dequeueBannerView<BV: BannerView>(for indexPath: IndexPath, type: BV.Type = BV.self) -> BV {
        dequeueReusableSupplementaryView(ofKind: BannerView.kind, for: indexPath, viewType: type)
    }

    func bannerView<BV: BannerView>(type: BV.Type = BV.self) -> BV? {
        supplementaryView(forElementKind: BannerView.kind, at: BannerView.indexPath) as? BV
    }
}
