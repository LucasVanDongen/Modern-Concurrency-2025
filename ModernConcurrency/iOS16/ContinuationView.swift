//
//  ContinuationView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

import SwiftUI

@MainActor
struct ContinuationView: View {
    @StateObject var viewModel = ContinuationViewModel()

    var body: some View {
        VStack {
            Text("Unsafe Continuation, \(viewModel.currentMessage)")
            Button("Double Message (will crash on second resume 🧨)") {
                Task {
                    try await viewModel.sendMessage()
                }
            }
        }
    }
}
