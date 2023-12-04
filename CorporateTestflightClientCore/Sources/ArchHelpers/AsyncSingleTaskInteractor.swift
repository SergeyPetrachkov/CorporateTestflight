public protocol AsyncSingleTaskInteractor: AnyObject {
    var currentTask: Task<Void, Never>? { get }
}

public extension AsyncSingleTaskInteractor where Self: ViewControllerLifeCycleBoundInteractor {
    func viewWillUnload() {
        currentTask?.cancel()
    }
}
