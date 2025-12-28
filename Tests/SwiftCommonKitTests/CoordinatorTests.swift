//
//  CoordinatorTests.swift
//  SwiftCommonKitTests
//
//  Created by Lens Team on 28.12.2025.
//

import Testing
@testable import SwiftCommonKit

/// Tests for the Coordinator pattern implementation.
@MainActor
struct CoordinatorTests {
    
    // MARK: - Test Helpers
    
    /// Mock coordinator for testing.
    final class MockCoordinator: BaseCoordinator {
        var startCallCount = 0
        var finishCallCount = 0
        
        override func start() {
            startCallCount += 1
        }
        
        override func finish() {
            finishCallCount += 1
            super.finish()
        }
    }
    
    // MARK: - Initialization Tests
    
    @Test("Coordinator initializes with empty state")
    func test_initialization_hasEmptyState() {
        let coordinator = MockCoordinator()
        
        #expect(coordinator.childCoordinators.isEmpty)
        #expect(coordinator.parentCoordinator == nil)
        #expect(coordinator.startCallCount == 0)
    }
    
    // MARK: - Child Management Tests
    
    @Test("Adding child coordinator sets parent reference")
    func test_addChild_setsParentReference() {
        let parent = MockCoordinator()
        let child = MockCoordinator()
        
        parent.addChild(child)
        
        #expect(parent.childCoordinators.count == 1)
        #expect(child.parentCoordinator === parent)
    }
    
    @Test("Adding same child twice is idempotent")
    func test_addChild_addingSameChildTwice_doesNotDuplicate() {
        let parent = MockCoordinator()
        let child = MockCoordinator()
        
        parent.addChild(child)
        parent.addChild(child)
        
        #expect(parent.childCoordinators.count == 1)
    }
    
    @Test("Adding multiple children works correctly")
    func test_addChild_multipleChildren_allAdded() {
        let parent = MockCoordinator()
        let child1 = MockCoordinator()
        let child2 = MockCoordinator()
        let child3 = MockCoordinator()
        
        parent.addChild(child1)
        parent.addChild(child2)
        parent.addChild(child3)
        
        #expect(parent.childCoordinators.count == 3)
        #expect(child1.parentCoordinator === parent)
        #expect(child2.parentCoordinator === parent)
        #expect(child3.parentCoordinator === parent)
    }
    
    @Test("Removing child coordinator works correctly")
    func test_removeChild_removesFromChildren() {
        let parent = MockCoordinator()
        let child = MockCoordinator()
        
        parent.addChild(child)
        parent.removeChild(child)
        
        #expect(parent.childCoordinators.isEmpty)
    }
    
    @Test("Removing non-existent child is safe")
    func test_removeChild_nonExistentChild_doesNotCrash() {
        let parent = MockCoordinator()
        let child = MockCoordinator()
        
        // Should not crash
        parent.removeChild(child)
        #expect(parent.childCoordinators.isEmpty)
    }
    
    @Test("Removing specific child from multiple children")
    func test_removeChild_specificChild_onlyRemovesThatChild() {
        let parent = MockCoordinator()
        let child1 = MockCoordinator()
        let child2 = MockCoordinator()
        let child3 = MockCoordinator()
        
        parent.addChild(child1)
        parent.addChild(child2)
        parent.addChild(child3)
        
        parent.removeChild(child2)
        
        #expect(parent.childCoordinators.count == 2)
        #expect(parent.childCoordinators.contains { $0 === child1 })
        #expect(parent.childCoordinators.contains { $0 === child3 })
        #expect(!parent.childCoordinators.contains { $0 === child2 })
    }
    
    @Test("Remove all children clears all coordinators")
    func test_removeAllChildren_clearsAllChildren() {
        let parent = MockCoordinator()
        let child1 = MockCoordinator()
        let child2 = MockCoordinator()
        
        parent.addChild(child1)
        parent.addChild(child2)
        
        parent.removeAllChildren()
        
        #expect(parent.childCoordinators.isEmpty)
    }
    
    // MARK: - Lifecycle Tests
    
    @Test("Start method is called correctly")
    func test_start_callsStartMethod() {
        let coordinator = MockCoordinator()
        
        coordinator.start()
        
        #expect(coordinator.startCallCount == 1)
    }
    
    @Test("Finish removes from parent and clears children")
    func test_finish_removesFromParentAndClearsChildren() {
        let parent = MockCoordinator()
        let child = MockCoordinator()
        let grandchild = MockCoordinator()
        
        parent.addChild(child)
        child.addChild(grandchild)
        
        child.finish()
        
        #expect(parent.childCoordinators.isEmpty)
        #expect(child.childCoordinators.isEmpty)
        #expect(child.finishCallCount == 1)
    }
    
    // MARK: - Memory Management Tests
    
    @Test("Child coordinators can be deallocated")
    func test_memoryManagement_childCanBeDeallocated() {
        let parent = MockCoordinator()
        var child: MockCoordinator? = MockCoordinator()
        
        parent.addChild(child!)
        weak var weakChild = child
        
        parent.removeChild(child!)
        child = nil
        
        #expect(weakChild == nil)
    }
    
    @Test("Parent reference is weak and doesn't cause retain cycle")
    func test_memoryManagement_parentReferenceIsWeak() {
        var parent: MockCoordinator? = MockCoordinator()
        let child = MockCoordinator()
        
        parent!.addChild(child)
        weak var weakParent = parent
        
        parent = nil
        
        #expect(weakParent == nil)
        #expect(child.parentCoordinator == nil)
    }
    
    // MARK: - Navigation Flow Tests
    
    @Test("Complex navigation hierarchy works correctly")
    func test_navigationFlow_complexHierarchy() {
        let root = MockCoordinator()
        let onboarding = MockCoordinator()
        let main = MockCoordinator()
        let settings = MockCoordinator()
        
        root.addChild(onboarding)
        onboarding.start()
        
        #expect(root.childCoordinators.count == 1)
        #expect(onboarding.startCallCount == 1)
        
        onboarding.finish()
        root.addChild(main)
        main.start()
        
        #expect(root.childCoordinators.count == 1)
        #expect(root.childCoordinators.first === main)
        
        main.addChild(settings)
        settings.start()
        
        #expect(main.childCoordinators.count == 1)
        #expect(settings.startCallCount == 1)
        
        settings.finish()
        
        #expect(main.childCoordinators.isEmpty)
    }
}
