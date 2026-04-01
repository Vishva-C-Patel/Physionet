//
//  LabeledTextField.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class PhysioLabeledTextField: UIView {

    let textField = UITextField()

    // Public API used by the view
    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        build(title: title, placeholder: placeholder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(title: String, placeholder: String) {
        translatesAutoresizingMaskIntoConstraints = false

        // Text field styling
        textField.placeholder = title.isEmpty ? placeholder : "\(title) • \(placeholder)"
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.clearButtonMode = .whileEditing
        textField.layer.cornerRadius = 14
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        // Add left padding
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 54))
        textField.leftViewMode = .always
        
        // Add right padding for clear button
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 54))
        textField.rightViewMode = .unlessEditing

        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Helpers
extension PhysioLabeledTextField {
    /// Assigns a custom input view (e.g., UIPickerView) and adds a toolbar with Done/Cancel.
    func setInputView(_ inputView: UIView, toolbarTitle: String? = nil) {
        textField.inputView = inputView

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let titleItem: UIBarButtonItem
        if let toolbarTitle = toolbarTitle, !toolbarTitle.isEmpty {
            let titleLabel = UILabel()
            titleLabel.text = toolbarTitle
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            titleLabel.textAlignment = .center
            titleLabel.textColor = .secondaryLabel
            titleLabel.sizeToFit()
            titleItem = UIBarButtonItem(customView: titleLabel)
        } else {
            titleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([cancel, flexible, titleItem, flexible, done], animated: false)

        textField.inputAccessoryView = toolbar

        // Prevent keyboard caret if using picker
        if inputView is UIPickerView {
            textField.tintColor = .clear
        } else {
            textField.tintColor = nil
        }
    }

    @objc private func cancelTapped() {
        textField.resignFirstResponder()
    }

    @objc private func doneTapped() {
        textField.resignFirstResponder()
    }
}
