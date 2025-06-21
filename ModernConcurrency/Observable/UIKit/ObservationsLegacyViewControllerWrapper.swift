//
//  ObservationsLegacyViewControllerWrapper.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import SwiftUI
import UIKit

// SwiftUI wrapper for ObservableLegacyViewController
struct ObservationsLegacyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ObservationsLegacyViewController {
        return ObservationsLegacyViewController()
    }

    func updateUIViewController(_ uiViewController: ObservationsLegacyViewController, context: Context) {
        // Updates from SwiftUI to the view controller can be handled here if needed
    }
}
