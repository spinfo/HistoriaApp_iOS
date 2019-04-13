
import Foundation
import UIKit

protocol TourDownloadActionsDelegate {
    func install(record: TourRecord)
    func remove(record: TourRecord)
}

class TourDownloadDialogBuilder {

    let delegate: TourDownloadActionsDelegate

    init(delegate: TourDownloadActionsDelegate) {
        self.delegate = delegate
    }

    func build(forRecord record: TourRecord, withStatus status: TourRecord.InstallStatus) -> UIAlertController {
        let dialog = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (TourDownloadViewHelper.shouldShowDeleteOption(status: status)) {
            dialog.addAction(buildDeleteAction(record: record))
        }
        dialog.addAction(buildInstallAction(record: record, status: status))
        dialog.addAction(buildCancelAction())
        return dialog
    }


    private func buildDeleteAction(record: TourRecord) -> UIAlertAction {
        return UIAlertAction(title: "Löschen", style: .destructive, handler: { _ in
            self.delegate.remove(record: record)
        })
    }

    private func buildInstallAction(record: TourRecord, status: TourRecord.InstallStatus) -> UIAlertAction {
        let title = TourDownloadViewHelper.determineInstallActionString(status: status)
        return UIAlertAction(title: title, style: .default, handler: { _ in
            self.delegate.install(record: record)
        })
    }

    private func buildCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
    }



}

