//
//  SafeContinuationView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

import SwiftUI

@MainActor
struct SafeContinuationView: View {
    @StateObject var viewModel = SafeContinuationViewModel()

    var body: some View {
        VStack {
            Text("Safe Continuation, \(viewModel.currentMessage)")
            Button("Double Message (will log error for second resume)") {
                Task {
                    await viewModel.pressButton()
                }
            }
        }
    }
}
