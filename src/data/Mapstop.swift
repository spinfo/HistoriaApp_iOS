
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

    // the mapstop's position in the tour
    var pos: Int = 0

    // A mapstop might belong to a scene if it is part of an indoor tour
    var scene: Scene?

    // A mapstop might have a scene coordinate if it is part of an indoor tour
    var sceneCoordinate: SceneCoordinate?

    var sceneType: String = ""

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
        pos = row["pos"]
        sceneType = row["scene_type"]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["place_id"] = place?.id
        container["tour_id"] = tour?.id
        container["name"] = name
        container["description"] = description
        container["pos"] = pos
        container["scene_id"] = scene?.id
        container["scene_coordinate_id"] = sceneCoordinate?.id
        container["scene_type"] = sceneType
    }

    public func isBeforeInSceneOrPosition(to other: Mapstop) -> Bool {
        guard (self.scene != nil && other.scene != nil) else {
            log.warning("Compring two mapstops without scene positions.")
            return self.pos < other.pos
        }
        if (self.scene!.pos == other.scene!.pos) {
            return self.pos < other.pos
        }
        return self.scene!.pos < other.scene!.pos
    }
}
