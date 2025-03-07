import UIKit

final class VersionListCell: UICollectionViewCell {
    // MARK: - UI props
    private lazy var titleView: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .preferredFont(forTextStyle: .headline)
        view.numberOfLines = 0
        return view
    }()

    private lazy var subtitleView: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .preferredFont(forTextStyle: .subheadline)
        view.textColor = .secondaryLabel
        view.numberOfLines = 0
        return view
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Class interface
    func configure(title: String, subtitle: String) {
        titleView.text = title
        subtitleView.text = subtitle
    }
}

private extension VersionListCell {
    func configureViews() {
        addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(subtitleView)
        subtitleView.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundColor = .systemBackground

        NSLayoutConstraint.activate(
            [
                titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
                subtitleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                subtitleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                subtitleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ]
        )
    }
}
