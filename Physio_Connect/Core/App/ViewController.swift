import UIKit

final class ViewController: UIViewController, UITableViewDataSource {

    private let tableView = UITableView()
    private let service = PhysioService.shared
    private var items: [Physiotherapist] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Physiotherapists"
        view.backgroundColor = .white

        setupTable()

        Task { await load() }
    }




    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @MainActor
    private func load() async {
        do {
            items = try await service.fetchPhysiotherapists()
            tableView.reloadData()
        } catch {
            print("❌ Supabase fetch error:", error)
        }
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let p = items[indexPath.row]
        let rating = p.avg_rating ?? 0
        let fee = Int(p.consultation_fee ?? 0)
        let loc = p.location_text ?? ""

        var content = cell.defaultContentConfiguration()
        content.text = p.name
        content.secondaryText = "⭐️ \(rating)   ₹\(fee)   \(loc)"
        cell.contentConfiguration = content

        return cell
    }
}
