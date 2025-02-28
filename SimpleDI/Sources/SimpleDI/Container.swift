import Foundation

/// A simple dependency injection container that allows for the registration and resolution of services.
public final class Container: Resolver {

	/// A dictionary to store factory closures for creating instances of registered services.
	private var factories = [String: (Any) -> Any]()

	/// A concurrent dispatch queue to ensure thread-safe access to the factories dictionary.
	private let queue = DispatchQueue(label: "com.simpledi.container.queue", attributes: .concurrent)

	/// Initializes a new instance of the `Container` class.
	public init() {}

	/// Registers a factory closure for creating instances of the specified type.
	///
	/// - Parameters:
	///   - type: The type of the service to register.
	///   - factory: A closure that takes an argument of type `Arg` and returns an instance of the service.
	public func register<T, Arg>(_ type: T.Type, factory: @escaping (Arg) -> T) {
		let key = String(describing: type)
		queue.async(flags: .barrier) {
			self.factories[key] = { arg in
				guard let arg = arg as? Arg else {
					fatalError("Invalid argument type")
				}
				return factory(arg)
			}
		}
	}

	/// Resolves an instance of the specified service type, using the provided argument.
	///
	/// - Parameters:
	///   - serviceType: The type of the service to resolve.
	///   - argument: An argument of type `Arg1` to pass to the factory closure.
	/// - Returns: An instance of the service, or `nil` if no factory is registered for the specified type.
	public func resolve<Service, Arg1>(_ serviceType: Service.Type, argument: Arg1) -> Service? {
		let key = String(describing: serviceType)
		return queue.sync {
			return factories[key]?(argument) as? Service
		}
	}

	/// Resolves an instance of the specified service type, without any arguments.
	///
	/// - Parameter serviceType: The type of the service to resolve.
	/// - Returns: An instance of the service, or `nil` if no factory is registered for the specified type.
	public func resolve<Service>(_ serviceType: Service.Type) -> Service? {
		resolve(serviceType, argument: ())
	}
}
