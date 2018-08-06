
import Foundation
import MapKit

class MapState {

    public static let defaultMapRegion = MKMapRectWorld

    public var tourCollection: TourCollectionOnMap

    public var visibleMapRegion: MKMapRect

    public static func restoreOrDefault() -> MapState {
        return MapState()
    }

    private init() {
        self.tourCollection = TourCollectionOnMap.empty
        self.visibleMapRegion = MapState.defaultMapRegion
        do {
            let defaults = UserDefaults.standard
            self.tourCollection = try TourCollectionOnMap.restore(from: defaults)
            self.visibleMapRegion = try MKMapRect.restore(from: defaults)
        } catch RestorationError.new(let message) {
            log.warning(message)
            setDefaultTours()
        } catch let error {
            log.error(error.localizedDescription)
        }
    }

    private func setDefaultTours() {
        let dao = MainDao()
        let tour = dao.getFirstTourWithAssociationsForMapping()
        if tour != nil {
            tourCollection = TourCollectionOnMap(tour: tour!)
        } else {
            log.error("Unable to retrieve any tour from the db.")
            tourCollection = TourCollectionOnMap.empty
        }
    }

    public func hasDefaultRegionSet() -> Bool {
        return MapState.isDefaultMapRegion(visibleMapRegion)
    }

    private static func isDefaultMapRegion(_ rect: MKMapRect) -> Bool {
        return MKMapRectEqualToRect(rect, MapState.defaultMapRegion)
    }

    public func persist() {
        let defaults = UserDefaults.standard
        tourCollection.save(to: defaults)
        visibleMapRegion.save(to: defaults)
        defaults.synchronize()
    }
}

fileprivate class Keys  {
    static let tourIds = "MapState.tourIds"
    static let coordX = "MapState.coordX"
    static let coordY = "MapState.coordY"
    static let mapWidth = "MapState.width"
    static let mapHeight = "MapState.height"
}

fileprivate enum RestorationError: Error {
    case new(String)
}

fileprivate extension MKMapRect {

    static func restore(from defaults: UserDefaults) throws -> MKMapRect {
        let x = try restoreDouble(from: defaults, key: Keys.coordX)
        let y = try restoreDouble(from: defaults, key: Keys.coordY)
        let w = try restoreDouble(from: defaults, key: Keys.mapWidth)
        let h = try restoreDouble(from: defaults, key: Keys.mapHeight)
        return MKMapRectMake(x, y, w, h)
    }

    private static func restoreDouble(from defaults: UserDefaults, key: String) throws -> Double {
        let result = defaults.double(forKey: key)
        guard result != Double(0) else {
            throw RestorationError.new("Unable to restore double value for map portion from user defaults, key: \(key)")
        }
        return result
    }

    func save(to defaults: UserDefaults) {
        defaults.set(self.origin.x, forKey: Keys.coordX)
        defaults.set(self.origin.y, forKey: Keys.coordY)
        defaults.set(self.size.width, forKey: Keys.mapWidth)
        defaults.set(self.size.height, forKey: Keys.mapHeight)
    }
}

fileprivate extension TourCollectionOnMap {

    static func restore(from defaults: UserDefaults) throws -> TourCollectionOnMap {
        let ids = try restoreTourIds(from: defaults)
        return try restoreTourCollection(ids: ids)
    }

    private static func restoreTourIds(from defaults: UserDefaults) throws -> [Int64] {
        guard let ids = defaults.array(forKey: Keys.tourIds) as? [Int64] else {
            throw RestorationError.new("Tour id values not restorable.")
        }
        return ids
    }

    private static func restoreTourCollection(ids: [Int64]) throws -> TourCollectionOnMap {
        let dao = MainDao()
        let toursUnwrapped = dao.getToursWithAssociationsForMapping(ids: ids)
        guard !toursUnwrapped.isEmpty else {
            throw RestorationError.new("Unable to restore tour collection from stored id values.")
        }
        return TourCollectionOnMap(tours: toursUnwrapped)
    }

    func save(to defaults: UserDefaults) {
        let ids = self.tours.map( { t in t.id  })
        defaults.set(ids, forKey: Keys.tourIds)
    }

}
