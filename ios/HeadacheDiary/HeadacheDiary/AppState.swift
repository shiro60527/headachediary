//
//  AppState.swift
//  HeadacheDiary
//

import Foundation
import Observation

@Observable
final class AppState {
    enum Tab {
        case record, history, print, settings
    }

    var selectedTab: Tab = .record
    var currentDateKey: String = DateKey.today()

    func goToRecord(dateKey: String) {
        currentDateKey = dateKey
        selectedTab = .record
    }
}
