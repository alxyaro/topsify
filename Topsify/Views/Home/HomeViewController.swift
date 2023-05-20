//
//  HomeViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit
import Combine
import CombineExt

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
        CALayer.performWithoutAnimation {
            backgroundGradient.anchorPoint = .zero
            backgroundGradient.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
            updateGradientPosition()
        }
    }
    
    // MARK: - Helpers

    private func updateGradientPosition() {
        let collectionView = collectionManager.collectionView
        CALayer.performWithoutAnimation {
            backgroundGradient.position.y = min(0, -(collectionView.contentOffset.y + collectionView.adjustedContentInset.top) / 2)
        }
    }

    private func configureViews() {
        view.addSubview(collectionManager.collectionView)
        collectionManager.collectionView.constrainEdgesToSuperview()

        view.layer.insertSublayer(backgroundGradient, at: 0)
        collectionManager.collectionView.didScrollPublisher
            .sink { [weak self] in
                self?.updateGradientPosition()
            }
            .store(in: &disposeBag)
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

        outputs.backgroundTintStyle
            .sink { [weak self] style in
                let color: UIColor = {
                    switch style {
                    case .night:
                        return UIColor(named: "HomeTimeTints/NightColor")
                    case .morning:
                        return UIColor(named: "HomeTimeTints/MorningColor")
                    case .afternoon:
                        return UIColor(named: "HomeTimeTints/AfternoonColor")
                    case .evening:
                        return UIColor(named: "HomeTimeTints/EveningColor")
                    }
                }()
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
