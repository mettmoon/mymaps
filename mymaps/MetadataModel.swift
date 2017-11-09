//
//  MetadataModel.swift
//  mymaps
//
//  Created by Peter Moon on 2017. 11. 9..
//  Copyright © 2017년 WEJOApps. All rights reserved.
//

import Foundation

struct Metadata {
    var name:String?
    var desc:String?
    var author:Person?
    var copyright:Copyright?
    var link:[Link]?
    var time:Date?
    var keyword:[String]?
    var bounds:Bounds?
    var extensions:Extensions?
}

