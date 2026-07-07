import Foundation

struct BudgetjarItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var detail: String
    var date: Date

    init(id: UUID = UUID(), title: String, detail: String = "", date: Date = Date()) {
        self.id = id
        self.title = title
        self.detail = detail
        self.date = date
    }
}
