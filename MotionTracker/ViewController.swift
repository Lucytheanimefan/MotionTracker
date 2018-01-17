//
//  ViewController.swift
//  MotionTracker
//
//  Created by Lucy Zhang on 1/16/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        motionUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionUpdates(){
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (deviceMotion, error) in
            guard error == nil else {
                return
            }
            
            // do something with device motion
            self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
        }
    }
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        let pitch = degrees(radians: attitude.pitch)
        let yaw = degrees(radians: attitude.yaw)
        print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
        
        
        self.textView.text = "Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)"
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }

}

