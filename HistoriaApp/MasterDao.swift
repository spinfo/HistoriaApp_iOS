//
//  MasterDao.swift
//  HistoriaApp
//
//  Created by David on 25.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import GRDB

class MasterDao {

    private let dbQueue: DatabaseQueue

    init() {
        do {
            self.dbQueue = try DatabaseQueue(path: FileService.getDBFile()!.path)
        } catch {
            fatalError("Unable to build a database connection: \(error)")

        }
    }

    public func getMapstops(forTour id: Int64) -> [Mapstop] {
        do {
            return try dbQueue.inDatabase({ db in
                return try Mapstop.filter(Column("tour_id") == id).fetchAll(db)
            })
        } catch {
            print("Unable to retrieve mapstops for tour (id: '\(id)'): \(error)")
            return []
        }
    }

    public func getPlace(id: Int64) -> Place? {
        do {
            return try dbQueue.inDatabase({ db in
                return try Place.fetchOne(db, key: id)
            })
        } catch {
            print("Unable to retrieve place (id: \(id): \(error)")
            return nil
        }
    }
    
}
