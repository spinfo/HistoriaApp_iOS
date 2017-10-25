
import Foundation

import SpeedLog

class UrlSchemes {

    static let serverBaseUri = "https://historia-app.de/wp-content/uploads/smart-history-tours"

    static let availableToursUri = UrlSchemes.serverBaseUri + "/tours.yaml"

    static let lexicon = "lexcion://"

    static let file = "file://"

    static func parseLexiconEntryIdFromUrl(_ url: String) -> Int64? {
        let idAsStr = url.replacingOccurrences(of: "lexicon://", with: "", options: .literal, range: nil)
        return Int64(idAsStr)
    }

}
