//
//  FileService.swift
//  HistoriaApp
//
//  Created by David on 10.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import UIKit

import SSZipArchive
import SpeedLog

class FileService {


    // put all a tour's files into their destination, return true on success, false on error
    // will attempt to remove the input file if everything goes ok.
    public class func installTour(fromZipFile file: URL) -> Tour? {

        // everything goes straight to our app's document folder
        let docsFolderPath = getDocumentsFolder().path

        // unzip the archive doing some checks
        if FileManager().fileExists(atPath: file.path) {
            if !(SSZipArchive.unzipFile(atPath: file.path, toDestination: docsFolderPath!)) {
                SpeedLog.print("ERROR", "Could not extract example tour to: \(docsFolderPath)")
                return nil
            }
        } else {
            SpeedLog.print("ERROR", "No zip file to extract at: \(file.path)")
            return nil
        }

        // Remove the input file, failure to do so does not affect the return status
        do {
            try FileManager().removeItem(at: file)
        } catch {
            SpeedLog.print("WARN", "Removing the installed tour file failed. Caught: \(error)")
        }

        // Construct a tour from the content file
        // TODO: Put somewhere else once this is not meant for the example tour
        let content = read(url: getDocumentsFolder().appendingPathComponent("shtm-tour-0-0.yaml")!)
        guard let tour = ServerResponseReader.parseTourYAML(content) else {
            SpeedLog.print("ERROR", "Empty response on parsing the input tour.")
            return nil
        }
        // TODO: Temove this test code
        SpeedLog.print("name: \(tour.name)")
        for stop in tour.mapstops {
            SpeedLog.print("stop: \(stop.name)")
        }
        DatabaseHelper.testRun(tour: tour)

        return tour
    }


    // installs the example tour included in the app's assets
    public class func installExampleTour() -> Tour? {

        // read the example tour's zip file as binary data from the assets
        let data = getExampleTourData()

        // write the zip file into a temporary container
        guard let tempUrl = FileService.writeToTempFile(data) else {
            return nil
        }

        return installTour(fromZipFile: tempUrl)
    }

    // return the file url that should be used for database access
    public class func getDBFile() -> URL? {
        return getDocumentsFolder().appendingPathComponent("db.sqlite")
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
            SpeedLog.print("ERROR", "Failed to write file to: \(fileUrl.path), caught: \(error)")
            return nil
        }
        return fileUrl
    }

    // read a file, return an empty string on error
    private class func read(url: URL) -> String {
        do {
            return try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            SpeedLog.print("ERROR", "Could not read file at: \(url.path), caught: \(error)")
            return ""
        }
    }
    
}
