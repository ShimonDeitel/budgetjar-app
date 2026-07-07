import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: BudgetjarItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.secondary)
                        Text("No entries yet")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.textPrimary)
                                    if !item.detail.isEmpty {
                                        Text(item.detail)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.secondary)
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.title)")
                            .listRowBackground(Theme.cardBackground)
                        }
                        .onDelete(perform: store.delete)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Family Budget Jar")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddEditView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                AddEditView(item: item)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(purchases)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(purchases)
            }
        }
        .tint(Theme.accent)
    }
}

struct AddEditView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let item: BudgetjarItem?

    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var date: Date = Date()
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .focused($isFocused)
                        .accessibilityIdentifier("titleField")
                    TextField("Notes", text: $detail)
                        .accessibilityIdentifier("detailField")
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("datePicker")
                }
            }
            .navigationTitle(item == nil ? "Add Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    title = item.title
                    detail = item.detail
                    date = item.date
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
    }

    private func save() {
        if var existing = item {
            existing.title = title
            existing.detail = detail
            existing.date = date
            store.update(existing)
        } else {
            store.add(title: title, detail: detail, date: date)
        }
    }
}
