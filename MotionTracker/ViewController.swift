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
    
    let pedometer = CMPedometer()
    
    @IBOutlet weak var fileNameField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var chartLabel: UILabel!
    
    @IBOutlet weak var chartView: LineChartView!
    
    private var _gyroActive:Bool = false
    var gyroActive:Bool {
        get{
            return self._gyroActive
        }
        set{
            self._gyroActive = newValue
            if (self._gyroActive){
                self.pedomActive = false
                self.motionActive = false
                stopAllUpdates()
                gyroScopeUpdate()
            }
        }
    }
    private var _pedomActive:Bool = false
    var pedomActive:Bool {
        get{
            return self._pedomActive
        }
        set{
            self._pedomActive = newValue
            if (self._pedomActive){
                self.gyroActive = false
                self.motionActive = false
                stopAllUpdates()
                pedometerUpdates()
            }
        }
    }
    
    private var _motionActive:Bool = false
    var motionActive:Bool {
        get{
            return self._motionActive
        }
        set{
            self._motionActive = newValue
            if (self._motionActive){
                self.gyroActive = false
                self.pedomActive = false
                stopAllUpdates()
                motionUpdates()
            }
        }
    }
    
    lazy var plots:[String:Bool] =
        {
            return ["Gyroscope": self.gyroActive, "Pedometer": self.pedomActive, "Motion": self.motionActive]
    }()
    
    typealias myFunc = () -> Void
    lazy var motionFunctions:[String: myFunc] = {
        return ["Gyroscope": gyroScopeUpdate, "Pedometer": pedometerUpdates, "Motion": motionUpdates, "Accel": accelUpdates]
    }()
    
    var xlineChartEntry = [ChartDataEntry]()
    var ylineChartEntry = [ChartDataEntry]()
    var zlineChartEntry = [ChartDataEntry]()
    
    var rollChartEntry = [ChartDataEntry]()
    var pitchChartEntry = [ChartDataEntry]()
    var yawChartEntry = [ChartDataEntry]()
    
    var cadenceChartEntry = [ChartDataEntry]()
    var paceChartEntry = [ChartDataEntry]()
    var distanceChartEntry = [ChartDataEntry]()
    
    var exportToCSV:Bool = false
    
    @IBOutlet weak var plotButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.chartView.chartDescription?.text = "Data"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    
    @IBAction func tabBarTap(_ sender: UIBarButtonItem) {
        resetLineChartArrays()
        if let title = sender.title{
            stopAllUpdates()
            //self.plots[title] = true
            self.chartLabel.text = title
            self.motionFunctions[title]!()
        }
    }
    
    @IBAction func exportCSV(_ sender: UIButton) {
        self.exportToCSV = true
    }
    
    
    func stopAllUpdates(){
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
        pedometer.stopUpdates()
    }
    
    func accelUpdates(){
        motionManager.accelerometerUpdateInterval = Constants.updateInterval
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData, error) in
            if let data = accelerometerData{
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                
                let xValue = ChartDataEntry(x: Double(self.xlineChartEntry.count), y: x)
                let yValue = ChartDataEntry(x: Double(self.ylineChartEntry.count), y: y)
                let zValue = ChartDataEntry(x: Double(self.zlineChartEntry.count), y: z)
                self.xlineChartEntry.append(xValue)
                self.ylineChartEntry.append(yValue)
                self.zlineChartEntry.append(zValue)
                
                self.updateChart(dataEntries: [self.xlineChartEntry, self.ylineChartEntry, self.zlineChartEntry], colors: [NSUIColor.blue, NSUIColor.green, NSUIColor.red], labels: ["X", "Y", "Z"], fileName: "accelerometer")
                
                self.textView.text = "Acceleration: \(x),\(y),\(z)"
            }
        }
    }
    
    func pedometerUpdates() -> Void{
        pedometer.startUpdates(from: Date()) { (pedometerData, error) in
            if let data = pedometerData {
                
                if let cadence = data.currentCadence?.doubleValue /* steps / seconds*/, let pace = data.currentPace?.doubleValue /*seconds/meter*/, let distance = data.distance?.doubleValue{
                    
                    self.textView.text = "\(cadence) steps/second, \(pace) seconds/meter, \(distance) traveled"
                    
                    let cadenceV = ChartDataEntry(x: Double(self.cadenceChartEntry.count), y: cadence)
                    let paceV = ChartDataEntry(x: Double(self.paceChartEntry.count), y: pace)
                    let distanceV = ChartDataEntry(x: Double(self.distanceChartEntry.count), y: distance)
                    self.rollChartEntry.append(cadenceV)
                    self.paceChartEntry.append(paceV)
                    self.distanceChartEntry.append(distanceV)
                    
                    self.updateChart(dataEntries: [self.cadenceChartEntry, self.paceChartEntry, self.distanceChartEntry], colors: [NSUIColor.blue, NSUIColor.green, NSUIColor.red], labels: ["Cadence", "Pace", "Distance"], fileName: "pedometer")
                }
            }
            else
            {
                self.chartView.data = nil
            }
        }
    }
    
    func motionUpdates() -> Void{
        motionManager.deviceMotionUpdateInterval = TimeInterval(Constants.updateInterval)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (deviceMotion, error) in
            guard error == nil else {
                return
            }
            
            // do something with device motion
            self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
        }
    }
    
    func gyroScopeUpdate() -> Void{
        
        motionManager.gyroUpdateInterval = TimeInterval(Constants.updateInterval) // every 5 seconds
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (gyroData, error) in
            if let data = gyroData {
                self.textView.text = "Rotation rate: \(data.rotationRate.x),\(data.rotationRate.y),\(data.rotationRate.z)"
                
                let xValue = ChartDataEntry(x: Double(self.xlineChartEntry.count), y: data.rotationRate.x)
                let yValue = ChartDataEntry(x: Double(self.ylineChartEntry.count), y: data.rotationRate.y)
                let zValue = ChartDataEntry(x: Double(self.zlineChartEntry.count), y: data.rotationRate.z)
                self.xlineChartEntry.append(xValue)
                self.ylineChartEntry.append(yValue)
                self.zlineChartEntry.append(zValue)
                
                self.updateChart(dataEntries: [self.xlineChartEntry, self.ylineChartEntry, self.zlineChartEntry], colors: [NSUIColor.blue, NSUIColor.green, NSUIColor.red], labels: ["X", "Y", "Z"],fileName: "gyroscope")
            }
        }
    }
    
    func updateChart(dataEntries:[[ChartDataEntry]], colors: [NSUIColor], labels: [String]?, fileName:String="motionTrackerData"){
        guard dataEntries.count == colors.count else {
            return
        }
        let chartData = LineChartData()
        for (i, data) in dataEntries.enumerated(){
            let label = (labels != nil) ? labels![i] : "\(i)"
            let line = LineChartDataSet(values: data, label: label)
            line.colors = [colors[i]]
            chartData.addDataSet(line)
            
            // Write to CSV
            let stringifiedData = data.map({ (dataEntry) -> String in
                return dataEntry.description
            })
            
            let filePrefix = (self.fileNameField.text != nil) ? "\(self.fileNameField.text!)_" : ""
        
            let pathToFile = CSVWriter.writeArrayToFile(array: stringifiedData, fileName: "\(filePrefix)\(fileName)")
            
            if (self.exportToCSV)
            {
                if let path = pathToFile{
                    let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        self.chartView.data = chartData
    }
    
    func resetLineChartArrays(){
        self.xlineChartEntry.removeAll()
        self.ylineChartEntry.removeAll()
        self.zlineChartEntry.removeAll()
        
        self.rollChartEntry.removeAll()
        self.pitchChartEntry.removeAll()
        self.yawChartEntry.removeAll()
        
        self.cadenceChartEntry.removeAll()
        self.paceChartEntry.removeAll()
        self.distanceChartEntry.removeAll()
    }
    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        let attitude = deviceMotion.attitude
        let roll = degrees(radians: attitude.roll)
        let pitch = degrees(radians: attitude.pitch)
        let yaw = degrees(radians: attitude.yaw)
        
        let rollV = ChartDataEntry(x: Double(self.rollChartEntry.count), y: roll)
        let pitchV = ChartDataEntry(x: Double(self.pitchChartEntry.count), y: pitch)
        let yawV = ChartDataEntry(x: Double(self.yawChartEntry.count), y: yaw)
        self.rollChartEntry.append(rollV)
        self.pitchChartEntry.append(pitchV)
        self.yawChartEntry.append(yawV)
        
        self.updateChart(dataEntries: [self.rollChartEntry, self.pitchChartEntry, self.yawChartEntry], colors: [NSUIColor.blue, NSUIColor.green, NSUIColor.red], labels: ["Roll", "Pitch", "Yaw"],fileName: "deviceMotion")
        
        self.textView.text = "Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)"
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / .pi * radians
    }
    
}

