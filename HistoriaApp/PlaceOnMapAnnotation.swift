
import Foundation

import Mapbox

// A simple wrapper a mapox annotation allowing for the connection from
// annotation to the mapstop and the place on map
class PlaceOnMapAnnotation : MGLPointAnnotation {

    public var placeOnMap: PlaceOnMap?

    // TODO: Needed?
    /*
    private static let MARKER_ICON_START = UIImage(named: "MarkerIconRed")
    private static let MARKER_ICON_DEFAULT = UIImage(named: "MarkerIconBlue")
    private static let MARKER_SIZE = CGSize(width: 40, height: 40)
    private static let MARKER_OFFSET = CGPoint(x: 0, y: 20)
    public static let ANNOTATION_OFFSET = CGPoint(x: 0, y: -20)
     */

    func annotationImage(reuseFrom mapView: MGLMapView) -> MGLAnnotationImage {
        let image = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseId())
        if (image == nil) {
            return createAnnotationImage()
        }
        return image!
    }

    private func createAnnotationImage() -> MGLAnnotationImage {
        if self.placeOnMap!.hasTourBeginMapstop {
            return MGLAnnotationImage(image: #imageLiteral(resourceName: "MarkerIconRed"), reuseIdentifier: reuseId())
        } else {
            return MGLAnnotationImage(image: #imageLiteral(resourceName: "MarkerIconBlue"), reuseIdentifier: reuseId())
        }
    }

    private func reuseId() -> String {
        if self.placeOnMap!.hasTourBeginMapstop {
            return "icon-start"
        } else {
            return "icon-default"
        }
    }

}
