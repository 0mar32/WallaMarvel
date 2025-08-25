//
//  ErrorMessage.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import Foundation

struct ErrorMessageUIModel: Identifiable, Equatable {

    var id: String { title }
    let title: String
    let message: String
    let actionTitle: String

    init(
        title: String,
        message: String = "",
        actionTitle: String
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
    }
}
