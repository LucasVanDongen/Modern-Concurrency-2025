//
//  ObservableView.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI

struct ObservableView: View {
    @State var model = ObservableModel()

    var body: some View {
        Text(model.currentValue?.rawValue ?? "No Message")
        Button("Next Message") {
            model.sendMessage()
        }
    }
}
