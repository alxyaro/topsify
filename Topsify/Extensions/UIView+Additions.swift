//
//  UIView+Additions.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-28.
//

import UIKit

extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil)![0] as! T
    }

    @discardableResult
    func useAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    @available(*, deprecated, renamed: "constrainEdges(to:)")
    func constrain(into view: UIView) {
        constrainEdges(to: view)
    }
    
    func constrainEdges(
        to view: UIView,
        excluding excludedEdges: EdgeSet = [],
        withInsets insets: NSDirectionalEdgeInsets = .zero,
        withPriorities priorities: EdgePriorities = .init()
    ) {
        useAutoLayout()
        if !excludedEdges.contains(.leading) {
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.leading).priority(priorities.leading).isActive = true
        }
        if !excludedEdges.contains(.trailing) {
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.trailing).priority(priorities.trailing).isActive = true
        }
        if !excludedEdges.contains(.top) {
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).priority(priorities.top).isActive = true
        }
        if !excludedEdges.contains(.bottom) {
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom).priority(priorities.bottom).isActive = true
        }
    }

    func constrainEdgesToSuperview(
        excluding excludedEdges: EdgeSet = [],
        withInsets insets: NSDirectionalEdgeInsets = .zero,
        withPriorities priorities: EdgePriorities = .init()
    ) {
        guard let superview else { return }
        constrainEdges(to: superview, excluding: excludedEdges, withInsets: insets, withPriorities: priorities)
    }

    func constrainInCenter(of view: UIView) {
        useAutoLayout()
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func constrainInCenterOfSuperview() {
        guard let superview else { return }
        constrainInCenter(of: superview)
    }
}

struct EdgeSet: OptionSet {
    static let leading = EdgeSet(rawValue: 1 << 0)
    static let trailing = EdgeSet(rawValue: 1 << 1)
    static let top = EdgeSet(rawValue: 1 << 2)
    static let bottom = EdgeSet(rawValue: 1 << 3)

    var rawValue: Int
}

struct EdgePriorities {
    /// Useful for composition layout cells. This avoids the `UIView-Encapsulated-Layout-` unsatisfiable constrains spam
    /// that happens during initial layout (seems to be when using estimated cell sizing that clashes with actual size).
    static let forCellSizing = Self(trailing: .justLessThanRequired, bottom: .justLessThanRequired)

    var leading: UILayoutPriority = .required
    var trailing: UILayoutPriority = .required
    var top: UILayoutPriority = .required
    var bottom: UILayoutPriority = .required
}
