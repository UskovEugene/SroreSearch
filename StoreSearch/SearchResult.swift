//
//  SearchResult.swift
//  StoreSearch
//
//  Created by пользователь on 21.02.17.
//  Copyright © 2017 Eugene Uskov. All rights reserved.
//

class SearchResult {
 
    var name = ""
    var artistName = ""

    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""


    
    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
