
import Foundation

import UIKit

import SSZipArchive
import XCGLogger

class FileService {


    // put all a tour's files into their destination, return true on success, false on error
    // will attempt to remove the input file if everything goes ok.
    public class func installTour(fromZipFile file: URL, tourRecord: TourRecord) -> Tour? {

        // everything goes straight to our app's document folder
        let docsFolderPath = getDocumentsFolder().path

        // unzip the archive doing some checks
        if FileManager.default.fileExists(atPath: file.path) {
            if !(SSZipArchive.unzipFile(atPath: file.path, toDestination: docsFolderPath!)) {
                log.error("Could not extract example tour to: \(docsFolderPath)")
                return nil
            }
        } else {
            log.error("No zip file to extract at: \(file.path)")
            return nil
        }

        // Remove the input file, failure to do so does not affect the return status
        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            log.warning("Removing the installed tour file failed. Caught: \(error)")
        }

        // Construct a tour from the now readable content file and hand it to the db installer
        let fileName = self.tourFileName(record: tourRecord)
        let content = read(url: getDocumentsFolder().appendingPathComponent(fileName)!)
        guard let tour = ServerResponseReader.parseTourYAML(content) else {
            log.error("Empty response on parsing the input tour.")
            return nil
        }
        // Save to db or fail
        if DatabaseHelper.save(tour: tour) {
            return tour
        } else {
            log.error("Tour could not be saved to db.")
            // TODO: Remove all the unzipped files, that were meant for the tour
            return nil
        }
    }


    // installs the example tour included in the app's assets
    public class func installExampleTour() -> Tour? {

        // read the example tour's zip file as binary data from the assets
        let data = getExampleTourData()

        // write the zip file into a temporary container
        guard let tempUrl = FileService.writeToTempFile(data) else {
            return nil
        }

        // we need a fake tour record to install the example (tourId and version
        // are 0 per convention for the example)
        let record = TourRecord()
        record.tourId = 0
        record.version = 0
        return installTour(fromZipFile: tempUrl, tourRecord: record)
    }

    // return the file url that should be used for database access
    public class func getDBFile() -> URL? {
        guard let url = getFile(atBase: "db.sqlite") else {
            log.error("Unable to determine db file.")
            return nil
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        return url
    }

    // return the file url with the given basename from our documents folder
    public class func getFile(atBase base: String) -> URL? {
        return getDocumentsFolder().appendingPathComponent(base)
    }

    //MARK: Private methods

    // return the url for our app's document folder
    private class func getDocumentsFolder() -> NSURL {
        return NSURL(
            fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!,
            isDirectory: true
        )
    }

    // read the example tour asset and return all it's data
    private class func getExampleTourData() -> Data {
        guard let asset = NSDataAsset(name: "ExampleTour") else {
            fatalError("Example tour not present.")
        }
        return asset.data
    }

    // write data to the app's document folder, return the file url
    private class func writeToDocumentFile(_ data: Data, fileName: String) -> URL? {
        let url = getDocumentsFolder().appendingPathComponent(fileName)!
        return writeFileLoggingErrors(data, fileUrl: url)
    }

    // write data to a temporary file, return the file path
    private class func writeToTempFile(_ data: Data) -> URL? {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString)
        return writeFileLoggingErrors(data, fileUrl: url)
    }

    // write a file or log an error and return nil
    private class func writeFileLoggingErrors(_ data: Data, fileUrl: URL) -> URL? {
        do {
            try data.write(to: fileUrl)
        } catch {
            log.error("Failed to write file to: \(fileUrl.path), caught: \(error)")
            return nil
        }
        return fileUrl
    }

    // read a file, return an empty string on error
    private class func read(url: URL) -> String {
        do {
            return try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            log.error("Could not read file at: \(url.path), caught: \(error)")
            return ""
        }
    }

    // construct a filename for a future tour file from a tour record
    private class func tourFileName(record: TourRecord) -> String {
        return "shtm-tour-\(record.tourId)-\(record.version).yaml"
    }
    
}
