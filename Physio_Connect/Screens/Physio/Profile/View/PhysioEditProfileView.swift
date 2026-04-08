//
//  PhysioEditProfileView.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit

final class PhysioEditProfileView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    enum ValidationError: LocalizedError {
        case message(String)
        var errorDescription: String? {
            switch self {
            case .message(let text): return text
            }
        }
    }

    // Replaced top bar with native navigation 

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()



    private let nameField = PhysioLabeledTextField(title: "Full Name", placeholder: "User")
    private let phoneField = PhysioLabeledTextField(title: "Phone", placeholder: "Phone number")
    private let genderField = PhysioLabeledTextField(title: "Gender", placeholder: "Gender")
    private let customGenderField = PhysioLabeledTextField(title: "Custom Gender", placeholder: "Enter your gender")
    private let dobField = PhysioLabeledTextField(title: "Date of Birth", placeholder: "YYYY-MM-DD")
    private let addressLine1Field = PhysioLabeledTextField(title: "Address Line 1", placeholder: "Clinic Name, Flat No")
    private let addressLine2Field = PhysioLabeledTextField(title: "Address Line 2", placeholder: "Street, Area, City")
    private let pincodeField = PhysioLabeledTextField(title: "Pincode", placeholder: "Pincode")
    private let placeOfWorkField = PhysioLabeledTextField(title: "Place of Work", placeholder: "Clinic or hospital")
    private let consultationFeeField = PhysioLabeledTextField(title: "Consultation Fee", placeholder: "e.g., 500")
    private let yearsExperienceField = PhysioLabeledTextField(title: "Years of Experience", placeholder: "e.g., 6")
    private let aboutField = PhysioLabeledTextField(title: "About", placeholder: "Short bio")
    private let genderPicker = UIPickerView()
    private let dobPicker = UIDatePicker()
    private let genderOptions = ["male", "female"]
    private var selectedGenderIndex = 0
    private var storedLatitude: String = ""
    private var storedLongitude: String = ""
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(_ data: PhysioProfileModel.EditProfileData) {
        nameField.text = data.name
        
        let loc = data.address
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
        
        phoneField.text = data.phone
        placeOfWorkField.text = data.placeOfWork
        consultationFeeField.text = data.consultationFee
        yearsExperienceField.text = data.yearsExperience
        aboutField.text = data.about
        storedLatitude = data.latitude
        storedLongitude = data.longitude
        applyGenderText(data.gender)
        if !data.dateOfBirth.isEmpty {
            dobField.text = data.dateOfBirth
            if let date = Self.dateFormatter.date(from: data.dateOfBirth) {
                dobPicker.date = date
            }
        } else {
            dobField.text = ""
        }
    }

    func currentInput() -> PhysioProfileModel.UpdateInput {
        let resolvedGender: String = {
            let selection = genderField.text
            return selection
        }()
        
        let line1 = addressLine1Field.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let line2 = addressLine2Field.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pin = pincodeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let combinedLocation = [line1, line2, pin].filter { !$0.isEmpty }.joined(separator: ", ")

        return PhysioProfileModel.UpdateInput(
            name: nameField.text,
            gender: resolvedGender,
            location: combinedLocation,
            placeOfWork: placeOfWorkField.text,
            phone: phoneField.text,
            dateOfBirth: dobField.text,
            about: aboutField.text,
            yearsExperience: yearsExperienceField.text,
            consultationFee: consultationFeeField.text,
            latitude: storedLatitude,
            longitude: storedLongitude,
            profileImagePath: ""
        )
    }

    func validatedInput() throws -> PhysioProfileModel.UpdateInput {
        let name = nameField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name.count >= 2 else {
            throw ValidationError.message("Full Name must be at least 2 characters.")
        }
        guard name.count <= 80 else {
            throw ValidationError.message("Full Name is too long.")
        }

        let phoneRaw = phoneField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedPhone = try normalizedIndianPhone(phoneRaw)

        let pincode = pincodeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !pincode.isEmpty {
            let pinDigits = pincode.filter { $0.isNumber }
            guard pinDigits.count == 6 else {
                throw ValidationError.message("Pincode must be 6 digits.")
            }
        }

        let dobText = dobField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !dobText.isEmpty {
            guard let dob = Self.dateFormatter.date(from: dobText) else {
                throw ValidationError.message("Date of Birth must be in YYYY-MM-DD format.")
            }
            let age = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
            guard age >= 18 else {
                throw ValidationError.message("Physiotherapist must be at least 18 years old.")
            }
        }

        let feeText = consultationFeeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !feeText.isEmpty {
            guard let fee = Double(feeText), fee >= 0, fee <= 100000 else {
                throw ValidationError.message("Consultation Fee must be a valid amount between 0 and 100000.")
            }
        }

        let expText = yearsExperienceField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !expText.isEmpty {
            guard let exp = Int(expText), exp >= 0, exp <= 70 else {
                throw ValidationError.message("Years of Experience must be a whole number between 0 and 70.")
            }
        }

        let about = aboutField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !about.isEmpty, about.count > 500 {
            throw ValidationError.message("About section cannot exceed 500 characters.")
        }

        var input = currentInput()
        input = PhysioProfileModel.UpdateInput(
            name: name,
            gender: input.gender,
            location: input.location,
            placeOfWork: input.placeOfWork.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: normalizedPhone ?? "",
            dateOfBirth: dobText,
            about: about,
            yearsExperience: expText,
            consultationFee: feeText,
            latitude: input.latitude,
            longitude: input.longitude,
            profileImagePath: input.profileImagePath
        )
        return input
    }

    func setSaving(_ saving: Bool) {
        // Saving state handled by view controller's navigation item
    }

    func setCoordinates(latitude: Double, longitude: Double) {
        storedLatitude = String(format: "%.6f", latitude)
        storedLongitude = String(format: "%.6f", longitude)
    }

    func setLocationText(_ text: String) {
        addressLine1Field.text = text
        addressLine2Field.text = ""
        pincodeField.text = ""
    }

    func hasCoordinates() -> Bool {
        !storedLatitude.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !storedLongitude.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func currentAddress() -> String {
        let line1 = addressLine1Field.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let line2 = addressLine2Field.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pin = pincodeField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return [line1, line2, pin].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    private func build() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .always
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
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
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        buildForm()
    }

    private func buildForm() {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let formStack = UIStackView()
        formStack.axis = .vertical
        formStack.spacing = 14
        formStack.translatesAutoresizingMaskIntoConstraints = false

        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderField.setInputView(genderPicker, toolbarTitle: "Select Gender")
        customGenderField.isHidden = true
        phoneField.textField.keyboardType = .phonePad
        phoneField.textField.textContentType = .telephoneNumber
        consultationFeeField.textField.keyboardType = .decimalPad
        consultationFeeField.textField.textContentType = .none
        yearsExperienceField.textField.keyboardType = .numberPad
        yearsExperienceField.textField.textContentType = .none
        dobField.textField.keyboardType = .numbersAndPunctuation
        nameField.textField.textContentType = .name
        nameField.textField.autocapitalizationType = .words
        placeOfWorkField.textField.textContentType = .organizationName
        placeOfWorkField.textField.autocapitalizationType = .words
        addressLine1Field.textField.textContentType = .fullStreetAddress
        addressLine1Field.textField.autocapitalizationType = .words
        addressLine2Field.textField.autocapitalizationType = .words
        pincodeField.textField.keyboardType = .numberPad
        pincodeField.textField.textContentType = .postalCode
        aboutField.textField.autocapitalizationType = .sentences
        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .wheels
        dobPicker.maximumDate = Date()
        dobPicker.addTarget(self, action: #selector(dobChanged), for: .valueChanged)
        dobField.setInputView(dobPicker, toolbarTitle: "Select Date")

        formStack.addArrangedSubview(nameField)
        formStack.addArrangedSubview(phoneField)
        formStack.addArrangedSubview(placeOfWorkField)
        formStack.addArrangedSubview(genderField)
        formStack.addArrangedSubview(dobField)
        formStack.addArrangedSubview(addressLine1Field)
        formStack.addArrangedSubview(addressLine2Field)
        formStack.addArrangedSubview(pincodeField)
        formStack.addArrangedSubview(consultationFeeField)
        formStack.addArrangedSubview(yearsExperienceField)
        formStack.addArrangedSubview(aboutField)

        card.addSubview(formStack)

        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            formStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            formStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            formStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        stackView.addArrangedSubview(card)
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
            customGenderField.isHidden = true
        } else {
            selectedGenderIndex = genderOptions.count - 1
            genderPicker.selectRow(selectedGenderIndex, inComponent: 0, animated: false)
            genderField.text = genderOptions[selectedGenderIndex]
            customGenderField.text = ""
            customGenderField.isHidden = true
        }
    }

    // MARK: - Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { genderOptions.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { genderOptions[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genderOptions[row]
        selectedGenderIndex = row
        customGenderField.isHidden = true
        customGenderField.text = ""
    }

    private func normalizedIndianPhone(_ raw: String) throws -> String? {
        guard !raw.isEmpty else { return nil }
        let digits = raw.filter { $0.isNumber }
        let tenDigits: String
        if digits.count > 10, digits.hasPrefix("91") {
            tenDigits = String(digits.suffix(10))
        } else {
            tenDigits = digits
        }
        guard tenDigits.count == 10 else {
            throw ValidationError.message("Phone number must be 10 digits.")
        }
        return "+91\(tenDigits)"
    }
}
