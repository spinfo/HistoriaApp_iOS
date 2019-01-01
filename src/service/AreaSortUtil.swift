
import Foundation

protocol ObjectWithName {
    var name: String { get }
}

class AreaSortUtil {

    class func sort<T : ObjectWithName>(_ list: [T]) -> [T] {
        var sorted = list.sorted(by: {(o1, o2) in
            o1.name.localizedCaseInsensitiveCompare(o2.name).rawValue < 0
        })
        return prependObject(in: &sorted, withName: "Anleitung")
    }

    private class func prependObject<T : ObjectWithName>(in list: inout [T], withName name: String) -> [T] {
        var objectWithName: T? = nil
        for i in (0..<(list.count)) {
            if name == list[i].name {
                objectWithName = list.remove(at: i)
                break
            }
        }
        if (objectWithName != nil) {
            list.insert(objectWithName!, at: 0)
        }
        return list
    }

}
