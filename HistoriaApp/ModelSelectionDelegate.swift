//
//  ModelSelectionDelegate.swift
//  HistoriaApp
//
//  Created by David on 19.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

protocol TourSelectionDelegate {
    func tourSelected(_ tour: Tour) -> Void
}

protocol AreaSelectionDelegate {
    func areaSelected(_ area: Area) -> Void
}

protocol ModelSelectionDelegate: TourSelectionDelegate, AreaSelectionDelegate {

}
