//
//  DatabaseHelper.swift
//  HistoriaApp
//
//  Created by David on 21.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import GRDB
import SpeedLog

// This performs basic operations having to do with the database in general,
// e.g. setting up the database or tearing it down
class DatabaseHelper {

    // TODO: Remove this
    public class func testRun(tour: Tour) {
        do {

            let dbFileURL = FileService.getDBFile()!

            // reset by deleting db file
            try FileManager().removeItem(at: dbFileURL)

            let dbQueue = try DatabaseQueue(path: dbFileURL.path)

            try dbQueue.inDatabase({ db in

                try DatabaseHelper.createTables(in: db)

                let mapstop = tour.mapstops.first!
                let page = mapstop.pages.first!

                try DatabaseHelper.safeInstallTour(tour, in: db)

                let page2 = try Page.fetchOne(db, key: ["guid": page.guid])
                let mapstop2 = try Mapstop.fetchOne(db, key: mapstop.id)
                let tour2 = try Tour.fetchOne(db)
                let area2 = try Area.fetchOne(db)

                let counts = try [ Area.fetchCount(db),
                                   Place.fetchCount(db),
                                   Tour.fetchCount(db),
                                   Mapstop.fetchCount(db),
                                   Page.fetchCount(db),
                                   Mediaitem.fetchCount(db) ]

                SpeedLog.print("page: \(page2!.guid)")
                SpeedLog.print("page: \(page.id) == \(page2?.id)")
                SpeedLog.print("stop: \(mapstop2?.name)")
                SpeedLog.print("area: \(area2?.name)")
                SpeedLog.print("tour: \(tour2?.name)")

                SpeedLog.print("count: \(counts)")


            })

        } catch {
            SpeedLog.print("ERROR", "Failed to test database: \(error)")
        }
    }


    // MARK: Private methods

    // This performs all necessary checks and inserts or updates a tour in the db
    private class func safeInstallTour(_ tour: Tour, in db: Database) throws {
        try tour.area!.insertOrUpdate(db)
        try tour.insertOrUpdate(db)

        for mapstop: Mapstop in tour.mapstops {

            try mapstop.place!.insertOrUpdate(db)
            try mapstop.insertOrUpdate(db)

            for page in mapstop.pages {
                try page.insertOrUpdate(db)

                for mediaitem in page.media {
                    // a mediaitem only needs to be inserted if it is not present already
                    // for it's page
                    let sql = "SELECT * FROM mediaitem WHERE guid = ? AND page_id = ?"
                    let present = try Mediaitem.fetchAll(db, sql, arguments: [mediaitem.guid, page.id])
                    // do the insert if neccessary
                    if present.isEmpty {
                        try mediaitem.insert(db)
                    }
                }
            }
        }
    }

    // create all tables neede for the application
    private class func createTables(in db: Database) throws {

        try db.create(table: "area", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("name", .text)
        })

        try db.create(table: "place", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("area_id", .integer).references("area", onDelete: .cascade)
            t.column("lat", .double)
            t.column("lon", .double)
            t.column("name", .text)
        })

        try db.create(table: "tour", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("area_id", .integer).references("area", onDelete: .cascade)
            t.column("version", .integer)
            t.column("name", .text)
            t.column("type", .text)
            t.column("walkLength", .integer)
            t.column("duration", .integer)
            t.column("tagWhat", .text)
            t.column("tagWhen", .text)
            t.column("tagWhere", .text)
            t.column("accessibility", .text)
            t.column("author", .text)
            t.column("intro", .text)
        })

        try db.create(table: "mapstop", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("place_id", .integer).references("place", onDelete: .restrict)
            t.column("tour_id", .integer).references("tour", onDelete: .cascade)
            t.column("name", .text)
            t.column("description", .text)
        })

        try db.create(table: "page", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("mapstop_id", .integer).references("mapstop", onDelete: .cascade)
            t.column("pos", .integer)
            t.column("guid", .text).unique()
            t.column("content", .text)
        })

        try db.create(table: "mediaitem", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(autoincrement: true)
            t.column("guid", .text)
            t.column("page_id", .integer).references("page", onDelete: .cascade)
        })
    }

}

// Our own extension to GRDB Records
fileprivate extension Record {

    // Insert or update a record in the databse based on it's primary key
    // NOTE: Not very efficient, but should be seldom needed (on tour install mainly)
    func insertOrUpdate(_ db: Database) throws {
        if try self.exists(db) {
            try self.update(db)
        } else {
            try self.insert(db)
        }
        
    }
    
}

