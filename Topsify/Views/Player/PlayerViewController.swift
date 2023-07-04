// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerViewController: UIViewController {

    private lazy var stageView = PlayerStageView(
        viewModel: viewModel.stageViewModel,
        contentAreaLayoutGuide: stageContentAreaLayoutGuide
    )
    private lazy var titleView = PlayerTitleView(
        viewModel: viewModel.titleViewModel
    )
    private lazy var controlsView = PlayerControlsView(
        viewModel: viewModel.controlsViewModel
    )
    private let subMenuView = PlayerSubMenuView()

    private let stageContentAreaLayoutGuide = UILayoutGuide()

    private let dismissalPanGestureRecognizer = DirectionalPanGestureRecognizer(direction: .down)
    private var dismissalPanGestureHandler: TransitionPanGestureHandler?

    private let backgroundGradientLayer = CAGradientLayer()

    private let viewModel: PlayerViewModel
    private let playBarView: PlayBarView
    private let interactionControllerForPresentation: UIPercentDrivenInteractiveTransition?
    private var disposeBag = DisposeBag()

    init(viewModel: PlayerViewModel, playBarView: PlayBarView, interactionControllerForPresentation: UIPercentDrivenInteractiveTransition? = nil) {
        self.viewModel = viewModel
        self.playBarView = playBarView
        self.interactionControllerForPresentation = interactionControllerForPresentation

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupView()
        setupDismissalGesture()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundGradientLayer.frame = view.bounds
    }

    private func setupBackground() {
        view.backgroundColor = .black

        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        backgroundGradientLayer.locations = [0, 1]
    }

    private func setupView() {
        view.addSubview(stageView)
        stageView.constrainEdgesToSuperview()

        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(titleView, overhang: PlayerTitleView.insets),
            OverhangingView(controlsView, overhang: PlayerControlsView.insets),
            OverhangingView(subMenuView, overhang: PlayerSubMenuView.insets)
        ])
        mainStackView.axis = .vertical
        mainStackView.directionalLayoutMargins = .init(horizontal: 24, vertical: 16)
        mainStackView.directionalLayoutMargins.top = 0 // to improve stage swiping
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.spacing = 12
        mainStackView.setCustomSpacing(20, after: controlsView.superview ?? UIView())

        view.addSubview(mainStackView)
        mainStackView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .top, withInsets: .bottom(24))

        stageView.addLayoutGuide(stageContentAreaLayoutGuide)
        stageContentAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stageContentAreaLayoutGuide.bottomAnchor.constraint(equalTo: mainStackView.topAnchor, constant: mainStackView.directionalLayoutMargins.top).isActive = true
        stageContentAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stageContentAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func setupDismissalGesture() {
        view.addGestureRecognizer(dismissalPanGestureRecognizer)
        dismissalPanGestureRecognizer.delegate = self

        dismissalPanGestureHandler = .init(
            gestureRecognizer: dismissalPanGestureRecognizer,
            direction: .down,
            delegate: self
        )
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: ())

        outputs.backgroundGradient
            .sink { [weak self] top, bottom in
                guard let self else { return }
                CALayer.perform(withDuration: 0.8) {
                    self.backgroundGradientLayer.colors = [top.uiColor.cgColor, bottom.uiColor.cgColor]
                }
            }
            .store(in: &disposeBag)
    }
}

extension PlayerViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
    }
}

extension PlayerViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PlayerTransitionController(transition: .appear, playBarView: playBarView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PlayerTransitionController(transition: .disappear, playBarView: playBarView)
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionControllerForPresentation
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        dismissalPanGestureHandler?.interactionController
    }
}

extension PlayerViewController: TransitionPanGestureHandlerDelegate {

    func shouldBeginTransition(_ handler: TransitionPanGestureHandler) -> Bool {
        presentingViewController?.presentedViewController == self && !isBeingDismissed
    }

    func beginTransition(_ handler: TransitionPanGestureHandler) {
        presentingViewController?.dismiss(animated: true)
    }

    func completionPanDistance(_ handler: TransitionPanGestureHandler) -> CGFloat {
        let playBarFrameInLocalCoordinates = playBarView.convert(playBarView.bounds, to: view)
        return abs(playBarFrameInLocalCoordinates.minY - view.frame.minY)
    }
}
