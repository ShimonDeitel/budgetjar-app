import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notifyEnabled_budgetjar") private var notifyEnabled = true
    @AppStorage("compactList_budgetjar") private var compactList = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Toggle("Enable Reminders", isOn: $notifyEnabled)
                        .accessibilityIdentifier("notifyToggle")
                    Toggle("Compact List", isOn: $compactList)
                        .accessibilityIdentifier("compactToggle")
                }
                Section("Pro") {
                    if purchases.isPurchased {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") { showPaywall = true }
                            .accessibilityIdentifier("upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/budgetjar-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/budgetjar-app/terms.html")!)
                    Text("Version 1.0")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(purchases)
            }
        }
    }
}
