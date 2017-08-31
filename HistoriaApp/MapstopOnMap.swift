//
//  MapstopOnMap.swift
//  HistoriaApp
//
//  Created by David on 30.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

// A wrapper for a mapstop's state on the map
public class MapstopOnMap {

    // the mapstop this wraps on the map
    var mapstop: Mapstop

    // Whether this mapstop is the first in it's tour
    var isFirstInTour: Bool

    init(_ mapstop: Mapstop) {
        self.mapstop = mapstop
        self.isFirstInTour = false
    }

}
