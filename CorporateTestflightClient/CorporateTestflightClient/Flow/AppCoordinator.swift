//
//  AppCoordinator.swift
//  CorporateTestflightClient
//
//  Created by Sergey Petrachkov on 24.11.2023.
//

import UIKit

@MainActor
final class AppCoordinator {

    private let rootNavigationController: UINavigationController
    private let dependenciesContainer: DependencyContaining

    init(rootNavigationController: UINavigationController, dependenciesContainer: DependencyContaining) {
        self.rootNavigationController = rootNavigationController
        self.dependenciesContainer = dependenciesContainer
    }

    func start() {
        
    }
}
