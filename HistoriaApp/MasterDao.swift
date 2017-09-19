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

    public func getTours(inAreaWIthId areaId: Int64) -> [Tour]? {
        do {
            return try self.dbQueue.inDatabase({ db in
                return try Tour.filter(Column("area_id") == areaId).fetchAll(db)
            })
        } catch {
            SpeedLog.print("ERROR", "Unable to retrieve tours for area (id: '\(areaId)'): \(error)")
            return nil
        }
    }

    public func getTourWithAssociationsForMapping(id: Int64) -> Tour? {
        do {
            let tour = try unsafeGetTour(id: id)
            tour.mapstops = try unsafeGetMapstops(forTour: id)

            // problmatic, could be fetched in one go, then assigned
            for mapstop in tour.mapstops {
                mapstop.place = try unsafeGetPlace(id: mapstop.placeId)
            }
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

    private func unsafeGetPlace(id: Int64) throws -> Place {
        return try dbQueue.inDatabase({ db in
            return try Place.fetchOne(db, key: id)!
        })
    }

}
