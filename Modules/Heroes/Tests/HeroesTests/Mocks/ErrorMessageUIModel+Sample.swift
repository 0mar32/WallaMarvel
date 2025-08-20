//
//  ErrorMessageUIModel+Sample.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//

import Foundation
@testable import Heroes 

extension ErrorMessageUIModel {
    static func sample(
        title: String = "Error",
        text: String = "Something went wrong"
    ) -> ErrorMessageUIModel {
        ErrorMessageUIModel(title: title, text: text)
    }
}
