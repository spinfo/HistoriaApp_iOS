
import Foundation

protocol TourSelectionDelegate {
    func tourSelected(_ tour: Tour) -> Void
}

protocol AreaSelectionDelegate {
    func areaSelected(_ area: Area) -> Void
}

protocol ModelSelectionDelegate: TourSelectionDelegate, AreaSelectionDelegate {

}
