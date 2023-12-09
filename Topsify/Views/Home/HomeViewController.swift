//
//  HomeViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit
import Combine
import CombineExt

final class HomeViewController: UIViewController, NavigationHeaderProviding {

    private let backgroundGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.type = .axial
        layer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        layer.startPoint = .zero
        layer.endPoint = CGPoint(x: 0.4, y: 0.8)
        return layer
    }()

    private let loadStateView = LoadStateView()

    private let headerNotificationsButton = NavigationHeaderView.Button(icon: "Icons/notifications")
    private let headerHistoryButton = NavigationHeaderView.Button(icon: "Icons/history")
    private let headerSettingsButton = NavigationHeaderView.Button(icon: "Icons/settings")

    lazy var navigationHeaderView = NavigationHeaderView(buttons: [
        headerNotificationsButton,
        headerHistoryButton,
        headerSettingsButton
    ])

    private lazy var collectionManager = CollectionManager(navigationHeaderView: navigationHeaderView)

    private let viewModel: HomeViewModel
    private let factory: DependencyFactory
    private let viewDidAppearRelay = PassthroughRelay<Void>()
    private var disposeBag = DisposeBag()
    
    init(
        viewModel: HomeViewModel,
        factory: DependencyFactory
    ) {
        self.viewModel = viewModel
        self.factory = factory

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        bindViewModel()
    }

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

    private func setUpView() {
        view.backgroundColor = .appBackground

        view.addSubview(collectionManager.collectionView)
        collectionManager.collectionView.constrainEdgesToSuperview()

        view.layer.insertSublayer(backgroundGradient, at: 0)
        collectionManager.collectionView.didScrollPublisher
            .sink { [weak self] in
                self?.updateGradientPosition()
            }
            .store(in: &disposeBag)

        view.addSubview(loadStateView)
        loadStateView.constrainEdgesToSuperview()
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            viewDidAppear: viewDidAppearRelay.eraseToAnyPublisher(),
            tappedReloadButton: loadStateView.retryButtonTapPublisher
        ))

        loadStateView.configure(loadState: outputs.loadState)

        outputs.navigationHeaderTitle
            .mapOptional()
            .assignWeakly(to: \.navigationHeaderView.title, on: self)
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

        outputs.presentContent
            .sink { [weak self] contentID in
                guard let self, let vc = factory.makeContentViewController(contentID) else { return }
                navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &disposeBag)
    }

    private func updateGradientPosition() {
        let collectionView = collectionManager.collectionView
        CALayer.performWithoutAnimation {
            backgroundGradient.position.y = min(0, -(collectionView.contentOffset.y + collectionView.adjustedContentInset.top) / 2)
        }
    }
}

extension HomeViewController {
    struct DependencyFactory {
        let makeContentViewController: (ContentID) -> UIViewController?
    }
}
