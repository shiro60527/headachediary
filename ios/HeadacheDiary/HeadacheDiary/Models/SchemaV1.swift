//
//  SchemaV1.swift
//  HeadacheDiary
//
//  現行モデル一式を VersionedSchema で包み、将来のモデル変更に備えた
//  SchemaMigrationPlan の器を用意する（MVP時点ではステージなし）。
//

import Foundation
import SwiftData

enum HeadacheDiarySchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [DiaryDay.self, HeadacheEntry.self, Medication.self]
    }
}

enum HeadacheDiaryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HeadacheDiarySchemaV1.self]
    }

    static var stages: [MigrationStage] { [] }
}
