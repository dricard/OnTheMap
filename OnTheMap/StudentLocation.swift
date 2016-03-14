//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-11.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import Foundation

struct StudentLocation {
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaUrl: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    var createdAt: NSDate? = nil
    var updatedAt: NSDate? = nil
    var imageUrl: String? = nil

    init(uniqueKey: String?, firstName: String?, lastName: String?, mapString: String?, mediaUrl: String?, latitude: Float?, longitude: Float?, createdAt: NSDate?, updatedAt: NSDate?, imageUrl: String?) {
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