public protocol ViewModelLifeCycle {
    @MainActor
    func start()
    @MainActor
    func stop()
}
