
import UIKit

import XCGLogger

protocol DialogPresentationDelegate {
    func present(dialog: UIAlertController) -> Void
}

class TourDownloadTableViewCell: UITableViewCell, URLSessionDownloadDelegate, TourDownloadActionsDelegate  {

    @IBOutlet weak var tourName: UILabel!
    @IBOutlet weak var updateVersionLabel: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var installStatusImageView: UIImageView!

    // initialized by the client
    var tourRecord: TourRecord!
    var installStatus: TourRecord.InstallStatus!
    var dialogPresentationDelegate: DialogPresentationDelegate!

    // initialized lazily by us
    var dialogBuilder: TourDownloadDialogBuilder!

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
        case Removing
        case RemovalFailed
        case RemovalOk
    }

    private var status: DownloadStatus = .Idle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func setTourRecord(_ record: TourRecord) {
        tourRecord = record
        tourName.text = record.name
        progress.text = self.defaultProgressText(record: record)
        updateVersionLabel.text = TourDownloadViewHelper.formatUpdateVersionText(record.version, prefix: "Update: ")
    }

    public func setInstallStatus(_ status: TourRecord.InstallStatus) {
        installStatus = status
        installStatusImageView.image = TourDownloadViewHelper.determineImage(forStatus: status)
    }

    // update the progress depending on the provided status
    // marks the status as set
    private func updateProgress(_ status: DownloadStatus) {
        updateProgress(status, bytesWritten: 0)
    }

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
            text = "Installiert"
            setInstallStatus(.upToDate)
        case .Removing:
            text = "Wird entfernt..."
        case .RemovalFailed:
            text = "Entfernen gescheitert"
        case .RemovalOk:
            text = "Entfernt"
            setInstallStatus(.notInstalled)
        }

        DispatchQueue.main.async {
            self.progress.text = text
        }
    }

    public func toggle() {
        if (dialogBuilder == nil) {
            dialogBuilder = TourDownloadDialogBuilder(delegate: self)
        }
        let dialog = dialogBuilder.build(forRecord: tourRecord, withStatus: installStatus)
        dialogPresentationDelegate.present(dialog: dialog)
    }

    private func toggleTourDownload() {
        if self.status == .Running {
            return
        }

        guard tourRecord != nil else {
            log.error("No tour record to start download for")
            return
        }

        let backgroundSessionConfig =
            URLSessionConfiguration.background(withIdentifier: String(describing: tourRecord?.id))
        backgroundSession = URLSession(configuration: backgroundSessionConfig,
                                       delegate: self, delegateQueue: OperationQueue.main)

        guard let url = URL(string: tourRecord!.downloadUrl) else {
            log.error("Not a valid url: '\(String(describing: tourRecord?.downloadUrl))'")
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
            log.debug("Downloaded file to \(location.path)")
            self.updateProgress(.InstallingTour, bytesWritten: 0)
        } else {
            log.error("Downloaded file not at expected location: \(location.path)")
            self.updateProgress(.FailedDownloading, bytesWritten: 0)
            return
        }
        let tour = FileService.installTour(fromZipFile: location, tourRecord: self.tourRecord!)

        if tour != nil {
            log.debug("Tour installed: \(tour!.name)")
            self.updateProgress(.Installed, bytesWritten: 0)
        } else {
            log.error("Empty tour after handing to install")
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
        log.error("Download finished with error: \(String(describing: error))")
    }


    // -- MARK: TourDownloadActionsDelegate

    func install(record: TourRecord) {
        toggleTourDownload()
    }

    func remove(record: TourRecord) {
        log.debug("Will remove tour: \(record.name)")
        updateProgress(.Removing)
        DispatchQueue.main.async {
            let result = FileService.removeTour(withId: record.tourId)
            self.updateProgress(result ? .RemovalOk : .RemovalFailed)
        }

    }

    // -- MARK: Private methods

    private func defaultProgressText(record: TourRecord) -> String {
        return TourDownloadViewHelper.formatFileSize(bytesAmount: record.downloadSize)
    }

}
