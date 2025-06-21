// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@MainActor
public struct DefaultContentView: View {
    @State private var model = Model()
    @State private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        Text("Model value: \(model.text)")
        Button(action: model.tap) {
            Text("Tap Model")
        }
        Text("ViewModel value: \(viewModel.text)")
        Button(action: viewModel.tap) {
            Text("Tap ViewModel")
        }
    }
}

@Observable
class Model {
    var text = "Waiting"
    private var messages = ChannelMessage.allCases


    func tap() {
        guard
            !messages.isEmpty
        else {
            text = "Ended"
            return
        }

        let newText = messages.removeFirst()

        text = newText.rawValue
    }
}

@Observable
class ViewModel {
    private var model = Model()

    var text: String {
        model.text
    }


    func tap() {
        model.tap()
    }
}

enum ChannelMessage: String, CaseIterable {
    case one, two, three
}
