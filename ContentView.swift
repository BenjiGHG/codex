import SwiftUI

struct ContentView: View {
    @StateObject private var store = CounterStore()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.accentColor.opacity(0.20),
                        Color(.systemBackground),
                        Color.accentColor.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        header

                        CounterCard(
                            title: "Ohne Selbstverletzung",
                            subtitle: "Jeder sichere Tag zählt.",
                            symbol: "heart.fill",
                            days: store.selfHarmDays,
                            startDate: store.selfHarmStart,
                            tint: .pink,
                            reset: store.resetSelfHarm
                        )

                        CounterCard(
                            title: "Ohne Alkohol",
                            subtitle: "Dein alkoholfreier Streak.",
                            symbol: "drop.fill",
                            days: store.alcoholDays,
                            startDate: store.alcoholStart,
                            tint: .blue,
                            reset: store.resetAlcohol
                        )

                        Text("Deine Daten bleiben lokal auf diesem Gerät.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .padding()
                }
            }
            .navigationTitle("Safe Days")
            .toolbarTitleDisplayMode(.large)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 78, height: 78)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }

            Text("Schritt für Schritt")
                .font(.title2.bold())

            Text("Heute zählt genauso wie morgen.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

struct CounterCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let days: Int
    let startDate: Date?
    let tint: Color
    let reset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(days)")
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text(days == 1 ? "Tag" : "Tage")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if let startDate {
                Label(
                    "Seit \(startDate.formatted(date: .abbreviated, time: .omitted))",
                    systemImage: "calendar"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Button(role: .destructive, action: reset) {
                Label("Startdatum zurücksetzen", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.22))
        }
        .shadow(color: .black.opacity(0.10), radius: 20, y: 8)
    }
}

final class CounterStore: ObservableObject {
    @Published private(set) var selfHarmStart: Date?
    @Published private(set) var alcoholStart: Date?

    private let selfHarmKey = "selfHarmStart"
    private let alcoholKey = "alcoholStart"

    init() {
        selfHarmStart = UserDefaults.standard.object(forKey: selfHarmKey) as? Date
        alcoholStart = UserDefaults.standard.object(forKey: alcoholKey) as? Date

        if selfHarmStart == nil {
            let now = Date()
            selfHarmStart = now
            UserDefaults.standard.set(now, forKey: selfHarmKey)
        }

        if alcoholStart == nil {
            let now = Date()
            self.alcoholStart = now
            UserDefaults.standard.set(now, forKey: self.alcoholKey)
        }
    }

    var selfHarmDays: Int { daysSince(selfHarmStart) }
    var alcoholDays: Int { daysSince(alcoholStart) }

    func resetSelfHarm() {
        let now = Date()
        selfHarmStart = now
        UserDefaults.standard.set(now, forKey: selfHarmKey)
    }

    func resetAlcohol() {
        let now = Date()
        alcoholStart = now
        UserDefaults.standard.set(now, forKey: alcoholKey)
    }

    private func daysSince(_ date: Date?) -> Int {
        guard let date else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0)
    }
}
