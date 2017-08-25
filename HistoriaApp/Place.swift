//
//  Place.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import GRDB

class Place : Record {

    // the place's id as given by the backend
    var id: Int64 = 0

    // the geographical latitude (WGS 84)
    var lat: Double = 0

    // the geographical longitude (WGS 84)
    var lon: Double = 0

    // the place's name
    var name: String = ""

    // the place's area
    var area: Area?

    // TODO: Method to get a geographical point, maybe as a "computed property" (cf. swift guide)


    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "place"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row.value(named: "id")
        lat = row.value(named: "lat")
        lon = row.value(named: "lon")
        name = row.value(named: "name")
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["area_id"] = area?.id
        container["lat"] = lat
        container["lon"] = lon
        container["name"] = name
    }
}
