#if canImport(UIKit)
    import UIKit

    public extension UICollectionView {

        func register<T: UICollectionViewCell>(cellType: T.Type) {
            register(T.self, forCellWithReuseIdentifier: reuseIdentifier(for: cellType))
        }

        func dequeueReusableCell<T: UICollectionViewCell>(for type: T.Type, indexPath: IndexPath) -> T {
            let identifier = reuseIdentifier(for: type)

            guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
                fatalError("Cell (\(type)) is not registered for identifier: \(identifier)")
            }

            return cell
        }

        private func reuseIdentifier<T>(for type: T.Type) -> String {
            String(describing: type)
        }
    }
#endif
