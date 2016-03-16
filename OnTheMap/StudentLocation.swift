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

    
    init(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: Double, longitude: Double, createdAt: String, updatedAt: String, imageUrl: String) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaUrl = mediaUrl
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageUrl = imageUrl
    }


}