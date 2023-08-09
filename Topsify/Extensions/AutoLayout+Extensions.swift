//
//  AutoLayout+Extensions.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-28.
//

import UIKit

extension UIView {

    @discardableResult
    func useAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    func constrainEdges(
        to anchorable: FrameAnchorable,
        excluding excludedEdges: EdgeSet = [],
        withInsets insets: NSDirectionalEdgeInsets = .zero,
        withPriorities priorities: EdgePriorities = .init()
    ) {
        useAutoLayout()
        if !excludedEdges.contains(.leading) {
            leadingAnchor.constraint(equalTo: anchorable.leadingAnchor, constant: insets.leading).priority(priorities.leading).isActive = true
        }
        if !excludedEdges.contains(.trailing) {
            trailingAnchor.constraint(equalTo: anchorable.trailingAnchor, constant: -insets.trailing).priority(priorities.trailing).isActive = true
        }
        if !excludedEdges.contains(.top) {
            topAnchor.constraint(equalTo: anchorable.topAnchor, constant: insets.top).priority(priorities.top).isActive = true
        }
        if !excludedEdges.contains(.bottom) {
            bottomAnchor.constraint(equalTo: anchorable.bottomAnchor, constant: -insets.bottom).priority(priorities.bottom).isActive = true
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

    func constrainInCenter(of anchorable: FrameAnchorable) {
        useAutoLayout()
        centerXAnchor.constraint(equalTo: anchorable.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: anchorable.centerYAnchor).isActive = true
    }

    func constrainInCenterOfSuperview() {
        guard let superview else { return }
        constrainInCenter(of: superview)
    }

    func constrainWidth(to width: CGFloat) {
        useAutoLayout()
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    func constrainHeight(to height: CGFloat) {
        useAutoLayout()
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    func constrainDimensions(width: CGFloat, height: CGFloat) {
        useAutoLayout()
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    func constrainDimensions(uniform value: CGFloat) {
        constrainDimensions(width: value, height: value)
    }

    func requireIntrinsicWidth() {
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func requireIntrinsicHeight() {
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func requireIntrinsicDimensions() {
        requireIntrinsicWidth()
        requireIntrinsicHeight()
    }
}

protocol FrameAnchorable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: FrameAnchorable {}
extension UILayoutGuide: FrameAnchorable {}

struct EdgeSet: OptionSet {
    static let leading = EdgeSet(rawValue: 1 << 0)
    static let trailing = EdgeSet(rawValue: 1 << 1)
    static let top = EdgeSet(rawValue: 1 << 2)
    static let bottom = EdgeSet(rawValue: 1 << 3)

    static let horizontal: Self = [.leading, .trailing]
    static let vertical: Self = [.top, .bottom]

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
