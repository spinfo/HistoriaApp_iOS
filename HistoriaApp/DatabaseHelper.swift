
import Foundation

import GRDB
import XCGLogger

// This performs basic operations having to do with the database in general,
// e.g. setting up the database or tearing it down
class DatabaseHelper {

    private static var theQueue: DatabaseQueue?

    // TODO: Move to Dao
    public class func save(tour: Tour) -> Bool {
        do {
            let dbQueue = getQueue()!
            try dbQueue.inDatabase({ db in
                try MasterDao().safeInstallTour(tour, in: db)
            })
        } catch {
            log.error("Failed to install tour: \(error)")
            return false
        }
        return true
    }

    // Sets up the database with tables, if no database is present or
    // if not at least one area and one tour is retrievable
    // Returns true if a database is available or false if something went
    // awry
    // TODO: GRDB seems to support a "DatabasMigrator" that might better be used here
    public class func initDB() -> Bool {

        var hasMinimumEntities = false
        do {
            // initialize the queue as it might not have been
            guard let localQueue = getQueue() else {
                log.error("Unable to get the db queue.")
                return false
            }
            try localQueue.inDatabase({ db in
                let numAreas = try Area.fetchCount(db)
                let numTours = try Tour.fetchCount(db)
                hasMinimumEntities = (numAreas > 0 && numTours > 0)
            })
        } catch {
            hasMinimumEntities = false
        }

        if !hasMinimumEntities {
            guard let localQueue = getQueue() else {
                log.error("Unable to get the db queue.")
                return false
            }
            log.info("Minimum db requirements not met, (re-)installing db.")
            do {
                try localQueue.inDatabase({ db in
                    try createTables(in: db)
                })
            } catch {
                log.error("Could not create tables: \(error)")
                return false
            }
            guard let _ = FileService.installExampleTour() else {
                log.error("Error on installing the example tour.")
                return false
            }
        }

        return true
    }

    public class func getQueue() -> DatabaseQueue? {
        if theQueue == nil {
            guard let dbFileURL = FileService.getDBFile() else {
                log.error("Unable to determine a database file.")
                return nil
            }

            do {
                theQueue = try DatabaseQueue(path: dbFileURL.path)
                // setup our database queue to release memory if asked for by the os
                theQueue?.setupMemoryManagement(in: UIApplication.shared)
            } catch {
                log.error("Unable to establish database queue: \(error)")
                return nil
            }
        }
        return theQueue
    }

    // create all tables needed for the application
    // will not delete existing tables
    private class func createTables(in db: Database) throws {

        // the geopoints tour id is defined below (because the tour table does not exist atm)
        try db.create(table: "geopoint", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(autoincrement: true)
            t.column("latitude", .double)
            t.column("longitude", .double)
        })

        try db.create(table: "area", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("name", .text)
            t.column("point1_id", .integer).references("geopoint")
            t.column("point2_id", .integer).references("geopoint")
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

        // add tour id to geopoints now that the table is created
        try db.alter(table: "geopoint", body: { t in
            t.add(column: "tour_id", .integer).references("tour", onDelete: .cascade)
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

        try db.create(table: "lexiconentry", ifNotExists: true, body: { t in
            t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
            t.column("title", .text)
            t.column("content", .text)
        })
    }

}

