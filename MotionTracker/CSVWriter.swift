//
//  CSVWriter.swift
//  MotionTracker
//
//  Created by Lucy Zhang on 1/17/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

class CSVWriter: NSObject {
    
    class func writeArrayToFile(array:[String], fileName:String) -> URL?
    {
        print("Filename: \(fileName)")
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let csvText = "Date written: \(Date())\n\(array.joined(separator: ","))"
        do
        {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        }
        catch
        {
            os_log("%@: Failed to create file: %@", type: .error, self.description(), error.localizedDescription)
        }
        return path
    }
}
