import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @State private var showEditProfile = false
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            LinearGradient.hydroGradient.ignoresSafeArea()

            List {
                profileSection
                notificationsSection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: dataStore.profile ?? fallbackProfile)
                .presentationDetents([.large])
                .presentationCornerRadius(28)
        }
        .confirmationDialog("Reset today's data?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset Today", role: .destructive) { dataStore.resetToday() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase all water logs for today. History from other days is unaffected.")
        }
    }

    // MARK: - Sections

    private var profileSection: some View {
        Section("Profile") {
            if let profile = dataStore.profile {
                HStack {
                    Label(profile.name, systemImage: "person.circle.fill")
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Edit") { showEditProfile = true }
                        .foregroundStyle(.hydroLight)
                }
                SettingsRow(icon: "scalemass.fill",  label: "Weight",         value: "\(Int(profile.weightLbs)) lbs")
                SettingsRow(icon: "figure.walk",     label: "Activity",        value: profile.activityLevel.rawValue)
                SettingsRow(icon: "waterbottle.fill", label: "Bottle Size",    value: "\(Int(profile.bottleSizeOz)) oz")
                SettingsRow(icon: "drop.fill",       label: "Daily Goal",      value: "\(Int(profile.dailyGoalOz)) oz")
                SettingsRow(icon: "number.circle.fill", label: "Bottles/Day", value: "\(profile.bottlesPerDay)")
            }
        }
        .listRowBackground(Color.white.opacity(0.1))

    }

    private var notificationsSection: some View {
        Section("Notifications") {
            if let profile = dataStore.profile {
                SettingsRow(
                    icon: "bell.fill",
                    label: "Reminder Window",
                    value: "\(profile.notificationStartHour):00 – \(profile.notificationEndHour):00"
                )
            }
            Button {
                if let profile = dataStore.profile {
                    NotificationService.shared.cancelAllNotifications()
                    NotificationService.shared.rescheduleNotifications(
                        for: profile,
                        todayOz: dataStore.todayTotalOz
                    )
                }
            } label: {
                Label("Reschedule Reminders", systemImage: "arrow.clockwise")
                    .foregroundStyle(.hydroLight)
            }
        }
        .listRowBackground(Color.white.opacity(0.1))
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Reset Today's Data", systemImage: "trash")
                    .foregroundStyle(.statusRed)
            }
        }
        .listRowBackground(Color.white.opacity(0.1))
    }

    private var aboutSection: some View {
        Section("About") {
            SettingsRow(icon: "drop.fill",    label: "App",     value: "HydroTrack")
            SettingsRow(icon: "tag.fill",     label: "Version", value: "1.0.0")
            SettingsRow(icon: "iphone",       label: "Requires", value: "iOS 17+")
        }
        .listRowBackground(Color.white.opacity(0.1))
    }

    // MARK: - Fallback

    private var fallbackProfile: UserProfile {
        UserProfile(name: "", weightLbs: 150, sex: .preferNotToSay, activityLevel: .moderate, bottleSizeOz: 32)
    }
}

// MARK: - SettingsRow

struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.hydroMid)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .foregroundStyle(.white.opacity(0.55))
        }
    }
}

// MARK: - EditProfileView

struct EditProfileView: View {
    @EnvironmentObject var dataStore: HydroDataStore
    @Environment(\.dismiss) var dismiss
    @State var profile: UserProfile

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.hydroGradient.ignoresSafeArea()

                Form {
                    personalSection
                    bottleSection
                    notificationSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataStore.updateProfile(profile)
                        if let p = dataStore.profile {
                            NotificationService.shared.rescheduleNotifications(
                                for: p,
                                todayOz: dataStore.todayTotalOz
                            )
                        }
                        dismiss()
                    }
                    .foregroundStyle(.hydroLight)
                }
            }
        }
    }

    private var personalSection: some View {
        Section("Personal") {
            HStack {
                Text("Name").foregroundStyle(.white)
                Spacer()
                TextField("Name", text: $profile.name)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.white)
                    .tint(.white)
            }
            HStack {
                Text("Weight (lbs)").foregroundStyle(.white)
                Spacer()
                TextField("150", value: $profile.weightLbs, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .frame(width: 80)
            }
            Picker("Sex", selection: $profile.sex) {
                ForEach(Sex.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .foregroundStyle(.white)
            Picker("Activity Level", selection: $profile.activityLevel) {
                ForEach(ActivityLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .foregroundStyle(.white)
        }
        .listRowBackground(Color.white.opacity(0.1))
    }

    private var bottleSection: some View {
        Section("Bottle") {
            HStack {
                Text("Bottle Size (oz)").foregroundStyle(.white)
                Spacer()
                TextField("32", value: $profile.bottleSizeOz, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .frame(width: 80)
            }
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.hydroMid)
                Text("Calculated goal: \(Int(profile.dailyGoalOz)) oz / \(profile.bottlesPerDay) bottles")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .listRowBackground(Color.white.opacity(0.1))
    }

    private var notificationSection: some View {
        Section("Reminder Window") {
            Stepper(
                "Start: \(profile.notificationStartHour):00",
                value: $profile.notificationStartHour,
                in: 4...12
            )
            .foregroundStyle(.white)
            Stepper(
                "End: \(profile.notificationEndHour):00",
                value: $profile.notificationEndHour,
                in: 18...23
            )
            .foregroundStyle(.white)
        }
        .listRowBackground(Color.white.opacity(0.1))
    }
}
