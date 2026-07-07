import XCTest
@testable import Budgetjar

@MainActor
final class BudgetjarTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeItemLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(title: "New Entry", detail: "Notes")
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddedItemAppearsFirst() {
        store.add(title: "Newest", detail: "")
        XCTAssertEqual(store.items.first?.title, "Newest")
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimitWithoutPro() {
        for i in 0..<(Store.freeItemLimit + 5) {
            store.add(title: "Item \(i)", detail: "")
        }
        XCTAssertFalse(store.canAddMore)
        XCTAssertEqual(store.items.count, Store.freeItemLimit)
    }

    func testProUnlockAllowsUnlimitedAdds() {
        store.isProUnlocked = true
        for i in 0..<(Store.freeItemLimit + 5) {
            store.add(title: "Item \(i)", detail: "")
        }
        XCTAssertTrue(store.canAddMore)
        XCTAssertEqual(store.items.count, Store.freeItemLimit + 5)
    }

    func testDeleteRemovesItem() {
        store.add(title: "ToDelete", detail: "")
        let item = store.items.first!
        store.delete(item)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testUpdateModifiesItem() {
        store.add(title: "Original", detail: "")
        var item = store.items.first!
        item.title = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.title, "Updated")
    }
}
