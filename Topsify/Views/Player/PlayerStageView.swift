// Created by Alex Yaro on 2023-04-01.

import Combine
import CombineExt
import Reusable
import UIKit

final class PlayerStageView: AppCollectionView {

    private let layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }()

    private var lastWidth: CGFloat = 0

    private let viewModel: PlayerStageViewModel
    private let contentAreaLayoutGuide: UILayoutGuide
    private var disposeBag = DisposeBag()

    private let stoppedOnItemAtIndexRelay = PassthroughRelay<(index: Int, itemList: PlayerStageViewModel.ItemList)>()
    private let willBeginDraggingRelay = PassthroughRelay<Void>()

    private var processingItemListEmission = false
    private var justCalledWillBeginDragging = false
    private var expectedContentOffsetAfterAnimation: CGPoint = .zero

    private var itemList: PlayerStageViewModel.ItemList?

    init(viewModel: PlayerStageViewModel, contentAreaLayoutGuide: UILayoutGuide) {
        self.viewModel = viewModel
        self.contentAreaLayoutGuide = contentAreaLayoutGuide

        super.init(collectionViewLayout: layout)

        backgroundColor = .clear
        isPagingEnabled = true
        decelerationRate = .normal
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        delegate = self
        dataSource = self

        registerEmptyCell()
        register(cellType: PlayerStageBasicItemCell.self)

        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            stoppedOnItemAtIndex: stoppedOnItemAtIndexRelay
                .eraseToAnyPublisher(),
            willBeginDragging: willBeginDraggingRelay
                .eraseToAnyPublisher()
        ))

        outputs.itemList
            .sink { [weak self] newItemList in
                guard let self else { return }

                assert(!processingItemListEmission, "Got an ItemList emission before the previous emission was processed")
                processingItemListEmission = true
                defer { self.processingItemListEmission = false }

                let lastItemList = itemList

                let contentOffsetPreReload = contentOffset.x

                itemList = newItemList

                reloadData()

                if !justCalledWillBeginDragging {
                    /// Note that cancelling touches may result in a call to `scrollViewDidEndDragging` in the delegate, which is okay as any
                    /// emissions to `stoppedOnItemAtIndexRelay` are guarded by `processingItemListEmission` being `false`.
                    cancelActiveTouches()
                }

                if let itemList {
                    if let transition = itemList.transition {
                        /// It's important not to use `lastItemList.activeItemIndex` as the previous index, and rather
                        /// calculate the last active item index using & based from the current one. If we were to calculate the offset using
                        /// the `lastItemList.activeItemIndex`, we'd risk an invalid offset *if an item was removed*.
                        /// In addition to the offset being wrong, the resulting animation could get glitched if the overall `contentOffset`
                        /// is negative, due to poor interaction with UIKit's bounce-back animation (read other comment in `setItemIndex`):
                        let deltaToLastActiveItemIndex: Int
                        switch transition {
                        case .movedForward:
                            deltaToLastActiveItemIndex = -1
                        case .movedBackward:
                            deltaToLastActiveItemIndex = 1
                        }
                        let offsetFromPreviousActiveItem = contentOffsetPreReload - contentOffset(forItemIndex: itemList.activeItemIndex + deltaToLastActiveItemIndex).x

                        switch transition {
                        case .movedForward:
                            setItemIndex(itemList.activeItemIndex - 1, offset: offsetFromPreviousActiveItem, animated: false)
                        case .movedBackward:
                            setItemIndex(itemList.activeItemIndex + 1, offset: offsetFromPreviousActiveItem, animated: false)
                        }
                        setItemIndex(itemList.activeItemIndex, animated: true)
                    } else {
                        /// The item list may be updated in response to a `willBeginDragging` emission.
                        /// However, we send that emission *before* passing the touch event to the collection view, so
                        /// the collection view states that we're not tracking/dragging. To work around this,
                        /// `justCalledWillBeginDragging` is additionally used to determine if we're dragging.
                        let isDragging = justCalledWillBeginDragging || isTracking || isDragging
                        let offsetFromPreviousActiveItem = contentOffsetPreReload - contentOffset(forItemIndex: lastItemList?.activeItemIndex ?? 0).x

                        setItemIndex(
                            itemList.activeItemIndex,
                            /// We only want to keep the offset when the user is dragging (to avoid sudden offset jumps).
                            /// Primary example of this is if/when we're animating to a new active item & the user touches down
                            /// to interrupt the animation.
                            offset: isDragging ? offsetFromPreviousActiveItem : 0,
                            animated: false
                        )
                    }
                }
            }
            .store(in: &disposeBag)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        contentAreaLayoutGuide.layoutFrame.contains(point)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        defer { lastWidth = bounds.width }

        /// If the bounds change, ensure we're on the right item index. This check is especially important
        /// for the initial layout of the view, as the `itemList` is emitted before the layout occurs.
        if lastWidth != bounds.width, let itemList {
            cancelActiveTouches()
            setItemIndex(itemList.activeItemIndex, animated: false)
        }
    }

    private func cancelActiveTouches() {
        // This is achieved by flipping the isEnabled gesture flag:
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = true
    }

    private func itemIndex(for contentOffset: CGPoint) -> Int {
        Int(round(contentOffset.x / bounds.width))
    }

    private func contentOffset(forItemIndex index: Int) -> CGPoint {
        CGPoint(
            x: CGFloat(index) * bounds.width,
            y: 0
        )
    }

    private func setItemIndex(_ index: Int, offset: CGFloat = 0, animated: Bool) {
        var contentOffset = contentOffset(forItemIndex: index)
        contentOffset.x += offset
        if animated {
            expectedContentOffsetAfterAnimation = contentOffset
        }
        if contentOffset.x < 0 {
            /// To avoid any weird animation interaction with the UIKit's `UIScrollView` bounce-back spring effect,
            /// ensure we're not setting a negative `contentOffset`. If we do set a negative content offset,
            /// say for example -253, what will happen is UIKit will try to animate from this offset back to `zero` as
            /// part of the bounce-back effect. However, if we also start an animated offset change at the same time,
            /// to e.g. 360, UIKit will perform the bounce-back effect simultaneously and we'll end up at 360 + 253 offset!
            /// Previously it was possible for the `offset` param to result in a negative `contentOffset` due to
            /// items being removed as part of a forward/backward transition. This is now accounted for, but keeping this
            /// safeguard just in case.
            contentOffset.x = 0
        }
        setContentOffset(contentOffset, animated: animated)
    }

    private func sendStoppedAtIndexEvent() {
        guard !isTracking && !isDragging else {
            /// We never want to send this event if the user is still dragging the collection view,
            /// as we risk an invalid offset being applied when calling `setItemIndex` in response
            /// to getting a new `itemList`.
            return
        }
        guard !processingItemListEmission else {
            /// If we're in the middle of processing an `ItemList` emission, we want to avoid
            /// sending the event as it may result in a second emission before we've finished processing the first.
            /// This can happen if any active touches are cancelled during the `ItemList` emission processing,
            /// which can result in this method getting called from one of the `UICollectionViewDelegate` callback.
            return
        }
        guard let itemList else { return }
        stoppedOnItemAtIndexRelay.accept((index: itemIndex(for: contentOffset), itemList: itemList))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// Using `setContentOffset` inside `scrollViewWillBeginDragging` does not seem to work, as it's overriden
        /// following the continued drag. As a result, emitting to `willBeginDraggingRelay`, which may potentially shift around the
        /// cells and require content offset changes, is problematic within that delegate method. Setting `contentOffset` directly
        /// seems to work better, but it's still buggy for certain edge cases (e.g. dragging near the end of the collection while removing
        /// the last cell). As a result, we need to update the collection data *before* the delegate method is called, and doing it
        /// here seems to work well.
        justCalledWillBeginDragging = true
        willBeginDraggingRelay.accept()
        justCalledWillBeginDragging = false
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if !isDecelerating {
            /// If the touch was just a quick tap, the scroll view will *not* register it as a drag, so none of the delegate methods will get
            /// called, and the scroll view will not automatically decelerate the content offset to the right position. Since `touchesBegan`
            /// invokes `willBeginDraggingRelay`, which can emit a new ItemList, we need to check that the current content
            /// offset is at a valid resting position (not stuck mid-page/item):
            let currentItemIndex = itemIndex(for: contentOffset)
            if contentOffset != contentOffset(forItemIndex: currentItemIndex) {
                setItemIndex(currentItemIndex, animated: true)
            }
        }
    }
}

extension PlayerStageView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = itemList?[itemAt: indexPath.item] else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PlayerStageBasicItemCell.self)
        cell.constrain(verticallyInside: contentAreaLayoutGuide)
        cell.configure(tempImageURL: item.artworkURL)
        return cell
    }
}

extension PlayerStageView: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /// Do not call anything here that tries to update `contentOffset` - see comment in `hitTest` above.
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            sendStoppedAtIndexEvent()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /// `scrollViewDidEndDecelerating` seems to be fired if the collection view is bouncing back
        /// (outside the content rectangle) and the user touches down before the bounce back is complete. In
        /// this case, we do *not* want to send the stoppedAt event.
        if !isTracking {
            sendStoppedAtIndexEvent()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        /// It's important not to call `scrollingDidStop` if the animation was *interrupted* (did not complete).
        /// To verify this, we compare the current offset to the expected offset from the last commited animation.
        if contentOffset == expectedContentOffsetAfterAnimation {
            sendStoppedAtIndexEvent()
        }
    }
}
