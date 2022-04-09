//
//  AppButton.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-06.
//

import UIKit

class AppButton: UIControl {
    private let wrapperView = UIView()
    let contentView: UIView
    var scaleOnTap: Bool
    
    typealias TapHandler = () -> Void
    var onTap: TapHandler?
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                UIView.animate(withDuration: isHighlighted ? 0.05 : 0.2, delay: 0, options: [.allowUserInteraction]) { [unowned self] in
                    wrapperView.alpha = isHighlighted ? 0.9 : 1.0
                    let scale = self.isHighlighted && scaleOnTap ? 0.95 : 1
                    wrapperView.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
    }
    
    init(contentView: UIView? = nil, scaleOnTap: Bool = true, onTap: TapHandler? = nil) {
        let contentView = contentView ?? UIView()
        
        self.wrapperView.isUserInteractionEnabled = false
        self.contentView = contentView
        self.scaleOnTap = scaleOnTap
        self.onTap = onTap
        
        super.init(frame: .zero)
        
        addSubview0(wrapperView)
        wrapperView.constrain(into: self)
        
        wrapperView.addSubview(contentView)
        contentView.constrain(into: wrapperView)
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    override func addSubview(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    private func addSubview0(_ view: UIView) {
        super.addSubview(view)
    }
}
