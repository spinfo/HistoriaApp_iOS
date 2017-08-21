//
//  DatabaseHelper.swift
//  HistoriaApp
//
//  Created by David on 21.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import GRDB

// This performs basic operations having to do with the database in general,
// e.g. setting up the database or tearing it down
class DatabaseHelper {
    
    public class func testRun(tour: Tour) {
        do {
            
            let dbFileURL = FileService.getDBFile()!
            
            // reset by deleting db file
            try FileManager().removeItem(at: dbFileURL)
            
            let dbQueue = try DatabaseQueue(path: dbFileURL.path)
            
            print(dbQueue.configuration)
            
            try dbQueue.inDatabase({ db in
                
                try db.create(table: "page", body: { t in
                    t.column("id", .integer).primaryKey()
                    t.column("pos", .integer)
                    t.column("guid", .text).unique()
                    t.column("content", .text)
                })
                
                let page = tour.mapstops.first!.pages.first!
                try page.insert(db)
                
                let page2 = try Page.fetchOne(db, key: ["guid": page.guid])
                print("page: \(page2!.guid)")
            })
            
        } catch {
            print("Failed to test database: \(error)")
        }
    }
    
    
}
