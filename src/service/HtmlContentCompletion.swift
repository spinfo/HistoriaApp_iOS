
import Foundation

import XCGLogger

class HtmlContentCompletion {

    private static let contentPlaceholder = "PlaceholderForContent"
    private static let cssPlaceholder = "PlaceholderForStyles"
    private static let lexiconHeadingPlaceholder = "LexiconHeadingPlaceholder"
    private static let htmlTemplate =
        "<html lang=\"de-DE\">" +
            "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<style>\n" +
                    HtmlContentCompletion.cssPlaceholder +
                "</style>\n" +
            "</head>" +
            "<body>" +
                HtmlContentCompletion.contentPlaceholder +
            "</body>" +
        "</html>";
    private static let lexiconHeadingTemplate =
        "<div style=\"text-align:center;margin-top:12px;\">" +
            "<hr>" +
            "<h1>" +
                HtmlContentCompletion.lexiconHeadingPlaceholder +
            "</h1>" +
            "<hr>" +
        "</div>\n";



    // take a content string and replace all occurences of mediaitem's guids with
    // the actual file paths that were downloaded
    static func replaceMediaitems(in content: String, media: [Mediaitem]) -> String {
        if (media.count <= 0) {
            return content
        }

        var newContent = content

        for mediaitem in media {
            let basename = mediaitem.basename
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
        let styles = FileService.getAssetFile("AppArticleCss")
        let templateWithStyles = htmlTemplate.replacingOccurrences(of: cssPlaceholder, with: styles)
        return templateWithStyles.replacingOccurrences(of: contentPlaceholder, with: innerHtml)
    }

    // set the given title at the start of the html snippet and return it
    static func setTitle(_ title: String, on content: String) -> String {
        let titleHtml = lexiconHeadingTemplate.replacingOccurrences(of: lexiconHeadingPlaceholder, with: title)
        return titleHtml + content
    }

}
