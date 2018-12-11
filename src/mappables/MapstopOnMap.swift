
import Foundation

// A wrapper for a mapstop's state on the map
public class MapstopOnMap {

    // the mapstop this wraps on the map
    let mapstop: Mapstop

    // Whether this mapstop is the first in it's tour
    var isFirstInTour: Bool

    var title: String {
        return mapstop.name
    }

    var subtitle: String {
        return mapstop.description
    }

    var tourTitle: String? {
        return mapstop.tour?.name
    }

    init(_ mapstop: Mapstop) {
        self.mapstop = mapstop
        self.isFirstInTour = false
    }

}
