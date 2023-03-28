// Created by Alex Yaro on 2023-03-27.

import UIKit

final class PlayerTitleView: UIView {

    private let titleView: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 24, weight: .bold)
        label.textColor = .appTextPrimary
        label.text = "Some Lengthy Song (with Lil Artist Name Here)" // FIXME: remove
        return label
    }()

    init() {
        super.init(frame: .zero)

        let titleWrapper = MarqueeView(titleView)
        addSubview(titleWrapper)
        // FIXME: temp; insets should only be set on PlayerViewController stack
        titleWrapper.constrainEdgesToSuperview(withInsets: .init(horizontal: 24, vertical: 0))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
