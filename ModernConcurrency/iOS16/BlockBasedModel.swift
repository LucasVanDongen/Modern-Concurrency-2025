//
//  BlockBasedModel.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

class BlockBasedModel {
    func sendMessage(completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("First Message"))
        completion(.success("Second Message")) // This will crash the app, unless it's properly handled
    }
}
