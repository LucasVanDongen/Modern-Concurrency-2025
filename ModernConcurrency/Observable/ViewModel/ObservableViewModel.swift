//
//  ObservableViewModel.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import ObservationSequence
import SwiftUI

@Observable
@MainActor
class ObservableViewModel {
    var text: String {
        model.currentValue?.rawValue ?? "No Value"
    }

    let observedText: Observations<ChannelMessage?, Never>

    // @ObservationIgnored
    private let model = ObservableModel()

    init() {
        let model = model
        observedText = Observations { model.currentValue }
    }

    func sendMessage() {
        model.sendMessage()
    }
}
