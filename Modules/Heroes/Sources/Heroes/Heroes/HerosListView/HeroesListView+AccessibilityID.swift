//
//  AccessibilityID.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 21/8/25.
//

import Foundation

extension HeroesListView {
    enum AccessibilityID {
        static let screen = "HeroesList_Screen"
        static let loading = "HeroesList_Loading"
        static let table = "HeroesList_Table"
        static let paginationSpinner = "HeroesList_PaginationSpinner"
        static let retryColumn = "HeroesList_RetryColumn"
        static let retryRow = "HeroesList_RetryRow"

        static func heroCell(_ id: Int) -> String {
            "HeroCell_\(id)"
        }
    }
}
