import UIKit

@MainActor
protocol VersionDetailsViewControlling: AnyObject {
    func showLoadedState(_ state: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel)
    func showLoadingState(_ state: VersionDetailsViewModel.State.VersionPreviewViewModel)
    func showError(_ error: Error)
}

final class VersionDetailsViewController: UIViewController, VersionDetailsViewControlling {

    private let interactor: VersionDetailsInteractor

    init(interactor: VersionDetailsInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deinit \(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        interactor.viewDidLoad()
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            interactor.viewWillUnload()
        }
        super.willMove(toParent: parent)
    }

    func showLoadedState(_ state: VersionDetailsViewModel.State.LoadedVersionDetailsViewModel) {
        print(state)
    }

    func showLoadingState(_ state: VersionDetailsViewModel.State.VersionPreviewViewModel) {
        
    }

    func showError(_ error: Error) {
        let alertVC = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(.init(title: "Ok", style: .default))
        present(alertVC, animated: true)
    }
}
