
import Foundation

protocol MapstopSelectionDelegate {
    func mapstopSelected(_ mapstop: Mapstop) -> Void
}

protocol TourSelectionDelegate {
    func tourSelectedForPreview(_ tour: Tour) -> Void
    func tourSelected(_ tour: Tour) -> Void
    func tourPreviewAborted() -> Void
}

protocol AreaSelectionDelegate {
    func areaSelected(_ area: Area) -> Void
}

protocol ModelSelectionDelegate: TourSelectionDelegate, AreaSelectionDelegate, MapstopSelectionDelegate {

}
