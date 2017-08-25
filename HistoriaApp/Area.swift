//
//  Area.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

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
    // TODO: Do not fetch eagerly
    // TODO: Order by createdAt descending
    var tours: Array<Tour> = Array()

    // One corner of the areas rectangle
    // TODO

    // Another corner of the areas rectangle
    // TODO

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
        id = row.value(named: "id")
        name = row.value(named: "name")
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["name"] = name
    }

}
