
import Foundation
import UIKit


class ReadingModeMapstopListController : UITableViewController, ReadingModeBackButtonUser {

    var backButtonDisplay: ReadingModeBackButtonDisplay?

    var mapstopSelectionDelegate: MapstopSelectionDelegate?

    var mapstops: [Mapstop] = Array()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButtonDisplay?.showBackButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButtonDisplay?.hideBackButton()
    }

    func backButtonPressed() {
        return
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapstops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "mapstopTableCell")! as! ReadingModeMapstopListTableViewCell

        let mapstop = getMapstop(at: indexPath)
        cell.setValues(with: mapstop, at: (indexPath.row + 1))

        cell.layoutIfNeeded()
        return cell
    }

    private func getMapstop(at indexPath: IndexPath) -> Mapstop {
        return mapstops[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapstopSelectionDelegate?.mapstopSelected(getMapstop(at: indexPath))
    }

}

class ReadingModeMapstopListTableViewCell : UITableViewCell {

    @IBOutlet weak var mapstopTitle: UILabel!

    @IBOutlet weak var mapstopDescription: UILabel!

    func setValues(with mapstop: Mapstop?, at pos: Int) {
        guard mapstop != nil else {
            return
        }
        mapstopTitle?.text = mapstopTitle(mapstop!, at: pos)
        mapstopDescription?.text = mapstop!.description
    }

    private func mapstopTitle(_ mapstop: Mapstop, at pos: Int) -> String {
        return String(format: "%d. %@", pos, mapstop.name)
    }
}

