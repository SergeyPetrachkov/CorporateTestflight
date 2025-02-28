public protocol Resolver {
	/// Retrieves the instance with the specified service type.
	///
	/// - Parameter serviceType: The service type to resolve.
	///
	/// - Returns: The resolved service type instance, or nil if no service is found.
	func resolve<Service>(_ serviceType: Service.Type) -> Service?

	/// Retrieves the instance with the specified service type and 1 argument to the factory closure.
	///
	/// - Parameters:
	///   - serviceType: The service type to resolve.
	///   - argument:   1 argument to pass to the factory closure.
	///
	/// - Returns: The resolved service type instance, or nil if no registration for the service type
	///            and 1 argument is found.
	func resolve<Service, Arg1>(
		_ serviceType: Service.Type,
		argument: Arg1
	) -> Service?
}
