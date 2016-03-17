//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-11.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

struct StudentLocation {
    
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaUrl: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String
    var imageUrl: String


    init(dictionary: [String:AnyObject]) {
         uniqueKey = dictionary[Constants.PARSE.uniqueKey] as! String
         firstName = dictionary[Constants.PARSE.firstName] as! String
         lastName = dictionary[Constants.PARSE.lastName] as! String
         mapString = dictionary[Constants.PARSE.mapString] as! String
         mediaUrl = dictionary[Constants.PARSE.mediaURL] as! String
         latitude = dictionary[Constants.PARSE.latitude] as! Double
         longitude = dictionary[Constants.PARSE.longitude] as! Double
         createdAt = dictionary[Constants.PARSE.createdAt] as! String
         updatedAt = dictionary[Constants.PARSE.updatedAt] as! String
         imageUrl = ""

    }
}