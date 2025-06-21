//
//  ObservableLegacyViewControllerWrapper.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI
import UIKit

// SwiftUI wrapper for ObservableLegacyViewController
struct ObservableLegacyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ObservableLegacyViewController {
        return ObservableLegacyViewController()
    }

    func updateUIViewController(_ uiViewController: ObservableLegacyViewController, context: Context) {
        // Updates from SwiftUI to the view controller can be handled here if needed
    }
}

// Convenience extension to make it easier to use the wrapper
extension ObservableLegacyViewController {
    static var asSwiftUIView: some View {
        ObservableLegacyViewControllerWrapper()
            .frame(width: 300, height: 200)
    }
}
