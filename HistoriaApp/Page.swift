//
//  Page.swift
//  HistoriaApp
//
//  Created by David on 14.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

// A page is a piece of html optionally linking to mediaitems, shown for
// a mapstop (together with other pages)
public class Page {
    
    // the backend's id value for this page
    var id: UInt64 = 0
    
    // the unique url that identifies this page on the backend
    var guid: String = ""
    
    // the page's position in a series of pages
    var pos: Int = 0
    
    // the page's html content
    var content: String = ""
    
    // the mediaitems linked from this page
    var media: Array<Mediaitem> = Array()
    
    // the mapstop this page is meant for
    var mapstop: Mapstop?
    
    
}
