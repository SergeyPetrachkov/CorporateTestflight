protocol VersionDetailsPresenting {

    @MainActor
    func showState(_ state: VersionDetailsViewModel.State)
}

final class VersionDetailsPresenter: VersionDetailsPresenting {

    weak var controller: VersionDetailsViewControlling?

    deinit {
        print("Deinit \(self)")
    }

    func showState(_ state: VersionDetailsViewModel.State) {
        switch state {
        case .loading(let versionPreviewViewModel):
            controller?.showLoadingState(versionPreviewViewModel)
        case .loaded(let loadedVersionDetailsViewModel):
            controller?.showLoadedState(loadedVersionDetailsViewModel)
        case .failed(let error):
            controller?.showError(error)
        }
    }
}
