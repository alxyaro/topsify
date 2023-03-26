//
//  HomeViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit
import Combine
import CombineExt
import CombineCocoa

final class HomeViewController: AppNavigableController {
    
    private let backgroundGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.type = .axial
        layer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 0.4, y: 0.8)
        return layer
    }()

    private let loadStateView = LoadStateView<HomeViewModel.HomeError>()

    private let viewDidAppearRelay = PassthroughRelay<Void>()

    private let collectionManager = CollectionManager()

    private let viewModel: HomeViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModel = .init(dependencies: .live())) {
        self.viewModel = viewModel
        
        super.init()

        configureViews()
        configureNavigation()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearRelay.accept()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundGradient.anchorPoint = .zero
        backgroundGradient.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
    }
    
    // MARK: - Helpers

    private func configureViews() {
        view.addSubview(collectionManager.collectionView)
        collectionManager.collectionView.constrainEdgesToSuperview()

        collectionManager.collectionView.didScrollPublisher
            .sink { [weak self] in
                guard let self else { return }
                let collectionView = self.collectionManager.collectionView
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.backgroundGradient.position.y = min(0, -(collectionView.contentOffset.y + collectionView.adjustedContentInset.top) / 2)
                CATransaction.commit()
            }
            .store(in: &disposeBag)

        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func configureNavigation() {
        navBarButtons += [
            AppNavigationBarButton(iconName: "bell", onTap: {

            }),
            AppNavigationBarButton(iconName: "clock.arrow.circlepath", onTap: {

            }),
            AppNavigationBarButton(iconName: "gear", onTap: { [weak self] in
                self?.navigationController?.pushViewController(HomeViewController(), animated: true)
            })
        ]
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            viewDidAppear: viewDidAppearRelay.eraseToAnyPublisher(),
            tappedReloadButton: Empty(completeImmediately: false).eraseToAnyPublisher()
        ))

        loadStateView.configure(loadState: outputs.loadState)

        outputs.navBarTitle
            .mapOptional()
            .assignWeakly(to: \.title, on: self)
            .store(in: &disposeBag)

        outputs.backgroundTint
            .sink { [weak self] color in
                self?.backgroundGradient.colors?[0] = color.cgColor
            }
            .store(in: &disposeBag)

        outputs.sections
            .sink { [weak collectionManager] in
                collectionManager?.updateSections($0)
            }
            .store(in: &disposeBag)
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundGradient.position.y = min(0, -(scrollView.contentOffset.y + scrollView.adjustedContentInset.top) / 2)
        CATransaction.commit()
    }
}
