//
//  Tour.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

public class Tour {
    
    enum TourType : String {
        case RoundTour = "round-tour"
        case Tour = "tour"
        case PublicTransportTour = "public-transport-tour"
        case BikeTour = "bike-tour"
        
        var representation: String {
            get {
                switch self {
                case .RoundTour: return "Rundgang"
                case .Tour: return "Spaziergang"
                case .PublicTransportTour: return "ÖPNV-Tour"
                case .BikeTour: return "Fahrrad-Tour"
                }
            }
        }
    }
    
    // the tour's id given by the backend
    var id: Int64 = 0
    
    // the backends publishing timestamp
    var version: Int64 = 0
    
    // the tour's name
    var name: String = ""
    
    // the mapstops, the tour consists of
    var mapstops: Array<Mapstop> = Array()
    
    // the area the tour is taking place in
    var area: Area?
    
    // which type of tour is this
    var type: TourType = .Tour
    
    // the tour's length in meters
    var walkLength: Int = 0
    
    // the tour's duration in minutes
    var duration: Int = 0
    
    // a few short strings describing the tour
    var tagWhat: String = ""
    var tagWhen: String = ""
    var tagWhere: String = ""
    
    // how easy is it to access the places in this tour
    var accessibility: String = ""
    
    // a string identifying the tour's creator(s)
    var author: String = ""
    
    // a short introduction to the tour
    var intro: String = ""
    
    // the tour's track as a series of geo coordinates
    // TODO
    
    // point of creation in the backend's db assumed to be in GMT+2
    var createdAt: Date = Date()
    static let creationDateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 2)
        return formatter
    }
    
    // TODO: Check if necessary
    // a tour might have Lexicon entries associated during installation
    // the connection to those is however not persisted
}
