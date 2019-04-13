//
//  SceneCoordinate.swift
//  HistoriaApp
//
//  Created by David on 29.11.18.
//

import Foundation
import GRDB
import UIKit

public class SceneCoordinate : Record {

    private static let originalSurfaceSize = CGSize (width: 960.0, height: 720.0)

    var id: Int64 = 0

    var x: Double = 0.0
    var y: Double = 0.0

    var sceneId: Int64 = 0
    var scene: Scene?

    var mapstopId: Int64 = 0
    var mapstop: Mapstop?

    override public class var databaseTableName: String {
        return "scene_coordinate"
    }

    public override init() {
        super.init()
    }

    public func positionOnSurface(withSize size: CGSize) -> CGPoint {
        let z: CGFloat
        if (size.width > size.height) {
            z = SceneCoordinate.originalSurfaceSize.width / size.width
        } else {
            z = SceneCoordinate.originalSurfaceSize.height / size.height
        }
        return CGPoint(x: CGFloat(x) / z, y: CGFloat(y) / z)
    }

    public required init(row: Row) {
        id = row["id"]
        x = row["x"]
        y = row["y"]
        sceneId = row["scene_id"]
        mapstopId = row["mapstop_id"]
        super.init(row: row)
    }

    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["x"] = x
        container["y"] = y
        container["scene_id"] = scene?.id
        container["mapstop_id"] = mapstop?.id
    }
}
