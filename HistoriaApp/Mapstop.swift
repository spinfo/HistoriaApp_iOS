//
//  Mapstop.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

public class Mapstop {
    
    // the backend's id for this mapstop
    var id: Int64 = 0
    
    // the place this mapstop is displayed on
    var place: Place?
    
    // the tour this mapstop belongs to
    var tour: Tour?
    
    // the mapstop's name as shown to the user
    var name: String = ""
    
    // a short description of the mapstop shown to the user
    var description: String = ""
    
    // the mapstops main content: (html) pages
    var pages: Array<Page> = Array()
    
}
