//
//  Constants.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-11.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import Foundation

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
}