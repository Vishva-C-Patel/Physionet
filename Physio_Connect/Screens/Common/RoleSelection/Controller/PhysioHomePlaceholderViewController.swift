//
//  PhysioHomePlaceholderViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

final class PhysioHomePlaceholderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Physio Dashboard"
        view.backgroundColor = UIColor(hex: "E3F0FF")

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.text = "Physiotherapist side is next.\nDesign screens → then we build the Tab Bar."

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}

