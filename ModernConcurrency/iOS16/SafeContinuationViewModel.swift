//
//
//  SafeContinuationViewModel.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

import Combine

class PrintLogger: Logging {
    func log(_ message: String) {
        print(message)
    }
}

@MainActor
class SafeContinuationViewModel: ObservableObject {
    private let model = BlockBasedModel()

    @Published private(set) var currentMessage = "No Message"

    func pressButton() async {
        Task {
            currentMessage = try await sendMessage()
        }
    }

    func sendMessage() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            var safeContinuation: SafeContinuation<String, any Error> = SafeContinuation(
                checkedContinuation: continuation,
                logging: PrintLogger()
            )

            model.sendMessage { result in
                safeContinuation.resume(with: result)
            }
        }
    }
}
