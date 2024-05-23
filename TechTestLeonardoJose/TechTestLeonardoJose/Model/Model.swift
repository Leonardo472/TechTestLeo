//
//  Model.swift
//  TechTestLeonardoJose
//
//  Created by Leonardo Jose Gunawan on 23/05/24.
//

import Foundation

struct ImgurImage: Codable {
    let id: String
    let title: String?
    let description: String?
    let datetime: Int
    let type: String
    let animated: Bool
    let width: Int
    let height: Int
    let size: Int
    let views: Int
    let bandwidth: Int
    let link: String
}
