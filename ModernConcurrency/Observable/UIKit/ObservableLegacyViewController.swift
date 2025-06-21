//
//  ObservableLegacyViewController.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import Observation
import UIKit

class ObservableLegacyViewController: UIViewController {
    private var model = ObservableViewModel()
    private var messageLabel: UITextField!
    private var nextButton: UIButton!

    override func loadView() {
        // Create and configure the message label
        messageLabel = UITextField(frame: CGRect(x: 50, y: 120, width: 200, height: 30))
        messageLabel.backgroundColor = .clear
        messageLabel.text = model.text
        messageLabel.textAlignment = .center

        // Create and configure the button
        nextButton = UIButton(primaryAction: UIAction(title: "Next Message") { [unowned self] _ in
            self.nextMessageButtonClicked()
        })

        let view = UIStackView(arrangedSubviews: [
            messageLabel,
            nextButton
        ])

        view.axis = .vertical

        // Add constraints
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        self.view = view
    }

    override func updateProperties() {
        // Another point to update values, slightly more efficient than `viewWillLayoutSubviews`
        // Trigger it with `setNeedsUpdateProperties()`

        super.updateProperties()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        messageLabel.text = model.text
    }

    @objc
    private func nextMessageButtonClicked() {
        model.sendMessage()
    }
}

