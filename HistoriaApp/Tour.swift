
import Foundation

import GRDB

public class Tour : Record {

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
    var track: [PersistableGeopoint]?

    // point of creation in the backend's db assumed to be in GMT+2
    var createdAt: Date = Date()
    static let creationDateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 2)
        return formatter
    }

    // a tour might have Lexicon entries associated during installation
    // the connection to those is however not persisted
    var lexiconEntries: [LexiconEntry] = Array()

    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "tour"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row["id"]
        version = row["version"]
        name = row["name"]
        type = TourType(rawValue: row["type"])!
        walkLength = row["walkLength"]
        duration = row["duration"]
        tagWhat = row["tagWhat"]
        tagWhen = row["tagWhen"]
        tagWhere = row["tagWhere"]
        accessibility = row["accessibility"]
        author = row["author"]
        intro = row["intro"]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["area_id"] = area?.id
        container["version"] = version
        container["name"] = name
        container["type"] = type.rawValue
        container["walkLength"] = walkLength
        container["duration"] = duration
        container["tagWhat"] = tagWhat
        container["tagWhen"] = tagWhen
        container["tagWhere"] = tagWhere
        container["accessibility"] = accessibility
        container["author"] = author
        container["intro"] = intro
    }

}
