// Created by Alex Yaro on 2023-10-02.

import UIKit

protocol BannerCollectionViewControllerDelegate<Section>: AnyObject {
    associatedtype Section

    func layoutSection(for section: Section, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
    func headerView(collectionView: UICollectionView, ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func cell(collectionView: UICollectionView, forSection section: Section, at indexPath: IndexPath) -> UICollectionViewCell
}

class BannerCollectionViewController<Section, Delegate>: UIViewController
where Section: Hashable,
      Delegate: BannerCollectionViewControllerDelegate<Section> {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias DataSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>

    private(set) lazy var collectionViewLayout: BannerLayout = {
        return BannerLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self, let section = dataSource.snapshot().sectionIdentifiers[safe: sectionIndex] else {
                return nil
            }
            return delegate?.layoutSection(for: section, layoutEnvironment: layoutEnvironment)
        }
    }()

    private(set) lazy var collectionView: AppCollectionView = {
        let collectionView = AppCollectionView(collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.indicatorStyle = .white
        collectionView.registerEmptyCell()
        return collectionView
    }()

    private(set) lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { [weak self, weak delegate] collectionView, indexPath, itemIdentifier in
            guard
                let section = self?.section(for: indexPath.section),
                let cell = delegate?.cell(collectionView: collectionView, forSection: section, at: indexPath)
            else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak delegate] collectionView, kind, indexPath in
            guard let headerView = delegate?.headerView(collectionView: collectionView, ofKind: kind, at: indexPath) else {
                return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
            }
            return headerView
        }

        return dataSource
    }()

    weak var delegate: Delegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground

        view.addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()
    }

    func section(for index: Int) -> Section? {
        if #available(iOS 15, *) {
            dataSource.sectionIdentifier(for: index)
        } else {
            dataSource.snapshot().sectionIdentifiers[safe: index]
        }
    }
}
