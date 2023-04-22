// Created by Alex Yaro on 2023-04-01.

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

        viewModel.itemList
            .sink { [weak self] itemList in
                guard let self else { return }
                self.itemList = itemList
                reloadData()
                setItemIndex(itemList?.activeItemIndex ?? 0)
            }
            .store(in: &disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        contentAreaLayoutGuide.layoutFrame.contains(point)
    }

    private func itemIndex(for contentOffset: CGPoint) -> Int {
        Int(contentOffset.x / bounds.width)
    }

    private func setItemIndex(_ index: Int) {
        setContentOffset(.init(x: CGFloat(index) * bounds.width, y: 0), animated: false)
    }

    private func scrollingDidStop() {
        guard let itemList else { return }
        viewModel.movedToItem(atIndex: itemIndex(for: contentOffset), itemList: itemList)
    }

    // Kept for future reference in case this is needed again:
    /*override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result != nil {
            /// Using `setContentOffset` inside `scrollViewWillBeginDragging` does not seem to work, as it's overriden
            /// following the continued drag. As a result, calling `updateCollectionData`, which may potentially shift around the
            /// cells and require content offset changes, is problematic within that delegate method. Setting `contentOffset` directly
            /// seems to work better, but it's still buggy for certain edge cases (e.g. dragging near the end of the collection while removing
            /// the last cell). As a result, we need to update the collection data *before* the delegate method is called, and doing it
            /// here in `hitTest` seems to work well.
            updateCollectionData(snapToExactPage: false)
        }
        return result
    }*/
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
            scrollingDidStop()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingDidStop()
    }
}
