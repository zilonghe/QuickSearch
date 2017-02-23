//
//  Result.swift
//  QuickSearch
//
//  Created by 何子龙 on 05/02/2017.
//  Copyright © 2017 何子龙. All rights reserved.
//

import Foundation

struct result {
    var movieName:String
    var detail: String
    var date: String
    var casts: String
    var url: String
    var imageUrl: String
    
    init(_ movieName:String, _ detail:String, _ date:String, _ casts:String, _ url:String, _ imageUrl:String) {
        self.movieName = movieName
        self.detail = detail
        self.date = date
        self.casts = casts
        self.url = url
        self.imageUrl = imageUrl
    }
}
