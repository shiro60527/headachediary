//
//  MedNameSuggestionChips.swift
//  HeadacheDiary
//
//  Web版 <datalist> の代替。過去入力した薬名をチップでタップ入力できるようにする
//  （ドロップダウンの完全再現はMVPでは過剰なため簡易化）。
//

import SwiftUI
import SwiftData

struct MedNameSuggestionChips: View {
    @Binding var name: String
    @Query(sort: \Medication.name) private var allMedications: [Medication]

    private var suggestions: [String] {
        let names = Set(allMedications.map { $0.name }).subtracting([""])
        let filtered = name.isEmpty ? names : names.filter { $0.localizedStandardContains(name) && $0 != name }
        return Array(filtered.sorted().prefix(8))
    }

    var body: some View {
        if !suggestions.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            name = suggestion
                        } label: {
                            Text(suggestion)
                                .font(.system(size: 12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        }
                        .foregroundColor(DesignConstants.tealDark)
                        .background(DesignConstants.tealLight)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
