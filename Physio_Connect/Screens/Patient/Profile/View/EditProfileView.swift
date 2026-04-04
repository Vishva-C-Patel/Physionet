//
//  EditProfileView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class EditProfileView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let nameField = LabeledTextField(title: "Full Name", placeholder: "Your name")
    private let phoneField = LabeledTextField(title: "Phone", placeholder: "Phone number")
    private let genderField = LabeledTextField(title: "Gender", placeholder: "Gender")
    private let customGenderField = LabeledTextField(title: "Custom Gender", placeholder: "Your gender")
    private let dobField = LabeledTextField(title: "Date of Birth", placeholder: "YYYY-MM-DD")
    private let addressLine1Field = LabeledTextField(title: "Address Line 1", placeholder: "House No, Street")
    private let addressLine2Field = LabeledTextField(title: "Address Line 2", placeholder: "Locality, City")
    private let pincodeField = LabeledTextField(title: "Pincode", placeholder: "Pincode")
    private let dobPicker = UIDatePicker()
    private let genderPicker = UIPickerView()
    private let genderOptions = ["Male", "Female", "Other"]
    private var selectedGenderIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ data: ProfileViewData) {
        nameField.text = data.name == "—" ? "" : data.name
        phoneField.text = data.phone == "—" ? "" : data.phone
        let genderText = data.gender == "—" ? "" : data.gender
        applyGenderText(genderText)
        dobField.text = data.dateOfBirth == "—" ? "" : data.dateOfBirth
        
        let loc = data.location == "—" ? "" : data.location
        var parts = loc.components(separatedBy: ", ")
        if parts.count >= 3 {
            pincodeField.text = parts.popLast() ?? ""
            addressLine2Field.text = parts.popLast() ?? ""
            addressLine1Field.text = parts.joined(separator: ", ")
        } else if parts.count == 2 {
            pincodeField.text = parts.popLast() ?? ""
            addressLine1Field.text = parts.popLast() ?? ""
            addressLine2Field.text = ""
        } else {
            addressLine1Field.text = loc
            addressLine2Field.text = ""
            pincodeField.text = ""
        }
        
        if let parsed = Self.dateFormatter.date(from: dobField.text) {
            dobPicker.date = parsed
        }
    }


    func currentInput() -> ProfileModel.ProfileUpdateInput {
        let resolvedGender: String = {
            let selection = genderField.text
            if selection == "Other" {
                return customGenderField.text
            }
            return selection
        }()
        let line1 = addressLine1Field.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let line2 = addressLine2Field.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pin = pincodeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let combinedLocation = [line1, line2, pin].filter { !$0.isEmpty }.joined(separator: ", ")

        return ProfileModel.ProfileUpdateInput(
            name: nameField.text,
            phone: phoneField.text,
            gender: resolvedGender,
            dateOfBirth: dobField.text,
            location: combinedLocation
        )
    }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceVertical = true

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        buildForm()
    }


    private func buildForm() {
        let card = makeCardView()
        let formStack = UIStackView()
        formStack.axis = .vertical
        formStack.spacing = 12
        formStack.translatesAutoresizingMaskIntoConstraints = false

        phoneField.keyboardType = .phonePad
        dobField.keyboardType = .numbersAndPunctuation

        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderField.setInputView(genderPicker, toolbarTitle: "Select Gender")
        customGenderField.isHidden = true

        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .wheels
        dobPicker.maximumDate = Date()
        dobPicker.addTarget(self, action: #selector(dobChanged), for: .valueChanged)
        dobField.setInputView(dobPicker, toolbarTitle: "Select Date")

        formStack.addArrangedSubview(nameField)
        formStack.addArrangedSubview(phoneField)
        formStack.addArrangedSubview(genderField)
        formStack.addArrangedSubview(customGenderField)
        formStack.addArrangedSubview(dobField)
        formStack.addArrangedSubview(addressLine1Field)
        formStack.addArrangedSubview(addressLine2Field)
        formStack.addArrangedSubview(pincodeField)

        card.addSubview(formStack)

        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            formStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            formStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            formStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(card)
    }

    private func makeCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = UITheme.Colors.surface
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }


    @objc private func dobChanged() {
        dobField.text = Self.dateFormatter.string(from: dobPicker.date)
    }

    private func applyGenderText(_ text: String) {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty {
            genderField.text = ""
            customGenderField.text = ""
            customGenderField.isHidden = true
            return
        }
        if let index = genderOptions.firstIndex(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) {
            selectedGenderIndex = index
            genderPicker.selectRow(index, inComponent: 0, animated: false)
            genderField.text = genderOptions[index]
            customGenderField.text = ""
            customGenderField.isHidden = genderOptions[index] != "Other"
        } else {
            selectedGenderIndex = genderOptions.count - 1
            genderPicker.selectRow(selectedGenderIndex, inComponent: 0, animated: false)
            genderField.text = "Other"
            customGenderField.text = normalized
            customGenderField.isHidden = false
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        genderOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        genderOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGenderIndex = row
        let selected = genderOptions[row]
        genderField.text = selected
        if selected == "Other" {
            customGenderField.isHidden = false
        } else {
            customGenderField.isHidden = true
            customGenderField.text = ""
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private final class LabeledTextField: UIView {
    private let titleLabel = UILabel()
    private let textField = UITextField()

    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    func setInputView(_ view: UIView, toolbarTitle: String) {
        textField.inputView = view
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let title = UIBarButtonItem(title: toolbarTitle, style: .plain, target: nil, action: nil)
        title.isEnabled = false
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([title, flex, done], animated: false)
        textField.inputAccessoryView = toolbar
    }

    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .label
        textField.backgroundColor = .tertiarySystemFill
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(12)
        textField.setRightPadding(12)
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func doneTapped() {
        textField.resignFirstResponder()
    }
}

private extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        rightView = paddingView
        rightViewMode = .always
    }
}
