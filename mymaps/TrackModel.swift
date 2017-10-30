//
//  TrackModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 10. 30..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation
import CoreLocation

struct Track:xmlProtocol {
    var name:String?
    var comment:String?
    var desc:String?
    var source:String?
    var link:URL?
    var number:UInt?
    var type:String?
    var extensions:Extensions?
    var trackSequnce:TrackSequnce?
    
    func getXMLString() -> String {
        return ""
    }
}

struct TrackSequnce {
    var trackPoint:Waypoint?
    var extensions:Extensions?
}
struct Extensions {
    
}
