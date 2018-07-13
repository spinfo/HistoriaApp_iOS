
import Foundation

import XCGLogger

class HtmlContentCompletion {

    private static let replaceMe = "to replace"
    private static let htmlTemplate =
        "<html>" +
            "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<style>" +
                    "img { max-width: 95%; height: auto !important; }" +
                    "figure { max-width: 100%; margin: 1em 0 1em; }" +
                "</style>" +
            "</head>" +
            "<body>" +
                HtmlContentCompletion.replaceMe +
            "</body>" +
        "</html>";



    // take a content string and replace all occurences of mediaitem's guids with
    // the actual file paths that were downloaded
    static func replaceMediaitems(in content: String, media: [Mediaitem]) -> String {
        if (media.count <= 0) {
            return content
        }

        var newContent = content

        for mediaitem in media {
            let basename = (mediaitem.guid as NSString).lastPathComponent
            guard (!basename.isEmpty && basename != "/") else {
                log.warning("Could not determine basename for guid: \(mediaitem.guid)")
                continue
            }
            guard let fileUrl = FileService.getFile(atBase: basename) else {
                log.warning("Cannot determine file url for base: '\(basename)'")
                continue
            }
            guard FileManager.default.fileExists(atPath: fileUrl.path) else {
                log.warning("File for mediaitem does not exist at: \(fileUrl)")
                continue
            }
            // actually do the replacement
            let replacement = UrlSchemes.file + fileUrl.path
            newContent = newContent.replacingOccurrences(of: mediaitem.guid, with: replacement)
            log.info("Replacing '\(mediaitem.guid)' with '\(replacement)'")
        }

        return newContent
    }

    // wraps a snippet of html into a full html page with a bit of custom styling
    static func wrapInPage(_ innerHtml: String) -> String {
        return htmlTemplate.replacingOccurrences(of: replaceMe, with: innerHtml)
    }

    // set the given title at the start of the html snippet and return it
    static func setTitle(_ title: String, on content: String) -> String {
        return "<h1>\(title)</h1>\(content)"
    }

}
