//
//  WaypointModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 27..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
import CoreLocation

struct Waypoint {
    var coordinate:CLLocationCoordinate2D
    var date:Date?
    var name:String?
    var desc:String?
    var type:WaypointType?
    init(coordinate:CLLocationCoordinate2D, date:Date? = nil, name:String? = nil, desc:String? = nil, type:WaypointType? = nil){
        self.coordinate = coordinate
        self.date = date
        self.name = name
        self.desc = desc
        self.type = type
        
    }
    
}
struct WaypointType {
    var name:String
}


