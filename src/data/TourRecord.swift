
import Foundation

class TourRecord {

    public enum InstallStatus {
        case notInstalled
        case updateAvailable
        case upToDate
    }

    // id of the record (not the tour) assigned by the server
    var id: Int64 = 0

    // the publishing timestamp issued by the server
    var version: Int = 0

    // name of the tour as shown to the user (same as the name of the tour
    // that will be downloaded)
    var name: String = ""

    // id of the tour that this record references
    var tourId: Int64 = 0

    // the area that the tour is part of
    var areaId: Int64 = 0

    // the name of the tour's area as to be shown to the user
    var areaName: String = ""

    // the url by which the tour may be downloaded
    var downloadUrl: String = ""

    // the size of the tour content download in bytes
    var downloadSize: Int = 0

    init() {}

}
