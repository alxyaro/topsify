//
//  AppNavigableController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

protocol AppNavigableController {
    typealias Callback = () -> Void
    
    var isNavBarSticky: Bool { get }
    var navBarButtons: [AppNavigationBarButton] { get }
    var mainScrollView: UIScrollView? { get }
    var mainScrollViewOnScroll: Callback? { get set }
}
