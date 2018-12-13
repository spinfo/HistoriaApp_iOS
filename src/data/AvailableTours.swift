
import Foundation

class AvailableTours {

    var recordsByAreaId: [Int64 : [TourRecord]]

    init() {
        recordsByAreaId = Dictionary()
    }

    convenience init(_ records: [TourRecord]) {
        self.init()
        addAll(records)
    }

    func addAll(_ records: [TourRecord]) {
        records.forEach({ record in add(record) })
    }

    func add(_ record: TourRecord) {
        var records = recordsByAreaId[record.areaId]
        if (records == nil) {
            records = Array()
        }
        records!.append(record)
        recordsByAreaId[record.areaId] = records!
    }

    func getRecords(in areaId: Int64) -> [TourRecord] {
        let result = recordsByAreaId[areaId]
        return result == nil ? Array() : result!
    }

    func buildAreaDownloadStatus() -> [AreaDownloadStatus] {
        return recordsByAreaId.map({ (areaid, records) in
            return AreaDownloadStatus(areaId: areaid, name: records[0].areaName, records: records)
        })
    }
}

