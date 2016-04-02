//
//  Model.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-17.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import Foundation

/// This class holds the data shared by various other classes. Access them through 
/// `Model.sharedInstance().propertyName`.
/// - parameters:
///   - userInformation: a StudentLocation struct containing the logged in user's information.
///   Used when posting a new location to the Parse API.
///   - studentLocations: an array of StudentLocation structs that contains the informations
///   posted by students. Used to display information on the map or in the tableView.
///   - loggedInWithFacebook: Bool - true if login process was through FB, false otherwise. 
///   Used to manage login to Parse and login out
///   - fbToken: String? - if logged in through FB, this holds the user token returned
///   - fbUserId: String? - if logged in through FB, this holds the used id
class Model: NSObject {

    var userInformation: StudentLocation? = nil
    var studentLocations: [StudentLocation]? = nil
    var loggedInWithFacebook: Bool = false
    var fbToken: String?
    var fbUserId: String?

    override init() {
        super.init()
    }

    // MARK: Shared Instance

    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }

}
