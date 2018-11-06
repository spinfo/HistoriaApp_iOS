//
//  Scene.swift
//  HistoriaApp
//
//  Created by David on 06.11.18.
//

import Foundation
import GRDB

public class SceneCoordinate : Record {

    var id: Int64 = 0

    var x: Float = 0.0

    var y: Float = 0.0

    var scene: Scene?

    var mapstop: Mapstop?

    override public class var databaseTableName: String {
        return "scene_coordinate"
    }

    public override init() {
        super.init()
    }

    public required init(row: Row) {
        id = row["id"]
        x = row["x"]
        y = row["y"]
        super.init(row: row)
    }

    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["x"] = x
        container["y"] = y
        container["scene_id"] = scene?.id
        container["mapstop_id"] = mapstop?.id
    }
}


// Data object for a Mapstop which is part of a Tour and has a place and a few html pages
public class Scene : Record {

    var id: Int64 = 0

    var pos: Int = 0

    var tour: Tour?

    var name: String = ""

    var title: String = ""

    var description: String = ""

    var excerpt: String = ""

    var src: String = ""

    var mapstops: Array<Mapstop> = Array()

    var coordinates: Array<SceneCoordinate> = Array()

    override public class var databaseTableName: String {
        return "scene"
    }

    public override init() {
        super.init()
    }

    public required init(row: Row) {
        id = row["id"]
        pos = row["pos"]
        name = row["name"]
        title = row["title"]
        description = row["description"]
        excerpt = row["excerpt"]
        src = row["src"]
        super.init(row: row)
    }

    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["pos"] = pos
        container["tour_id"] = tour?.id
        container["name"] = name
        container["title"] = title
        container["description"] = description
        container["except"] = excerpt
        container["src"] = src
    }

}
