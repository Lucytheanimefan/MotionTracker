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
import Charts

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var gyroTextView: UITextView!
    
    @IBOutlet weak var chartView: LineChartView!
    
    var xlineChartEntry = [ChartDataEntry]()
    var ylineChartEntry = [ChartDataEntry]()
    var zlineChartEntry = [ChartDataEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.chartView.chartDescription?.text = "Gyroscope data"
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
                
                let xValue = ChartDataEntry(x: Double(self.xlineChartEntry.count), y: data.rotationRate.x)
                let yValue = ChartDataEntry(x: Double(self.ylineChartEntry.count), y: data.rotationRate.y)
                let zValue = ChartDataEntry(x: Double(self.zlineChartEntry.count), y: data.rotationRate.z)
                self.xlineChartEntry.append(xValue)
                self.ylineChartEntry.append(yValue)
                self.zlineChartEntry.append(zValue)
                let xLine = LineChartDataSet(values: self.xlineChartEntry, label: "X")
                xLine.colors = [NSUIColor.blue]
                let yLine = LineChartDataSet(values: self.ylineChartEntry, label: "Y")
                yLine.colors = [NSUIColor.red]
                let zLine = LineChartDataSet(values: self.zlineChartEntry, label: "Z")
                zLine.colors = [NSUIColor.green]
                
                let data = LineChartData()
                data.addDataSet(xLine)
                data.addDataSet(yLine)
                data.addDataSet(zLine)
                self.chartView.data = data
 
            }
        }
    }
    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        let pitch = degrees(radians: attitude.pitch)
        let yaw = degrees(radians: attitude.yaw)
        //print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
        
        
        self.textView.text = "Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)"
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }

}

