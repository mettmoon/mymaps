//
//  WaypointModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 27..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
import CoreLocation
extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

struct Waypoint:xmlProtocol {
    var coordinate:CLLocationCoordinate2D
    var date:Date?
    var name:String = ""
    var desc:String?
    var type:WaypointType?
    
    func getXMLString() -> String {
        var string:String = ""
        
        string += "<wpt lat=\"\(coordinate.latitude)\" lon=\"\(coordinate.longitude)\">"
        string += "<name>\(name)</name>"
        if let desc = desc {
        string += "<desc>\(desc)</desc>"
        }
        if let date = date {
            string += "<time>\(date.iso8601)</time>"
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


