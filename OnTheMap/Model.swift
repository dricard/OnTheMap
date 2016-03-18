//
//  Model.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-17.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import Foundation

class Model: NSObject {

    var userInformation: StudentLocation? = nil
    var studentLocations: [StudentLocation]? = nil

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
