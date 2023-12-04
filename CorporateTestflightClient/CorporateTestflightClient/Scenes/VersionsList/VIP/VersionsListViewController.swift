import UIKit
import TestflightUIKit

@MainActor
protocol VersionsListViewControlling: AnyObject {
    func showVersions(_ versions: [VersionsListModels.VersionViewModel])
    func showProjectName(_ projectName: String)
}

final class VersionsListViewController: UIViewController, VersionsListViewControlling {

    private let interactor: VersionsListInteractorProtocol
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout())

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, VersionsListModels.VersionViewModel> = {
        let dataSource = UICollectionViewDiffableDataSource<Int, VersionsListModels.VersionViewModel>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, version in
                let cell = collectionView.dequeueReusableCell(for: VersionListCell.self, indexPath: indexPath)
                cell.configure(title: version.title, subtitle: version.subtitle)
                return cell
            }
        )
        return dataSource
    }()

    init(interactor: VersionsListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        makeLayout()
        interactor.viewDidLoad()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }

    func showVersions(_ versions: [VersionsListModels.VersionViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VersionsListModels.VersionViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(versions, toSection: 0)
        dataSource.apply(snapshot)
    }

    func showProjectName(_ projectName: String) {
        title = projectName
    }
}

private extension VersionsListViewController {

    func makeCollectionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 10,
            bottom: 10,
            trailing: 10
        )
        section.interGroupSpacing = 0

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    func makeLayout() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
//        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.register(cellType: VersionListCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        )
    }
}
