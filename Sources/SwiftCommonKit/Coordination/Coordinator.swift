//
//  Coordinator.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation
import SwiftUI

/// A coordinator protocol that manages navigation flows and child coordinators.
///
/// Coordinators follow the Coordinator pattern to separate navigation logic from view controllers/views.
/// This protocol is marked as `@MainActor` to ensure all navigation operations happen on the main thread,
/// following Swift 6 concurrency best practices.
///
/// ## Usage
/// ```swift
/// @MainActor
/// final class AppCoordinator: Coordinator {
///     weak var parentCoordinator: Coordinator?
///     var childCoordinators: [Coordinator] = []
///     var navigationController: UINavigationController
///
///     func start() {
///         // Configure initial navigation
///     }
/// }
/// ```
@MainActor
public protocol Coordinator: AnyObject {
    /// The parent coordinator that owns this coordinator.
    /// This should be weak to avoid retain cycles.
    var parentCoordinator: (any Coordinator)? { get set }
    
    /// Child coordinators managed by this coordinator.
    /// When a child's flow completes, remove it from this array.
    var childCoordinators: [any Coordinator] { get set }
    
    /// Starts the coordinator's flow.
    /// This method should set up the initial state and present the first screen.
    func start()
    
    /// Adds a child coordinator to manage its lifecycle.
    /// - Parameter coordinator: The child coordinator to add.
    func addChild(_ coordinator: any Coordinator)
    
    /// Removes a child coordinator from the hierarchy.
    /// Call this when a child coordinator's flow has completed.
    /// - Parameter coordinator: The child coordinator to remove.
    func removeChild(_ coordinator: any Coordinator)
    
    /// Removes all child coordinators.
    /// Useful when cleaning up or resetting the navigation flow.
    func removeAllChildren()
}

/// Default implementations for coordinator child management.
public extension Coordinator {
    /// Adds a child coordinator and sets its parent reference.
    /// - Parameter coordinator: The child coordinator to add.
    func addChild(_ coordinator: any Coordinator) {
        guard !childCoordinators.contains(where: { $0 === coordinator }) else {
            return
        }
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    /// Removes a child coordinator by identity comparison.
    /// - Parameter coordinator: The child coordinator to remove.
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    /// Removes all child coordinators.
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
