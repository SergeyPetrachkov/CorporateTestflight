import CorporateTestflightDomain

extension VersionDetailsViewModel {

    enum State: Equatable {

        // MARK: - Nested VMs

        struct ErrorViewModel: Equatable {
            let message: String
        }

        // MARK: - Cases

        case loading(VersionDetailsLoadingView.State)
        case loaded(VersionDetailsLoadedView.State)
        case failed(ErrorViewModel)
    }
}
