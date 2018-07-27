
import Foundation

protocol MapstopSelectionDelegate {
    func mapstopSelected(_ mapstop: Mapstop) -> Void
}

protocol TourSelectionDelegate {
    func tourSelected(_ tour: Tour) -> Void
}

protocol AreaSelectionDelegate {
    func areaSelected(_ area: Area) -> Void
}

protocol ModelSelectionDelegate: TourSelectionDelegate, AreaSelectionDelegate, MapstopSelectionDelegate {

}
