//
//  Model.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-17.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

class Model {

    static let sharedDataContainer = Model()
    
    var studentLocations: [StudentLocation]?
    
    init() {
    }
}
