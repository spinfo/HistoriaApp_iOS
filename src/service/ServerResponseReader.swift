
import Foundation

import Yams
import XCGLogger

// A service class parsing YAML responses sent by the backend
class ServerResponseReader {

    enum Fail: Error {
        case ParseError
        case CastError
    }

    public static func parseTourRecordsYAML(_ input: String) -> [TourRecord]? {
        var result = Array<TourRecord>()

        do {
            let dicts = try parseToArray(input)
            result = try dicts.map({ (dict: Dictionary<String, Any>) -> TourRecord in
                let record = TourRecord()
                record.id = try dict.safeGetInt64("id")
                record.name = try dict.safeGetString("name")
                record.areaId = try dict.safeGetInt64("areaId")
                record.tourId = try dict.safeGetInt64("tourId")
                record.areaName = try dict.safeGetString("areaName")
                record.version = try dict.safeGetInt("version")
                record.downloadSize = try dict.safeGetInt("downloadSize")
                record.downloadUrl = try dict.safeGetString("mediaUrl")
                return record
            })
        } catch let error as ParseError {
            log.error("ParseError on tour records parsing: \(error)")
            return nil
        } catch {
            log.error("Unknown error in tour records parsing: \(error)")
            return nil
        }

        return result
    }

    public static func parseTourYAML(_ input: String) -> Tour? {
        let tour = Tour()

        do {
            let dict = try parseToDict(input)

            // the tour values
            tour.id = try dict.safeGetInt64("id")
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
            area.id = try areaDict.safeGetInt64("id")
            area.name = try areaDict.safeGetString("name")
            area.tours.append(tour)
            tour.area = area
            tour.area!.point1 = try PersistableGeopoint(coords: areaDict.safeGetDoubleArray("point1"))
            tour.area!.point2 = try PersistableGeopoint(coords: areaDict.safeGetDoubleArray("point2"))

            // create and link the tour track
            tour.track = []
            for doublePair in try dict.safeGetArrayOfDoubleArrays("track") {
                let point = try PersistableGeopoint(coords: doublePair)
                point.tour = tour
                tour.track!.append(point)
            }

            // creaete and link the tour's mapstops
            let mapstopDicts = try dict.safeGetObjectDictArray("mapstops")
            var mapstopPos = 0
            for stopDict in mapstopDicts {
                let mapstop = Mapstop()

                // mapstop values
                mapstop.id = try stopDict.safeGetInt64("id")
                mapstop.name = try stopDict.safeGetString("name")
                mapstop.description = try stopDict.safeGetString("description")
                mapstop.pos = mapstopPos
                mapstopPos += 1

                // create and link the place
                let placeDict = try stopDict.safeGetObjectDict("place")
                let place = Place()
                place.id = try placeDict.safeGetInt64("id")
                place.lat = try placeDict.safeGetDouble("lat")
                place.lon = try placeDict.safeGetDouble("lon")
                place.name = try placeDict.safeGetString("name")
                place.area = tour.area
                mapstop.place = place

                // create and link the pages
                let pageDicts = try stopDict.safeGetObjectDictArray("pages")
                for pageDict in pageDicts {
                    let page = Page()
                    page.id = try pageDict.safeGetInt64("id")
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

            // create and link the tour's lexicon entries
            if dict["lexiconEntries"] != nil {
                let lexDicts = try dict.safeGetObjectDictArray("lexiconEntries")
                for lexDict in lexDicts {
                    let entry = LexiconEntry()
                    entry.id = try lexDict.safeGetInt64("id")
                    entry.title = try lexDict.safeGetString("title")
                    entry.content = try lexDict.safeGetString("content")
                    tour.lexiconEntries.append(entry)
                }
            }
        } catch let error as ParseError {
            log.error("ParseError on tour parsing: \(error)")
            return nil
        } catch {
            log.error("Unknown error in tour parsing: \(error)")
            return nil
        }

        return tour
    }

    // wrap Yams' basic parsing into a throwing function for convenience
    private static func parseToDict(_ input: String) throws -> Dictionary<String, Any> {
        guard !input.isEmpty else {
            throw ParseError.General(msg: "Empty input on yaml parsing.")
        }
        // parse the yaml input into a YAMS node and use YAMS' dictionary extension to get a mapping
        return try Yams.load(yaml: input) as! Dictionary<String, Any>
    }

    // wrap Yams' basic parsing into a throwing function for convenience
    private static func parseToArray(_ input: String) throws -> Array<Dictionary<String, Any>> {
        guard !input.isEmpty else {
            throw ParseError.General(msg: "Empty input on yaml parsing.")
        }

        var result = Array<Dictionary<String, Any>>()
        var sequence = try Yams.load_all(yaml: input)
        while let single = sequence.next() {
            result.append(single as! Dictionary<String, Any>)
        }
        return result
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

// we extend the Dictionary class to (type-) safely retrieve values from a
// Dictionary<String, Any>
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

    func safeGetDoubleArray(_ key: Key) throws -> [Double] {
        guard let result = self[key] as? [Double] else {
            throw ParseError.CastError(key: String(describing: key), type: "[Double]")
        }
        return result
    }

    func safeGetArrayOfDoubleArrays(_ key: Key) throws -> [[Double]] {
        guard let result = self[key] as? [[Double]] else {
            throw ParseError.CastError(key: String(describing: key), type: "[[Double]]")
        }
        return result
    }

    func safeGetInt64(_ key: Key) throws -> Int64 {
        // Yams parses all integer values as ints (sad)
        let asInt = try self.safeGetInt(key)
        return Int64(asInt)
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

    // NOTE: This assumes the input's time to be in GMT+2...
    func safeGetDate(_ key: Key, formatter: DateFormatter) throws -> Date {
        let dateDescription = try self.safeGetString(key)
        guard let result = formatter.date(from: dateDescription) else {
            throw ParseError.General(msg: "Invalid date '\(dateDescription)' for format: '\(String(describing: formatter.dateFormat))'")
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

