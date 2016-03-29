//
//  Constants.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-11.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import Foundation

/// Holds all the URLs and keys of the Udacity and Parse APIs. This way if
/// the APIs change in the futur only this files needs to be updated.
///
/// Use `Constants.UDACITY.parameter` to access Udacity's API parameters and
/// `Constants.PARSE.parameter` to access Parse API parameters.
struct Constants {
    
    // UDACITY
    
    struct UDACITY {
        
        // opening a session
        static let baseUrl = "https://www.udacity.com/api/session"
        
        // session response
        static let account = "account"
        static let registered = "registered"
        static let key = "key"
        
        static let session = "session"
        static let expiration = "expiration"
        static let id = "id"
        
        // getting user public data
        static let userDataUrl = "https://www.udacity.com/api/users/"
        // user data response
        static let user = "user"
        static let lastName = "last_name"
        static let firstName = "first_name"
        static let imageUrl = "_image_url"
        
    }
    
    struct PARSE {
        
        // getting student locations
        static let baseUrl = "https://api.parse.com/1/classes/StudentLocation"
        // location data response
        static let results = "results"
        
        static let createdAt = "createdAt"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
    }
}