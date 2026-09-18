import SwiftUI

struct ContentView: View {
    @StateObject private var store = CounterStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header

                    CounterCard(
                        title: "Ohne Selbstverletzung",
                        subtitle: "Jeder sichere Tag zählt.",
                        symbol: "heart.fill",
                        days: store.selfHarmDays,
                        startDate: store.selfHarmStart,
                        reset: store.resetSelfHarm
                    )

                    CounterCard(
                        title: "Ohne Alkohol",
                        subtitle: "Dein alkoholfreier Streak.",
                        symbol: "drop.fill",
                        days: store.alcoholDays,
                        startDate: store.alcoholStart,
                        reset: store.resetAlcohol
                    )

                    Text("Die App speichert deine Daten nur lokal auf diesem Gerät.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Safe Days")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 38))
                .foregroundStyle(.green)

            Text("Schritt für Schritt")
                .font(.title2.bold())

            Text("Heute zählt genauso wie morgen.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }
}

struct CounterCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let days: Int
    let startDate: Date?
    let reset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(.green)
                Text(title)
                    .font(.headline)
                Spacer()
            }

            Text("\(days)")
                .font(.system(size: 54, weight: .bold, design: .rounded))

            Text(days == 1 ? "Tag" : "Tage")
                .foregroundStyle(.secondary)

            Text(subtitle)
                .foregroundStyle(.secondary)

            if let startDate {
                Text("Seit \(startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button("Startdatum zurücksetzen", role: .destructive) {
                reset()
            }
            .buttonStyle(.bordered)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
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
            alcoholStart = now
            UserDefaults.standard.set(now, forKey: alcoholKey)
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
