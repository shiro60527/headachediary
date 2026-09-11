//
//  MedicationCard.swift
//  HeadacheDiary
//
//  Web版「飲んだ薬」カード（index.html:323-351, 700-715）。
//

import SwiftUI
import SwiftData

struct MedicationCard: View {
    let dateKey: String
    let day: DiaryDay?
    @Environment(\.modelContext) private var context

    @State private var time = Date()
    @State private var name = ""
    @State private var count: Double = 1
    @State private var selectedEffect: MedEffect? = nil
    @State private var showValidationAlert = false

    var body: some View {
        SectionCard(title: "飲んだ薬", hint: "効き目も記録できます") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("時刻")
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .frame(width: 90)

                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("薬の名前")
                        TextField("例: バファリン", text: $name)
                            .textFieldStyle(.roundedBorder)
                        MedNameSuggestionChips(name: $name)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("錠数")
                        Stepper(value: $count, in: 0.5...20, step: 0.5) {
                            Text(countLabel)
                        }
                        .frame(width: 110)
                    }
                }

                fieldLabel("効き目")
                EffectSelectorGroup(selected: $selectedEffect)

                Button(action: addMedication) {
                    Text("＋ 薬を記録する")
                        .font(.system(size: 15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(DesignConstants.teal)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                if let meds = day?.sortedMedications, !meds.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(meds.enumerated()), id: \.element.persistentModelID) { index, med in
                            DiaryRow(time: med.time.isEmpty ? "--:--" : med.time) {
                                let effect = MedEffect.from(med.effect)
                                HStack(spacing: 10) {
                                    Text(med.name).font(.system(size: 14, weight: .semibold))
                                    Text(formattedCount(med.count) + "錠")
                                        .font(.system(size: 13))
                                        .foregroundColor(DesignConstants.gray)
                                    if !effect.shortLabel.isEmpty {
                                        Text(effect.shortLabel)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 8).padding(.vertical, 3)
                                            .background(DesignConstants.tealLight)
                                            .foregroundColor(DesignConstants.tealDark)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                }
                            } onDelete: {
                                delete(med)
                            }
                            if index < meds.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .alert("薬の名前を入力してください", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private var countLabel: String {
        formattedCount(count) + "錠"
    }

    private func formattedCount(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(DesignConstants.gray)
    }

    private func addMedication() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showValidationAlert = true
            return
        }
        let target = day ?? {
            let newDay = DiaryDay(dateKey: dateKey)
            context.insert(newDay)
            return newDay
        }()

        let effect = selectedEffect ?? .unknown
        let med = Medication(
            time: DateKey.timeString(from: time),
            name: trimmedName,
            count: count,
            effect: effect.rawValue
        )
        med.day = target
        context.insert(med)

        name = ""
        count = 1
        selectedEffect = nil
    }

    private func delete(_ med: Medication) {
        guard let target = day else { return }
        context.delete(med)
        DayMaintenance.pruneIfEmpty(target, context: context)
    }
}
