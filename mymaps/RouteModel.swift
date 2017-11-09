//
//  RouteModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 11. 9..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation

struct Route {
    var name:String?
    var comment:String?
    var desc:String?
    var source:String?
    var link:[Link]?
    var number:UInt?
    var type:String?
    var extensions:Extensions?
    var routepoints:[Waypoint]?
}

