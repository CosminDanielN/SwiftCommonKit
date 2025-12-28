//
//  DataActor.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// A global actor for performing data operations off the main thread.
@globalActor
public actor DataActor {
    public static let shared = DataActor()
    
    private init() {}
}
