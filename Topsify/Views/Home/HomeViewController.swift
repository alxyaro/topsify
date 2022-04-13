//
//  HomeViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit

class HomeViewController: UIViewController, AppNavigableController {
    
    var isNavBarSticky = false
    var navBarButtons = [AppNavigationBarButton]()
    var mainScrollView: UIScrollView? = nil
    var mainScrollViewOnScroll: AppNavigableController.Callback?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test Title"
        
        view.directionalLayoutMargins.leading = 15
        view.directionalLayoutMargins.trailing = 15
        
        let header = HomeHeaderView()
        
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        header.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        let productionRowView = ArtifactRowView()
        productionRowView.preservesSuperviewLayoutMargins = true
        
        view.addSubview(productionRowView)
        productionRowView.translatesAutoresizingMaskIntoConstraints = false
        productionRowView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 15).isActive = true
        productionRowView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        productionRowView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        navBarButtons.append(AppNavigationBarButton(iconName: Bool.random() ? "flame" : "trash", onTap: {
            self.navigationController?.pushViewController(HomeViewController(), animated: true)
        }))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
