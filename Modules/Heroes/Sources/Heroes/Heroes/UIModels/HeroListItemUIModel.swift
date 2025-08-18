//
//  HeroListItemUIModel.swift
//  Heroes
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import Foundation

struct HeroListItemUIModel: Identifiable, Hashable {
    let id: Int
    let imageURL: URL?
    let name: String
}
