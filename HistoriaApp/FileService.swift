//
//  FileService.swift
//  HistoriaApp
//
//  Created by David on 10.08.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import UIKit
import os.log

class FileService {

    
    // put all a tour's files into their destination, return true on success, false on error
    // will attempt to remove the input file if everything goes ok.
    public class func installTour(fromZipFile file: URL) -> Bool {
        
        // everything goes straight to our app's document folder
        let docsFolderPath = getDocumentsFolder().path
        
        // unzip the archive doing some checks
        if FileManager().fileExists(atPath: file.path) {
            if !(SSZipArchive.unzipFile(atPath: file.path, toDestination: docsFolderPath!)) {
                os_log("Could not extract example tour to: %s", log: OSLog.default, type: .error, docsFolderPath!)
                return false
            }
        } else {
            os_log("No zip file to extract at: %s", log: OSLog.default, type: .error, file.path)
            return false
        }
        
        // Remove the input file, failure to do so does not affect the return status
        do {
            try FileManager().removeItem(at: file)
            
            // TODO: Remove
            let list = try FileManager().contentsOfDirectory(atPath: docsFolderPath!)
            for f in list {
                print("f: " + f)
            }
            let tourFile = getDocumentsFolder().appendingPathComponent("shtm-tour-0-0.yaml")
            let content = read(fileAtUrl: tourFile!)
            print(content)
            
        } catch {
            os_log("Removing the installed tour file failed. Caught: %s",
                   log: OSLog.default, type: .fault, error.localizedDescription)
        }
        return true
    }
    
    
    // installs the example tour included in the app's assets
    public class func installExampleTour() -> Bool {
       
        // read the example tour's zip file as binary data from the assets
        let data = getExampleTourData()
        
        // write the zip file into a temporary container
        guard let tempUrl = FileService.writeToTempFile(data) else {
            return false
        }
        
        return installTour(fromZipFile: tempUrl)
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
            os_log("Failed to write file to: %s, caught: %s", log: OSLog.default, type: .error,
                   fileUrl.path, error.localizedDescription)
            return nil
        }
        return fileUrl
    }
    
    // read a file, return an empty string on error
    private class func read(fileAtUrl: URL) -> String {
        do {
            return try NSString(contentsOf: fileAtUrl, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            os_log("Could not read file at: %s, caught: %s", log: OSLog.default, type: .error,
                   fileAtUrl.path, error.localizedDescription)
            return ""
        }
    }
    
}
