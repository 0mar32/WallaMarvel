//
//  ErrorMessage.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

import Foundation

struct ErrorMessageUIModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let text: String
}
