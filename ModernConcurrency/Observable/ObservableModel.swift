//
//  ObservableModel.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI

@Observable
@MainActor
final class ObservableModel {
    var currentValue: ChannelMessage?

    private var messages = ChannelMessage.allCases

    func sendMessage() {
        guard !messages.isEmpty else {
            return
        }

        currentValue = messages.removeFirst()
    }
}
