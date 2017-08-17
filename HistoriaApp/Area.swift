//
//  Area.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

// An area basically is a name connected to a geographic rectangle.
// Tours take place in an area.
public class Area {
    
    // the backend's id for this area
    var id: UInt64 = 0
    
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
    
    
}
