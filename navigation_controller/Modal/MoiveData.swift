//
//  MoiveData.swift
//  navigation_controller
//
//  Created by Tarun Kumar on 23/08/24.
//

import Foundation

struct MovieData :Codable{
    let page :Int
    let results : [Results]
}
struct Results : Codable{
    let id : Int
    let original_title :String
    let overview:String
    let poster_path:String
}
