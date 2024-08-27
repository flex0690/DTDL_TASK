//
//  MovieModal.swift
//  navigation_controller
//
//  Created by Tarun Kumar on 23/08/24.
//

import Foundation

struct MovieModal {
    var movieResults: [MovieResult]
    var numberOfMovies: Int
}

struct MovieResult: Codable {
    let id: Int
    let original_title: String
    let overview: String
    let poster_path: String
}

