protocol VersionDetailsPresenting {

    @MainActor
    func showState(_ state: VersionDetailsViewModel.State)
}

final class VersionDetailsPresenter: VersionDetailsPresenting {

    weak var controller: VersionDetailsViewControlling?

    func showState(_ state: VersionDetailsViewModel.State) {

    }
}
