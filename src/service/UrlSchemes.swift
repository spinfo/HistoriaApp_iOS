
import Foundation

import XCGLogger

class UrlSchemes {

    static let serverBaseUri = "http://historia.ililil.co/wp-content/uploads/smart-history-tours"
    static let availableToursUri = UrlSchemes.serverBaseUri + "/tours.v2.yaml"

    // static let serverBaseUri = "https://5587237654002.hostingkunde.de/wp-content/uploads/smart-history-tours"
    // static let availableToursUri = UrlSchemes.serverBaseUri + "/tours.yaml"

    static let lexicon = "lexcion://"

    static let file = "file://"

    static func parseLexiconEntryIdFromUrl(_ url: String) -> Int64? {
        let idAsStr = url.replacingOccurrences(of: "lexicon://", with: "", options: .literal, range: nil)
        return Int64(idAsStr)
    }

}
