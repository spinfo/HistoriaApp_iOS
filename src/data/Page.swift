
import Foundation

import GRDB

// A page is a piece of html optionally linking to mediaitems, shown for
// a mapstop (together with other pages)
public class Page : Record {

    // the backend's id value for this page
    var id: Int64 = 0

    // the unique url that identifies this page on the backend
    var guid: String = ""

    // the page's position in a series of pages
    var pos: Int = 0

    // the page's html content
    var content: String = ""

    // the mediaitems linked from this page
    var media: Array<Mediaitem> = Array()

    // the mapstop this page is meant for
    var mapstop: Mapstop?

    // get the actual content that should be displayed for the page
    func getPresentationContent() -> String {
        let dao = MainDao()
        let media = dao.getMediaitems(forPageWithId: self.id)
        let localContent = HtmlContentCompletion.replaceMediaitems(in: self.content, media: media)
        return HtmlContentCompletion.wrapInPage(localContent)
    }

    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "page"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row["id"]
        guid = row["guid"]
        pos = row["pos"]
        content = row["content"]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["mapstop_id"] = mapstop?.id
        container["guid"] = guid
        container["pos"] = pos
        container["content"] = content
    }
}
