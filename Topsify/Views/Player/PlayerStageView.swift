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

    private let viewModel: PlayerStageViewModel
    private let contentAreaLayoutGuide: UILayoutGuide
    private var disposeBag = DisposeBag()

    private let stoppedOnItemAtIndexRelay = PassthroughRelay<Int>()
    private let willBeginDraggingRelay = PassthroughRelay<Void>()

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

        register(cellType: PlayerStageBasicItemCell.self)

        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            stoppedOnItemAtIndex: stoppedOnItemAtIndexRelay
                .compactMap { [weak self] index in
                    guard let itemList = self?.itemList else {
                        return nil
                    }
                    return (index: index, itemList: itemList)
                }
                .eraseToAnyPublisher(),
            willBeginDragging: willBeginDraggingRelay
                .eraseToAnyPublisher()
        ))

        outputs.itemList
            .sink { [weak self] newItemList in
                guard let self else { return }
                let lastItemList = itemList

                let offsetFromPreviousActiveItem = contentOffset.x - contentOffset(forItemIndex: lastItemList?.activeItemIndex ?? 0).x

                itemList = newItemList

                reloadData()

                if let itemList {
                    if let transition = itemList.transition {
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

    private func itemIndex(for contentOffset: CGPoint) -> Int {
        Int(contentOffset.x / bounds.width)
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
        setContentOffset(contentOffset, animated: animated)
    }

    private func sendStoppedAtIndexEvent() {
        guard !isTracking && !isDragging else {
            /// We never want to send this event if the user is still dragging the collection view,
            /// as we risk an invalid offset being applied when calling `setItemIndex` in response
            /// to getting a new `itemList`.
            /// This can happen
            return
        }
        stoppedOnItemAtIndexRelay.accept(itemIndex(for: contentOffset))
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
