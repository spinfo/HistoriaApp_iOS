
import Foundation

import GRDB

public class Mediaitem : Record {

    // TODO: a simple id generated by the db
    var id: Int64 = 0

    // A url (wordpress guid) via which the mediaitem may be identified
    // NOTE: This is unique on the backend, but may exist multiple times
    //       in the app's db. (Though only once for each page
    // TODO: Ensure that the combination of page and guid is unique
    var guid: String = ""

    // the page this media item belongs to
    var page: Page?


    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "mediaitem"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row.value(named: "id")
        guid = row.value(named: "guid")
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["page_id"] = page?.id
        container["guid"] = guid
    }

    /// Update id after a successful insert
    override public func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
