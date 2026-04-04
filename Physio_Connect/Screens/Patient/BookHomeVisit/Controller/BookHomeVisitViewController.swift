//
//  BookHomeVisitViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 31/12/25.
//

import UIKit

final class BookHomeVisitViewController: UIViewController, UITextFieldDelegate {

    private let bookView = BookHomeVisitView()
    private let physioID: UUID
    private let isReschedule: Bool
    private var specializationForTrigger: String?

    private var physioNameForSummary: String?
    private var slots: [SlotRow] = []
    private var selectedSlot: SlotRow?

    // MARK: - Init
    init(physioID: UUID, isReschedule: Bool = false) {
        self.physioID = physioID
        self.isReschedule = isReschedule
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = bookView }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableTapToDismissKeyboard()

        UITheme.applyNativeNavBar(to: self, title: "Book Home Visit")

        // Actions
        bookView.confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        bookView.calendarButton.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)

        bookView.phoneField.delegate = self

        // Date picker
        bookView.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        bookView.setDate(bookView.datePicker.date)

        // TextView placeholder behaviour
        bookView.instructionsTextView.delegate = self

        // Live summary updates
        bookView.addressField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)

        // Fetch
        fetchPhysioHeader()
        fetchSlots(for: bookView.datePicker.date)

        // Initial summary
        bookView.updateAppointmentSummary(
            doctorName: nil,
            date: bookView.datePicker.date,
            time: nil,
            address: nil
        )
    }

    @objc private func calendarTapped() {
        bookView.toggleDatePickerVisible()
    }

    @objc private func dateChanged() {
        // reset selection
        selectedSlot = nil
        bookView.setDate(bookView.datePicker.date)
        bookView.setSelectedTimeText(nil)

        // update summary
        bookView.updateAppointmentSummary(
            doctorName: physioNameForSummary,
            date: bookView.datePicker.date,
            time: nil,
            address: bookView.addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        fetchSlots(for: bookView.datePicker.date)
    }

    @objc private func addressChanged() {
        bookView.updateAppointmentSummary(
            doctorName: physioNameForSummary,
            date: bookView.datePicker.date,
            time: selectedSlotTimeText(),
            address: bookView.addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    // MARK: - Fetch Doctor (Name/Spec/Rating/Fee)
    private func fetchPhysioHeader() {
        Task {
            do {
                async let p = PhysioService.shared.fetchPhysiotherapist(by: physioID)
                async let specs = PhysioService.shared.fetchSpecializationNames(for: physioID)

                let physio = try await p
                let specNames = (try? await specs) ?? []
                let spec = specNames.first ?? "Physiotherapy specialist"

                let fee = Int(physio.consultation_fee ?? 0)
                let feeText = "₹\(fee)/hr"

                let avg = physio.avg_rating ?? 0
                let count = physio.reviews_count ?? 0
                let ratingText = "⭐️ \(String(format: "%.1f", avg)) | \(count) reviews"

                await MainActor.run {
                    self.physioNameForSummary = physio.name
                    self.specializationForTrigger = spec

                    self.bookView.setPhysio(
                        name: physio.name,
                        spec: spec,
                        rating: ratingText,
                        fee: feeText
                    )

                    self.bookView.updateAppointmentSummary(
                        doctorName: physio.name,
                        date: self.bookView.datePicker.date,
                        time: self.selectedSlotTimeText(),
                        address: self.bookView.addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }

            } catch {
                print("❌ fetchPhysioHeader error:", error)
            }
        }
    }

    // MARK: - Fetch Slots from physio_availability_slots
    private func fetchSlots(for date: Date) {
        Task {
            do {
                let rows = try await PhysioService.shared.fetchAvailableSlots(
                    physioID: physioID,
                    forDayContaining: date
                )

                await MainActor.run {
                    self.slots = rows
                    self.renderSlots()
                }
            } catch {
                print("❌ fetchSlots error:", error)
                await MainActor.run {
                    self.slots = []
                    self.renderSlots()
                }
            }
        }
    }

    private func renderSlots() {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"

        let now = Date()
        let cal = Calendar.current
        if let selected = selectedSlot,
           cal.isDate(selected.start_time, inSameDayAs: now),
           selected.start_time <= now {
            selectedSlot = nil
        }

        let visibleSlots = slots.filter { slot in
            guard cal.isDate(slot.start_time, inSameDayAs: now) else { return true }
            return slot.start_time > now
        }

        let vms: [BookHomeVisitView.SlotVM] = visibleSlots.map {
            .init(id: $0.id, title: fmt.string(from: $0.start_time), isBooked: $0.is_booked)
        }

        bookView.renderSlots(vms, selectedID: selectedSlot?.id) { [weak self] tappedID in
            guard let self else { return }
            guard let slot = self.slots.first(where: { $0.id == tappedID }),
                  slot.is_booked == false else { return }

            self.selectedSlot = slot
            self.bookView.setSelectedTimeText(fmt.string(from: slot.start_time))

            self.bookView.updateAppointmentSummary(
                doctorName: self.physioNameForSummary,
                date: self.bookView.datePicker.date,
                time: fmt.string(from: slot.start_time),
                address: self.bookView.addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            self.renderSlots()
        }
    }

    private func selectedSlotTimeText() -> String? {
        guard let s = selectedSlot else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: s.start_time)
    }
    
    private func finalizeBookingAfterPayment(_ draft: BookingDraft) {
        Task {
            do {
                // MUST have a session now (either already logged in OR logged in during payment flow)
                let session = try await SupabaseManager.shared.client.auth.session
                let userUUID = session.user.id

                try await performBooking(
                    userUUID: userUUID,
                    slotID: draft.slotID,
                    address: draft.address,
                    phone: draft.phone,
                    notes: draft.notes
                )

            } catch {
                await MainActor.run {
                    showAlert("Booking failed", error.localizedDescription)
                }
            }
        }
    }
    
    private func pushPayment(with draft: BookingDraft) {
        let vc = PaymentViewController(draft: draft)

        vc.onPaymentSuccess = { [weak self] in
            guard let self else { return }
            self.finalizeBookingAfterPayment(draft)
        }

        vc.onRequireSignup = { [weak self] in
            guard let self else { return }
            self.pushSignupThenReturnToPayment(draft: draft)
        }

        navigationController?.pushViewController(vc, animated: true)
    }


    private func pushSignupThenReturnToPayment(draft: BookingDraft) {
        // Build the banner values for signup screen if you want:
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"

        let signupDraft = AppointmentDraft(
            dateText: df.string(from: draft.slotStart),
            timeText: tf.string(from: draft.slotStart),
            therapistName: draft.physioName,
            addressText: draft.address
        )

        let model = CreateAccountModel(appointment: signupDraft)
        let vc = CreateAccountViewController(model: model)

        vc.onSignupComplete = { [weak self] in
            guard let self else { return }
            // After signup, go back to payment screen (same draft)
            self.navigationController?.popViewController(animated: true)
        }
        attachLogin(to: vc) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        navigationController?.pushViewController(vc, animated: true)
    }


    private func popToHome() {
        // simplest: return to root
        navigationController?.popToRootViewController(animated: true)
    }

    private func formatTimeForSignup(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df.string(from: date)
    }



    // MARK: - Confirm: if not logged in → go to signup, else book
    @objc private func confirmTapped() {

        guard let slot = selectedSlot else {
            showAlert("Select a time slot", "Please choose an available time slot to proceed.")
            return
        }

        let address = bookView.addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phoneText = bookView.phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phoneNormalized = phoneText.replacingOccurrences(of: " ", with: "")

        let rawNotes = bookView.instructionsTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesIsPlaceholder = (bookView.instructionsTextView.textColor == .lightGray)
        let notes = (notesIsPlaceholder || rawNotes.isEmpty) ? nil : rawNotes

        if address.isEmpty {
            showAlert("Missing address", "Please enter your home address.")
            return
        }
        if phoneNormalized.isEmpty {
            showAlert("Missing phone number", "Please enter a contact number.")
            return
        }
        if !phoneNormalized.hasPrefix("+91") {
            showAlert("Invalid phone number", "Use the +91 prefix followed by 10 digits.")
            return
        }
        let phoneDigits = phoneNormalized.replacingOccurrences(of: "+91", with: "")
        if phoneDigits.count != 10 || phoneDigits.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            showAlert("Invalid phone number", "Enter a valid 10 digit number after +91.")
            return
        }
        let phone = "+91" + phoneDigits

        // Build draft (NO DB write here)
        let draft = BookingDraft(
            physioID: physioID,
            physioName: physioNameForSummary ?? "Physiotherapist",
            slotID: slot.id,
            slotStart: slot.start_time,
            slotEnd: slot.end_time,
            address: address,
            phone: phone,
            notes: notes,
            serviceMode: "home"
        )

        if isReschedule {
            handleReschedule(draft)
        } else {
            pushPayment(with: draft)
        }

    }

    private func handleReschedule(_ draft: BookingDraft) {
        Task {
            do {
                _ = try await SupabaseManager.shared.client.auth.session
                self.finalizeBookingAfterPayment(draft)
            } catch {
                await MainActor.run {
                    self.pushSignupThenBook(draft: draft)
                }
            }
        }
    }

    private func pushSignupThenBook(draft: BookingDraft) {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"

        let signupDraft = AppointmentDraft(
            dateText: df.string(from: draft.slotStart),
            timeText: tf.string(from: draft.slotStart),
            therapistName: draft.physioName,
            addressText: draft.address
        )

        let model = CreateAccountModel(appointment: signupDraft)
        let vc = CreateAccountViewController(model: model)

        vc.onSignupComplete = { [weak self] in
            guard let self else { return }
            self.finalizeBookingAfterPayment(draft)
        }
        attachLogin(to: vc) { [weak self] in
            self?.finalizeBookingAfterPayment(draft)
        }

        navigationController?.pushViewController(vc, animated: true)
    }


    // MARK: - Booking logic
    private func performBooking(
        userUUID: UUID,
        slotID: UUID,
        address: String,
        phone: String,
        notes: String?
    ) async throws {

        struct AppointmentPayload: Encodable {
            let customerID: UUID
            let physioID: UUID
            let slotID: UUID
            let serviceMode: String
            let addressText: String
            let contactPhone: String
            let instructions: String?
            let status: String

            enum CodingKeys: String, CodingKey {
                case customerID = "customer_id"
                case physioID = "physio_id"
                case slotID = "slot_id"
                case serviceMode = "service_mode"
                case addressText = "address_text"
                case contactPhone = "contact_phone"
                case instructions
                case status
            }
        }

        struct AppointmentIDRow: Decodable { let id: UUID }

        let payload = AppointmentPayload(
            customerID: userUUID,
            physioID: physioID,
            slotID: slotID,
            serviceMode: "home",
            addressText: address,
            contactPhone: phone,
            instructions: notes,
            status: "booked"
        )

        // 1) insert appointment
        let inserted: AppointmentIDRow = try await SupabaseManager.shared.client
            .from("appointments")
            .insert(payload)
            .select("id")
            .single()
            .execute()
            .value

        // 2) mark slot booked
        try await PhysioService.shared.markSlotBooked(slotID: slotID)
        ArticleTriggerService.shared.triggerArticles(
            keyword: specializationForTrigger ?? "Physiotherapy",
            source: "appointment",
            userID: userUUID.uuidString,
            context: [
                "event": "booking_completed",
                "appointment_id": inserted.id.uuidString,
                "physio_id": physioID.uuidString,
                "user_id": userUUID.uuidString
            ]
        )

        await MainActor.run {
            let a = UIAlertController(
                title: "Appointment Confirmed ✅",
                message: "Your appointment has been booked successfully.",
                preferredStyle: .alert
            )

            a.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            })

            self.present(a, animated: true)
        }


        // 3) refresh slots
        fetchSlots(for: bookView.datePicker.date)
    }

    // MARK: - Push Signup
    private func pushSignup(with draft: AppointmentDraft, onComplete: @escaping () -> Void) {
        let model = CreateAccountModel(appointment: draft)
        let vc = CreateAccountViewController(model: model)

        vc.onSignupComplete = {
            onComplete()
        }
        attachLogin(to: vc) {
            onComplete()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    private func attachLogin(to signupVC: CreateAccountViewController, onAuthComplete: @escaping () -> Void) {
        signupVC.onLoginTapped = { [weak self] in
            guard let self else { return }
            let loginVC = LoginViewController()
            loginVC.onLoginSuccess = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                onAuthComplete()
            }
            loginVC.onSignupTapped = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            loginVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }

    // MARK: - Retry booking after signup
    private func retryBookingAfterSignup(
        slotID: UUID,
        address: String,
        phone: String,
        notes: String?
    ) {
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let userUUID = session.user.id

                try await self.performBooking(
                    userUUID: userUUID,
                    slotID: slotID,
                    address: address,
                    phone: phone,
                    notes: notes
                )
            } catch {
                await MainActor.run {
                    self.showAlert("Signup required", "Please complete signup/login to confirm booking.")
                }
            }
        }
    }

    private func formatDateForSignup(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df.string(from: date)
    }

    private func showAlert(_ title: String, _ message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UITextView placeholder handling
extension BookHomeVisitViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .darkGray
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let t = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty {
            textView.textColor = .lightGray
            textView.text = "Special instructions (parking, floor, access etc.)"
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField == bookView.phoneField else { return }
        let prefix = "+91 "
        if (textField.text ?? "").isEmpty {
            textField.text = prefix
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == bookView.phoneField else { return }
        let normalized = (textField.text ?? "").replacingOccurrences(of: " ", with: "")
        if normalized == "+91" || normalized.isEmpty {
            textField.text = nil
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == bookView.phoneField else { return true }
        let prefix = "+91 "
        let current = textField.text ?? ""
        let updated = (current as NSString).replacingCharacters(in: range, with: string)

        if updated.isEmpty {
            return true
        }

        var raw = updated.replacingOccurrences(of: "+", with: "")
        raw = raw.replacingOccurrences(of: " ", with: "")
        if raw.hasPrefix("91") {
            raw.removeFirst(2)
        }
        raw = raw.filter { $0.isNumber }
        if raw.count > 10 {
            return false
        }

        let formatted = formatPhoneDigits(raw, prefix: prefix)
        textField.text = formatted
        if let end = textField.endOfDocument as UITextPosition? {
            textField.selectedTextRange = textField.textRange(from: end, to: end)
        }

        return false
    }

    private func formatPhoneDigits(_ digits: String, prefix: String) -> String {
        if digits.isEmpty { return prefix }
        let first = String(digits.prefix(5))
        let rest = String(digits.dropFirst(5))
        if rest.isEmpty {
            return prefix + first
        }
        return prefix + first + " " + rest
    }
}
