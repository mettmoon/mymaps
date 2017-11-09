//
//  GPXModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 30..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
struct GPX {
    var gpxScheme:String {
        return "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"\(version)\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\" creator=\"\(creator)\">"
    }
    var defaultScheme:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    func getXMLString() -> String {
        var result = ""
        result.appendXML(defaultScheme)
        result.appendXML(gpxScheme)
        
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
    var tracks:[Track]?
    var waypoints:[Waypoint]?
    var routes:[Route]?
    var metadata:Metadata?
    var extensions:Extensions?
    var creator:String
    var version:String
    init(creator:String, version:String = "1.1", tracks:[Track]? = nil, waypoints:[Waypoint]? = nil, routes:[Route]? = nil, metadata:Metadata? = nil, extensions:Extensions? = nil) {
        self.creator = creator
        self.version = version
        self.tracks = tracks
        self.waypoints = waypoints
        self.routes = routes
        self.metadata = metadata
        self.extensions = extensions
    }
}

extension String {
    mutating func appendXML(_ string:String, prettyPrinted:Bool = true){
        self.append(string)
        if prettyPrinted {
            self.append("\n")
        }
    }
}

