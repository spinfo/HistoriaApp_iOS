//
//  Place.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

class Place {
    
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
    
}
