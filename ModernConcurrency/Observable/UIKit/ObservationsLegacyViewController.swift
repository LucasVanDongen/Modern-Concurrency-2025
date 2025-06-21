//
//  ObservationsLegacyViewController.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//

import Observation
import ObservationSequence
import UIKit

class ObservationsLegacyViewController: UIViewController {
    private var model = ObservableViewModel()
    private var messageLabel1: UITextField!
    private var messageLabel2: UITextField!
    private var messageLabel3: UITextField!
    private var nextButton: UIButton!

    override func loadView() {
        // Create and configure the message label
        messageLabel1 = UITextField(frame: CGRect(x: 50, y: 120, width: 200, height: 30))
        messageLabel1.backgroundColor = .clear
        messageLabel1.text = model.text
        messageLabel1.textAlignment = .center

        messageLabel2 = UITextField(frame: CGRect(x: 50, y: 120, width: 200, height: 30))
        messageLabel2.backgroundColor = .clear
        messageLabel2.text = model.text
        messageLabel2.textAlignment = .center

        messageLabel3 = UITextField(frame: CGRect(x: 50, y: 120, width: 200, height: 30))
        messageLabel3.backgroundColor = .clear
        messageLabel3.text = model.text
        messageLabel3.textAlignment = .center

        // Create and configure the button
        nextButton = UIButton(primaryAction: UIAction(title: "Next Message") { [unowned self] _ in
            self.nextMessageButtonClicked()
        })

        let view = UIStackView(arrangedSubviews: [
            messageLabel1,
            messageLabel2,
            messageLabel3,
            nextButton
        ])

        view.axis = .vertical

        // Add constraints
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 120)
        ])

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0475-observed.md
        // https://github.com/phausler/ObservationSequence/
        let names = Observations {
            self.model.text
        }

        Task.detached {
            for await name in names {
                Task { @MainActor in
                    self.messageLabel1.text = name
                }
            }
        }

        Task.detached {
            for await name in names._throttle(for: .seconds(0.3)) {
                Task { @MainActor in
                    self.messageLabel2.text = name
                }
            }
        }

        Task.detached {
            for await name in names.debounce(for: .seconds(0.3)) {
                Task { @MainActor in
                    self.messageLabel3.text = name
                }
            }
        }
    }

    @objc
    private func nextMessageButtonClicked() {
        model.sendMessage()
    }
}

