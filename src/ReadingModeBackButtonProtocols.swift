//
//  ReadingModeBackButtonProtocols.swift
//  HistoriaApp
//
//  Created by David on 17.08.18.
//

import Foundation

protocol ReadingModeBackButtonDisplay {
    func showBackButton()
    func hideBackButton()
}

protocol ReadingModeBackButtonUser {
    var backButtonDisplay: ReadingModeBackButtonDisplay? { get set }
    func backButtonPressed()
}
