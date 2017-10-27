//
//  WaypointModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 27..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
import CoreLocation
fileprivate let dateFormatter:DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-DDThh:mm:ssz"
    return dateFormatter
}()
struct Waypoint {
    var coordinate:CLLocationCoordinate2D
    var date:Date?
    var name:String = ""
    var desc:String?
    var type:WaypointType?
    
    func gpxString() -> String {
        var string:String = ""
        
        string += "<wpt lat=\"\(coordinate.latitude)\" lon=\"\(coordinate.longitude)\">"
        string += "<name>\(name)</name>"
        if let desc = desc {
        string += "<desc>\(desc)</desc>"
        }
        if let date = date {
            string += "<time>\(dateFormatter.string(from:date))</time>"
        }
        if let type = type {
            string += "<type>\(type.name)</type>"
        }
        string += "</wpt>"
        return string
    }
    
}
struct WaypointType {
    var name:String
}


