
import Foundation

import GRDB

// An area basically is a name connected to a geographic rectangle.
// Tours take place in an area.
public class Area : Record {

    // the backend's id for this area
    var id: Int64 = 0

    // the name of the area as displayed to the user
    var name: String = ""

    // the tours taking place in this area
    var tours: Array<Tour> = Array()

    // One corner of the areas rectangle
    var point1Id: Int64 = 0
    var point1: PersistableGeopoint?

    // Another corner of the areas rectangle
    var point2Id: Int64 = 0
    var point2: PersistableGeopoint?

    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "area"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row["id"]
        name = row["name"]
        point1Id = row["point1_id"]
        point2Id = row["point2_id"]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["name"] = name
        container["point1_id"] = point1?.id
        container["point2_id"] = point2?.id
    }

}
