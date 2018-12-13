
import Foundation

class AreaDownloadStatus {

    let areaId: Int64

    let name: String

    var downloadedToursAmount: Int = 0

    var downloadedTourSize: Int64 = 0

    var lastVersion: Int = 0

    var tourRecords: [TourRecord] = Array()

    var downloadableToursAmount: Int {
        get { return tourRecords.count }
    }

    private var tourIds: Set<Int64> = Set()

    private let installedTourIds: Set<Int64>

    init(areaId: Int64, name: String, records: [TourRecord]) {
        self.areaId = areaId
        self.name = name
        self.installedTourIds = MainDao().getTourIds(inAreaWithId: areaId)
        addRecords(records)
    }

    private func addRecords(_ records: [TourRecord]) {
        records.forEach({ record in addRecord(record) })
    }

    private func addRecord(_ record: TourRecord) {
        guard (!tourIds.contains(record.tourId)) else {
            log.warning("Attempt to add a tour record twice. Id: \(record.id)")
            return
        }
        guard (record.areaId == areaId) else {
            log.warning("Attempt to add a record belonging to the wrong area, \(record.areaId) != \(areaId)")
            return
        }

        tourIds.insert(record.tourId)
        tourRecords.append(record)
        incrementValues(using: record)
    }

    private func incrementValues(using record: TourRecord) {
        if (installedTourIds.contains(record.tourId)) {
            downloadedToursAmount += 1
            downloadedTourSize += Int64(record.downloadSize)
        }
        if (lastVersion < record.version) {
            lastVersion = record.version
        }
    }

}


