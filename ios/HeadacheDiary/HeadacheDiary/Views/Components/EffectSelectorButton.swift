//
//  EffectSelectorButton.swift
//  HeadacheDiary
//
//  服薬の効き目4択（Web版 .effect-group 相当）。
//
//  Web版は内部変数の初期値が "unknown" でも、クリックイベントが発火するまで
//  どのボタンにも .selected クラスが付かない（画面上は未選択に見える）。
//  この非対称性を再現するため selected は Optional とし、未選択(nil)と
//  「未記入を明示選択」を区別する。薬追加時に nil であれば "unknown" として保存する。
//

import SwiftUI

struct EffectSelectorGroup: View {
    @Binding var selected: MedEffect?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MedEffect.allCases) { effect in
                let isSelected = selected == effect
                Button {
                    selected = effect
                } label: {
                    Text(effect.label)
                        .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .foregroundColor(isSelected ? DesignConstants.tealDark : DesignConstants.gray)
                .background(isSelected ? DesignConstants.tealLight : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? DesignConstants.teal : DesignConstants.border, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
