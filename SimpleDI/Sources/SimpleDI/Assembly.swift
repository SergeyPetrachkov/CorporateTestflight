// Plan:
// This is a package that mimicks Swinject. Assembly, container and GCD implementation in a Swift 5 package. No async-await, no Combine.

public protocol Assembly {
	/// Provide hook for ``Assembler`` to load Services into the provided container
	///
	/// - parameter container: the container provided by the ``Assembler``
	///
	func assemble(container: Container)

	/// Provides a hook to the ``Assembly`` that will be called once the ``Assembler`` has loaded all ``Assembly``
	/// instances into the container.
	///
	/// - parameter resolver: the resolver that can resolve instances from the built container
	///
	func loaded(resolver: Resolver)
}

public extension Assembly {
	func loaded(resolver _: Resolver) {
		// no-op
	}
}
