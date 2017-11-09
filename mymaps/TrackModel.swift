//
//  TrackModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 30..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
import CoreLocation

struct Track {
    var name:String?
    var comment:String?
    var desc:String?
    var source:String?
    var link:URL?
    var number:UInt?
    var type:String?
    var extensions:Extensions?
    var trackSequnce:TrackSequnce?
    init(name:String? = nil, comment:String? = nil, desc:String? = nil, source:String? = nil, link:URL? = nil, number:UInt? = nil, type:String? = nil, extensions:Extensions? = nil, trackSequnce:TrackSequnce? = nil){
        self.name = name
        self.comment = comment
        self.desc = desc
        self.source = source
        self.link = link
        self.number = number
        self.type = type
        self.extensions = extensions
        self.trackSequnce = trackSequnce
    }
}

struct TrackSequnce {
    var trackPoints:[Waypoint]?
    var extensions:Extensions?
    init(trackPoints:[Waypoint]? = nil, extensions:Extensions? = nil) {
        self.trackPoints = trackPoints
        self.extensions = extensions
    }
}
struct Extensions {
    var parameters:[String : String]?
}



