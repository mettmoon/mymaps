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
    func getXMLString(tagName:String) -> String {
        var context:String = "<\(tagName)>"
        if let name = self.name {
            context.appendXML("<name>\(name)</name>")
        }
        if let comment = self.comment {
            context.appendXML("<cmt>\(comment)</cmt>")
        }
        if let desc = self.desc {
            context.appendXML("<desc>\(desc)</desc>")
        }
        if let source = self.source {
            context.appendXML("<src>\(source)</src>")
        }
        if let link = self.link {
            context.appendXML("<link>\(link.absoluteString)</link>")
        }
        if let number = self.number {
            context.appendXML("<number>\(number)</number>")
        }
        if let type = self.type {
            context.appendXML("<type>\(type)</type>")
        }
        if let extensions = self.extensions {
            context.appendXML(extensions.getXMLString(tagName: "extensions"))
        }
        if let trkseq = self.trackSequnce?.getXMLString(tagName: "trkseg") {
            context.appendXML(trkseq)
        }
        context.appendXML("</\(tagName)>")
        return context
    }
}

struct TrackSequnce:xmlProtocol {
    var trackPoints:[Waypoint]?
    var extensions:Extensions?
    func getXMLString(tagName: String) -> String {
        var context:String = ""
        context.appendXML("<\(tagName)>")
        if let trackPoints = self.trackPoints {
            for trackPoint in trackPoints {
                context.appendXML(trackPoint.getXMLString(tagName: "trkpt"))
            }
        }
        if let extensions = self.extensions {
            context.appendXML(extensions.getXMLString(tagName: "extensions"))
        }
        context.appendXML("</\(tagName)>")
        return context
    }
}
struct Extensions:xmlProtocol {
    var parameters:[String : String]?
    func getXMLString(tagName: String) -> String {
        if let parameters = self.parameters, parameters.count > 0 {
            for (k,v) in parameters {
                
            }
        }
        return ""
    }
}

