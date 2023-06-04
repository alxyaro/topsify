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
    private var interactionControllerForDismissal: UIPercentDrivenInteractiveTransition?
    private let dismissalPanGestureRecognizer = DirectionalPanGestureRecognizer(direction: .down)

    private let viewModel: PlayerViewModel

    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
        setupDismissalGesture()
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
        dismissalPanGestureRecognizer.addTarget(self, action: #selector(handleDismissalPan(sender:)))
        dismissalPanGestureRecognizer.delegate = self
    }

    @objc private func handleDismissalPan(sender: DirectionalPanGestureRecognizer) {
        let percentComplete = (sender.translation(in: view).y / view.frame.height).clamped(to: 0...1)

        switch sender.state {
        case .possible:
            break
        case .began:
            if let controller = interactionControllerForDismissal {
                controller.cancel()
            }
            guard let presentingViewController, presentingViewController.presentedViewController == self else {
                return
            }
            interactionControllerForDismissal = UIPercentDrivenInteractiveTransition()
            presentingViewController.dismiss(animated: true)
        case .changed:
            interactionControllerForDismissal?.update(percentComplete)
        case .ended, .cancelled, .failed: fallthrough
        @unknown default:
            if let controller = interactionControllerForDismissal {
                var shouldFinish = percentComplete >= 0.5
                let velocity = sender.velocity(in: view).y
                if abs(velocity) > 1000 {
                    shouldFinish = velocity > 0
                }

                controller.completionCurve = .easeOut
                controller.completionSpeed = max(0.95, abs(velocity) / 1500)
                if shouldFinish {
                    controller.finish()
                } else {
                    controller.cancel()
                }
            }
            interactionControllerForDismissal = nil
        }
    }
}

extension PlayerViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
    }
}

extension PlayerViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PlayerTransitionController(animation: .appear)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PlayerTransitionController(animation: .disappear)
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // TODO: implement, use optional value passed in init?
        nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionControllerForDismissal
    }
}
