//
//  MasterDao.swift
//  HistoriaApp
//
//  Created by David on 25.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import GRDB
import SpeedLog

// For the moment we only use one dao for all db access
class MasterDao {

    // TODO This should probably be shared by multiple instances of the DAO
    private let dbQueue: DatabaseQueue

    init() {
        guard let queue = DatabaseHelper.getQueue() else {
            fatalError("Unable to establish a database connection.")
        }
        self.dbQueue = queue
    }

    public func getMapstops(forTour id: Int64) -> [Mapstop] {
        do {
            return try unsafeGetMapstops(forTour: id)
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve mapstops for tour (id: '\(id)'): \(error)")
            return []
        }
    }

    public func getPlace(id: Int64) -> Place? {
        do {
            return try unsafeGetPlace(id: id)
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve place (id: '\(id)'): \(error)")
            return nil
        }
    }

    public func getFirstTour() -> Tour? {
        do {
            return try self.dbQueue.inDatabase({ db in
                return try Tour.fetchOne(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve a single tour: \(error)")
            return nil
        }
    }

    public func getFirstArea() -> Area? {
        do {
            return try self.dbQueue.inDatabase({ db in
                return try Area.fetchOne(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve a single area: \(error)")
            return nil
        }
    }

    public func getTourCount(forAreaWithId id: Int64) -> Int  {
        do {
            return try self.dbQueue.inDatabase({ db in
                return try Tour.filter(Column("area_id") == id).fetchCount(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve a tour count for area \(id)")
            return 0
        }
    }

    public func getAreas() -> [Area] {
        do {
            return try self.dbQueue.inDatabase({ db in
                return try Area.fetchAll(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve a list of all areas")
            return []
        }
    }

    // TODO: Order by createdAt descending
    public func getTours(inAreaWIthId areaId: Int64) -> [Tour] {
        do {
            return try unsafeGetTours(inAreaWithId: areaId)
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve tours for area (id: '\(areaId)'): \(error)")
            return []
        }
    }

    public func getToursWithAssociationsForMapping(inAreaWithId id: Int64) -> [Tour] {
        do {
            let tours = try unsafeGetTours(inAreaWithId: id)
            // TODO: atm this introduces quadratic complexity (no of tours * no mapstops)
            //      and should be refactored
            for tour in tours {
                try self.unsafeSetAssociationsForMapping(on: tour)
            }
            return tours
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve tours for area (id: '\(id)'): \(error)")
            return []
        }
    }

    public func getTourWithAssociationsForMapping(id: Int64) -> Tour? {
        do {
            let tour = try unsafeGetTour(id: id)
            try self.unsafeSetAssociationsForMapping(on: tour)
            return tour
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve tour with associations: (id: '\(id)'): \(error)")
            return nil
        }
    }

    public func getPages(forMapstop id: Int64) -> [Page] {
        do {
            return try dbQueue.inDatabase({ db in
                return try Page.filter(Column("mapstop_id") == id).fetchAll(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve pages for mapstop (id: '\(id)'): \(error)")
            return []
        }
    }

    public func getMediaitems(forPageWithId id: Int64) -> [Mediaitem] {
        do {
            return try dbQueue.inDatabase({ db in
                return try Mediaitem.filter(Column("page_id") == id).fetchAll(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve mediaitems for page (id: '\(id)'): \(error)")
            return []
        }
    }

    // MARK: Tour installation

    // This performs all necessary checks and inserts or updates a tour in the db
    public func safeInstallTour(_ tour: Tour, in db: Database) throws {


        // keep a previous version of the tour's area for cleanup
        let previousArea = try Area.fetchOne(db, key: tour.area!.id)
        // save/update the area
        try tour.area!.point1!.insert(db)
        try tour.area!.point2!.insert(db)
        try tour.area!.insertOrUpdate(db)
        // if there was a previous area, it's points may now be safely deleted
        if previousArea != nil {
            try PersistableGeopoint.deleteAll(db, keys: [ previousArea!.point1Id, previousArea!.point2Id ])
        }

        // at this point we need a tour with a db referable id, so insert/update it
        try tour.insertOrUpdate(db)

        // update/insert the mapstops, overwriting where previous ones exist
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

        // update the tour track by removing all old coordinates and re-inserting the new ones
        if (tour.track != nil && tour.track!.count > 0) {
            try PersistableGeopoint.filter(Column("tour_id") == tour.id).deleteAll(db)
            for point in tour.track! {
                point.tour = tour
                try point.insert(db)
            }
        } else {
            SpeedLog.print("WARN", "Installing a tour without a track should never happen.")
        }

        // save the tour's lexicon entries
        for entry in tour.lexiconEntries {
            try entry.insertOrUpdate(db)
        }
    }

    // MARK: Private unsafe fetches
    // These fetch GRDB records, but might throw and thus are not exposed

    private func unsafeGetMapstops(forTour id: Int64) throws -> [Mapstop] {
        return try dbQueue.inDatabase({ db in
            return try Mapstop.filter(Column("tour_id") == id).fetchAll(db)
        })
    }

    private func unsafeGetTour(id: Int64) throws -> Tour {
        return try dbQueue.inDatabase({ db in
            return try Tour.fetchOne(db, key: id)!
        })
    }

    private func unsafeGetTours(inAreaWithId id: Int64) throws -> [Tour] {
        return try self.dbQueue.inDatabase({ db in
            return try Tour.filter(Column("area_id") == id).fetchAll(db)
        })
    }

    private func unsafeGetPlace(id: Int64) throws -> Place {
        return try dbQueue.inDatabase({ db in
            return try Place.fetchOne(db, key: id)!
        })
    }

    private func unsafeGetArea(id: Int64) throws -> Area {
        return try dbQueue.inDatabase({ db in
            return try Area.fetchOne(db, key: id)!
        })
    }

    private func unsafeGetTrack(tourId: Int64) throws -> [PersistableGeopoint] {
        return try dbQueue.inDatabase({ db in
            return try PersistableGeopoint.filter(Column("tour_id") == tourId).fetchAll(db)
        })
    }

    // set associations needed for map display on the given tour
    // NOTE: Very, very problematic. We should be able to at least fetch
    //      this without the loop over the mapstops
    private func unsafeSetAssociationsForMapping(on tour: Tour) throws {
        tour.mapstops = try unsafeGetMapstops(forTour: tour.id)

        for mapstop in tour.mapstops {
            mapstop.place = try unsafeGetPlace(id: mapstop.placeId)
        }
        tour.track = try unsafeGetTrack(tourId: tour.id)
    }
}

// Our own extension to GRDB Records
fileprivate extension Record {

    // Insert or update a record in the databse based on it's primary key
    // NOTE: Not very efficient, but should be seldom needed (on tour install mainly)
    func insertOrUpdate(_ db: Database) throws {
        if try self.exists(db) {
            SpeedLog.print("Updating: \(type(of: self))")
            try self.update(db)
        } else {
            SpeedLog.print("Inserting: \(type(of: self))")
            try self.insert(db)
        }
        
    }
}
