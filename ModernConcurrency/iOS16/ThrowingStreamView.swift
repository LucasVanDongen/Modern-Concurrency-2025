//
//  ThrowingStreamView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 17/07/2025.
//

import SwiftUI

@MainActor
struct ThrowingStreamView: View {
    @State var viewModel = ThrowingStreamViewModel()

    var body: some View {
        VStack {
            Text("Throwing Stream: \(viewModel.currentMessage)")
            Button("Double Message - Second Message Accepted Too") {
                Task {
                    try await viewModel.buttonPressed()
                }
            }
        }
    }
}
