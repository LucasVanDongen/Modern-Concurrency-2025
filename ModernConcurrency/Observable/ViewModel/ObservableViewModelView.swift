//
//  ObservableViewModelView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI

struct ObservableViewModelView: View {
    @State var viewModel = ObservableViewModel()

    var body: some View {
        Text(viewModel.text)
        Button("Next Message") {
            viewModel.sendMessage()
        }
    }
}
