/// An interface for MockFunc and MockThrowingFunc to define the configuration of `whenCalled` callbacks.
public protocol WhenCalledConfigurable {
	associatedtype Input
	func whenCalled(closure: sending @escaping (Input) -> Void)
}

/// An interface for ThreadSafeMockFunc and ThreadSafeMockThrowingFunc to define the configuration of `whenCalled` callbacks.
/// Since those implementations are actor based, this protocol also has a constraint to be implemented by actors.
public protocol WhenCalledIsolatedConfigurable: Actor {
	associatedtype Input
	func whenCalled(closure: sending @escaping (Input) -> Void)
}
