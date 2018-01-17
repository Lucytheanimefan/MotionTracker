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
    
    
    @IBOutlet weak var gyroTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        motionUpdates()
        gyroScopeUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionUpdates(){
        motionManager.deviceMotionUpdateInterval = TimeInterval(Constants.updateInterval)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (deviceMotion, error) in
            guard error == nil else {
                return
            }
            
            // do something with device motion
            self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
        }
    }
    
    func gyroScopeUpdate(){
        motionManager.gyroUpdateInterval = TimeInterval(Constants.updateInterval) // every 5 seconds
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (gyroData, error) in
            if let data = gyroData {
                self.gyroTextView.text = "Rotation rate: \(data.rotationRate.x),\(data.rotationRate.y),\(data.rotationRate.z)"
            }
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

