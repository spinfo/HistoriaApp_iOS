
import Foundation

import GRDB
import MapKit

public class Mapstop : Record {

    // the backend's id for this mapstop
    var id: Int64 = 0

    // the place this mapstop is displayed on
    var placeId: Int64 = 0
    var place: Place?

    // the tour this mapstop belongs to
    var tour: Tour?

    // the mapstop's name as shown to the user
    var name: String = ""

    // a short description of the mapstop shown to the user
    var description: String = ""

    // the mapstops main content: (html) pages
    var pages: Array<Page> = Array()

    var coordinate: CLLocationCoordinate2D {
        return place!.coordinate
    }

    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "mapstop"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row["id"]
        name = row["name"]
        description = row["description"]
        placeId = row["place_id"]
        // pages = Page.filter( == id)
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["place_id"] = place?.id
        container["tour_id"] = tour?.id
        container["name"] = name
        container["description"] = description
    }
}
