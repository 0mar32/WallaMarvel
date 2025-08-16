//
//  HeroUIModel.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import Foundation
import DesignSystem

struct HeroDetailsUIModel {
    var id: Int
    var title: String
    var imageURL: URL?
    var description: String
    var storiesSection: SectionUIModel?
    var seriesSection: SectionUIModel?
}

struct SectionUIModel {
    let icon: SFIcon?
    let title: String
    let names: [String]
}
