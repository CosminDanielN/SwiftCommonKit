//
//  BaseCoordinator.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation
import SwiftUI

/// A base coordinator implementation providing common functionality.
///
/// This class provides a concrete implementation of the `Coordinator` protocol
/// with sensible defaults for child coordinator management and navigation.
///
/// Subclass this to create specific coordinators for your application flows:
/// ```swift
/// @MainActor
/// final class OnboardingCoordinator: BaseCoordinator {
///     override func start() {
///         // Present onboarding flow
///     }
/// }
/// ```
@MainActor
open class BaseCoordinator: Coordinator {
    /// The parent coordinator that owns this coordinator.
    /// Weak reference to prevent retain cycles.
    public weak var parentCoordinator: (any Coordinator)?
    
    /// Child coordinators managed by this coordinator.
    public var childCoordinators: [any Coordinator] = []
    
    /// Creates a new base coordinator instance.
    public init() {}
    
    /// Starts the coordinator's flow.
    /// Override this method in subclasses to implement specific navigation logic.
    open func start() {
        // Override in subclasses
    }
    
    /// Cleans up the coordinator and its children.
    /// Call this when the coordinator's flow is complete.
    public func finish() {
        removeAllChildren()
        parentCoordinator?.removeChild(self)
    }
}
