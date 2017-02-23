//
//  Constants.swift
//  QuickSearch
//
//  Created by 何子龙 on 18/01/2017.
//  Copyright © 2017 何子龙. All rights reserved.
//

// MARK: - Constants

struct Constants {
    
    // MARK: Flickr
    struct Douban {
        static let APIScheme = "https"
        static let APIHost = "api.douban.com"
        static let APIPath = "/v2/movie/search"
        static let NowAPIPath = "/v2/movie/in_theaters"
    }
    
    // MARK: Douban Parameter Keys
    struct DoubanParameterKeys {
        static let Query = "q"
    }
    
    // MARK: Douban Parameter Values
//    struct DoubanParameterValues {
//        static let APIKey = "YOUR API KEY HERE"
//        static let ResponseFormat = "json"
//        static let DisableJSONCallback = "1" /* 1 means "yes" */
//        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
//        static let GalleryID = "5704-72157622566655097"
//        static let MediumURL = "url_m"
//    }
    
    // MARK: Douban Response Keys
    struct DoubanResponseKeys {
        static let Title = "title"
        static let Count = "count"
        static let Total = "total"
        static let Subject = "subjects"
        static let DirectLink = "alt"
        static let Rate = "rating"
    }
    
    // MARK: Douban Response Values
    struct DoubanResponseValues {
        static let OKStatus = "ok"
    }
}
