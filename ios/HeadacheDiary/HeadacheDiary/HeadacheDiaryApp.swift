//
//  HeadacheDiaryApp.swift
//  HeadacheDiary
//

import SwiftUI
import SwiftData

@main
struct HeadacheDiaryApp: App {
    var sharedModelContainer: ModelContainer = {
        let configuration = ModelConfiguration(schema: Schema(versionedSchema: HeadacheDiarySchemaV1.self), isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(
                for: Schema(versionedSchema: HeadacheDiarySchemaV1.self),
                migrationPlan: HeadacheDiaryMigrationPlan.self,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
