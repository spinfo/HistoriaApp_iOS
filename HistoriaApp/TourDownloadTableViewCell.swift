
import UIKit

import SpeedLog

class TourDownloadTableViewCell: UITableViewCell, URLSessionDownloadDelegate  {

    @IBOutlet weak var tourName: UILabel!

    @IBOutlet weak var areaName: UILabel!

    @IBOutlet weak var progress: UILabel!

    var tourRecord: TourRecord?

    var downloadTask: URLSessionDownloadTask?

    var backgroundSession: URLSession?

    private enum DownloadStatus {
        case Idle
        case Running
        case Stopped
        case FailedDownloading
        case InstallingTour
        case FailedInstalling
        case Installed
    }

    private var status: DownloadStatus = .Idle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func setTourRecord(_ record: TourRecord) {
        self.tourRecord = record
        self.tourName.text = record.name
        self.areaName.text = record.areaName
        self.progress.text = self.defaultProgressText(record: record)
    }

    // update the progress depending on the provided status
    // marks the status as set
    private func updateProgress(_ status: DownloadStatus, bytesWritten: Int64) {
        self.status = status

        let text: String

        switch self.status {
        case .Idle:
            text = self.defaultProgressText(record: self.tourRecord!)
        case .Running:
            let percent = Int(Float(bytesWritten)/Float(tourRecord!.downloadSize) * 100)
            text = "\(percent) % von " + defaultProgressText(record: self.tourRecord!)
        case .Stopped:
            text = "Gestoppt..."
        case .InstallingTour:
            text = "Installiere..."
        case .FailedDownloading:
            text = "Download fehlgeschlagen"
        case .FailedInstalling:
            text = "Installation fehlgeschlagen"
        case .Installed:
            text = "OK"
        }

        DispatchQueue.main.async {
            self.progress.text = text
        }
    }

    public func toggleTourDownload() {
        // TODO: Handle stop and restart
        if self.status == .Running {
            return
        }

        guard tourRecord != nil else {
            SpeedLog.print("ERROR", "No tour record to start download for")
            return
        }

        let backgroundSessionConfig =
            URLSessionConfiguration.background(withIdentifier: String(describing: tourRecord?.id))
        backgroundSession = URLSession(configuration: backgroundSessionConfig,
                                       delegate: self, delegateQueue: OperationQueue.main)

        guard let url = URL(string: tourRecord!.downloadUrl) else {
            SpeedLog.print("ERROR", "Not a valid url: '\(tourRecord?.downloadUrl)'")
            return
        }
        downloadTask = backgroundSession?.downloadTask(with: url)
        downloadTask?.resume()
        self.status = .Running
    }

    // MARK: -- URLSessionDownloadDelegate

    // Attempt to install the tour after a successfull download
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if FileManager.default.fileExists(atPath: location.path) {
            SpeedLog.print("INFO", "Downloaded file to \(location.path)")
            self.updateProgress(.InstallingTour, bytesWritten: 0)
        } else {
            SpeedLog.print("ERROR", "Downloaded file not at expected location: \(location.path)")
            self.updateProgress(.FailedDownloading, bytesWritten: 0)
            return
        }
        let tour = FileService.installTour(fromZipFile: location, tourRecord: self.tourRecord!)

        if tour != nil {
            SpeedLog.print("INFO", "Tour installed: \(tour!.name)")
            self.updateProgress(.Installed, bytesWritten: 0)
        } else {
            SpeedLog.print("ERROR", "Empty tour after handing to install")
            self.updateProgress(.FailedInstalling, bytesWritten: 0)
        }
    }

    // Update the progress during the download
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.updateProgress(.Running, bytesWritten: totalBytesWritten)
    }

    // Handle an error (on downoload end)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // we might get nil on a successfull download
        if error == nil {
            return
        }
        self.updateProgress(.FailedDownloading, bytesWritten: 0)
        SpeedLog.print("ERROR", "Download finished with error: \(error)")
    }

    // -- MARK: Private methods

    private func defaultProgressText(record: TourRecord) -> String {
        return "ca. \(record.downloadSize / 1000000) MB"
    }

}
