
import Foundation
import UIKit

class TourDownloadViewHelper {


    class func determineImage(forStatus status: TourRecord.InstallStatus) -> UIImage {
        switch status {
        case .upToDate:
            return #imageLiteral(resourceName: "TourDownloadUpToDate")
        case .notInstalled:
            return #imageLiteral(resourceName: "TourDownloadDownload")
        case .updateAvailable:
            return #imageLiteral(resourceName: "TourDownloadUpdate")
        }
    }

    class func determineInstallActionString(status: TourRecord.InstallStatus) -> String {
        switch status {
        case .upToDate:
            return "Erneut installieren"
        case .notInstalled:
            return "Installieren"
        case .updateAvailable:
            return "Update"
        }
    }

    class func formatUpdateVersionText(_ version: Int, prefix: String) -> String {
        guard version > 0 else {
            return ""
        }
        guard let interval = TimeInterval(exactly: version) else {
            log.error("Cannot format date from timestamp: \(version)")
            return ""
        }
        let date = Date(timeIntervalSince1970: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return prefix + dateFormatter.string(from: date)
    }

    class func formatFileSize(bytesAmount: Int) -> String {
        return String(format: "%.2f MB", (Float(bytesAmount) / 1000000))
    }

    class func shouldShowDeleteOption(status: TourRecord.InstallStatus) -> Bool {
        return status != .notInstalled
    }

}
