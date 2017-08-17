//
//  ServerResponseReader.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import Yams
import os.log

// A service class parsing YAML responses sent by the backend
class ServerResponseReader {
    
    enum Fail: Error {
        case ParseError
        case CastError
    }
    
    public static func parseTourYAML(_ input: String) -> Tour? {
        let tour = Tour()
        
        do {
            // parse the yaml input into a YAMS node
            let node = try Parser(yaml: input).singleRoot()
            
            // this uses a dictionary extension (defined in: Yams/Constructor.swift)
            guard let dict = Dictionary<String, Any>.construct_mapping(from: node!) as? Dictionary<String, Any> else {
                throw ParseError.General(msg: "Cannot construct mapping from input.")
            }
            
            // the tour values
            tour.id = try dict.safeGetUint64("id")
            tour.name = try dict.safeGetString("name")
            tour.type = try dict.safeGetTourType("type")
            tour.walkLength = try dict.safeGetInt("walkLength")
            tour.duration = try dict.safeGetInt("duration")
            tour.tagWhat = try dict.safeGetString("tagWhat")
            tour.tagWhen = try dict.safeGetString("tagWhen")
            tour.tagWhere = try dict.safeGetString("tagWhere")
            tour.accessibility = try dict.safeGetString("accessibility")
            tour.author = try dict.safeGetString("author")
            tour.intro = try dict.safeGetString("intro")
            tour.createdAt = try dict.safeGetDate("createdAt", formatter: Tour.creationDateFormatter())
            
            // create the area and link it
            let areaDict = try dict.safeGetObjectDict("area")
            let area = Area()
            area.id = try areaDict.safeGetUint64("id")
            area.name = try areaDict.safeGetString("name")
            area.tours.append(tour)
            tour.area = area
            
            // creaete and link the tour's mapstops
            let mapstopDicts = try dict.safeGetObjectDictArray("mapstops")
            for stopDict in mapstopDicts {
                let mapstop = Mapstop()
                
                // mapstop values
                mapstop.id = try stopDict.safeGetUint64("id")
                mapstop.name = try stopDict.safeGetString("name")
                mapstop.description = try stopDict.safeGetString("description")
                
                // create and link the place
                let placeDict = try stopDict.safeGetObjectDict("place")
                let place = Place()
                place.id = try placeDict.safeGetUint64("id")
                place.lat = try placeDict.safeGetDouble("lat")
                place.lon = try placeDict.safeGetDouble("lon")
                place.name = try placeDict.safeGetString("name")
                place.area = tour.area
                mapstop.place = place
                
                // create and link the pages
                let pageDicts = try stopDict.safeGetObjectDictArray("pages")
                for pageDict in pageDicts {
                    let page = Page()
                    page.id = try pageDict.safeGetUint64("id")
                    page.guid = try pageDict.safeGetString("guid")
                    page.pos = try pageDict.safeGetInt("pos")
                    page.content = try pageDict.safeGetString("content")
                    
                    // create and link the page's mediaitems
                    if pageDict["media"] != nil {
                        let mediaitemDicts = try pageDict.safeGetObjectDictArray("media")
                        for mediaitemDict in mediaitemDicts {
                            let mediaitem = Mediaitem()
                            mediaitem.guid = try mediaitemDict.safeGetString("guid")
                            mediaitem.page = page
                            page.media.append(mediaitem)
                        }
                    }
                    //link the page
                    mapstop.pages.append(page)
                    page.mapstop = mapstop
                }
                
                // link stop to tour and vice versa
                mapstop.tour = tour
                tour.mapstops.append(mapstop)
                
            }
            
        } catch let error as ParseError {
            print("ParseError: \(error.message)")
            return nil
        } catch {
            print("Unknown error in tour parsing: " + String(describing: error))
            return nil
        }
        
        return tour
    }
    
}

// An error class used to handle errors while parsing a server response
fileprivate enum ParseError: Error {
    
    case General(msg: String)
    case CastError(key: String, type: String)
    
    var message: String {
        get {
            switch self {
            case let .General(msg): return msg
            case let .CastError(key, type): return "CastError: Key '\(key)' not of type '\(type)'"
            }
        }
    }
    
}

// we extend the Dictionary class to (type-) safe retrieve values from a
// Dictionary<String, Any> (the result of YAML parsing)
fileprivate extension Dictionary where Value: Any {
    
    func safeGetString(_ key: Key) throws -> String {
        guard let result = self[key] as? String else {
            throw ParseError.CastError(key: String(describing: key), type: "String")
        }
        return result
    }
    
    func safeGetInt(_ key: Key) throws -> Int {
        guard let result = self[key] as? Int else {
            throw ParseError.CastError(key: String(describing: key), type: "Int")
        }
        return result
    }
    
    func safeGetDouble(_ key: Key) throws -> Double {
        guard let result = self[key] as? Double else {
            throw ParseError.CastError(key: String(describing: key), type: "Double")
        }
        return result
    }
    
    func safeGetUint64(_ key: Key) throws -> UInt64 {
        // Yams parses all integer values as ints (sad)
        let asInt = try self.safeGetInt(key)
        return UInt64(asInt)
    }
    
    func safeGetObjectDict(_ key: Key) throws -> Dictionary<String, Any> {
        guard let result = self[key] as? Dictionary<String, Any> else {
            throw ParseError.CastError(key: String(describing: key), type: "Dictionary<String, Any>")
        }
        return result
    }
    
    func safeGetObjectDictArray(_ key: Key) throws -> Array<Dictionary<String, Any>> {
        guard let result = self[key] as? Array<Dictionary<String, Any>> else {
            throw ParseError.CastError(key: String(describing: key), type: "Array<Dictionary<String, Any>>")
        }
        return result
    }
    
    // NOTE: This assumes the input's time to be in GMT+2
    func safeGetDate(_ key: Key, formatter: DateFormatter) throws -> Date {
        let dateDescription = try self.safeGetString(key)
        guard let result = formatter.date(from: dateDescription) else {
            throw ParseError.General(msg: "Invalid date '\(dateDescription)' for format: '\(formatter.dateFormat)'")
        }
        return result
    }
    
    func safeGetTourType(_ key: Key) throws -> Tour.TourType {
        let typeDescription = try self.safeGetString(key)
        guard let result = Tour.TourType(rawValue: typeDescription) else {
            throw ParseError.General(msg: "Not a valid tour type: \(typeDescription)")
        }
        return result
    }
}

