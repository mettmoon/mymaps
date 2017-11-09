//
//  GPXModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 30..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
struct GPX {
    var gpxScheme:String = "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"1.1\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\" creator=\"MotionXGPSFull 24.2 Build 5063R64\">"
    var defaultScheme:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    func getXMLString() -> String {
        var result = ""
        result.appendXML(defaultScheme)
        result.appendXML(gpxScheme)
        if let name = self.name {
            result.appendXML("<name>\(name)</name>")
        }
        if let desc = self.desc {
            result.appendXML("<desc>\(desc)</desc>")
        }
        
        for waypoint in self.waypoints ?? [] {
            result.appendXML(waypoint.getXMLString(tagName: "wpt"))
        }
        if let tracks = self.tracks, tracks.count > 0 {
            for track in tracks {
                result.appendXML(track.getXMLString(tagName: "trk"))
            }
        }
        result.appendXML("</gpx>")
        
        return result
    }
    var name:String?
    var desc:String?
    var tracks:[Track]?
    var waypoints:[Waypoint]?
//    var routes:[Route]?
//    var metadata:Metadata?
//    var extensions:[Extension]?
}

extension String {
    mutating func appendXML(_ string:String, prettyPrinted:Bool = true){
        self.append(string)
        if prettyPrinted {
            self.append("\n")
        }
    }
}

