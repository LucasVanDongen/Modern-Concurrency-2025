//
//  TestActor.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 20/06/2025.
//

@globalActor actor TestActor: GlobalActor {
    static let shared = TestActor()
}
