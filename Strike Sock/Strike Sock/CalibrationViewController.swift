//
//  CalibrationViewController.swift
//  Strike Sock
//
//  Created by Anna Diemel on 3/29/21.
//

import UIKit
import CoreBluetooth
import CorePlot

let calibrationWelcomePageText = """
Welcome to the calibration page!
By pressing Start, you will launch into a short calibration procedure that will ensure we get the best possible data out of your run. Prompts will appear on the screen that guide you through the process.
\n
Note: don't worry about recalibrating before every run. We'll remember your last calibration, so you only need to use this if something needs an update.
"""

let startButtonPressedText = """
Beginning calibration...
Press Pause to stop the calibration process.
"""

let tipToeText = """
Shift your weight completely onto the balls of your feet.
Don't worry too much about balance for now.
If you can, try jumping on your tip toes.
Your calves will thank you later!
"""

let heelText = """
Shift your weight back onto your heels.
Try walking around on your heels, with your toes in the air.
Just don't try this when you're running!
"""

let leftText = """
Halfway done!
Stand on your left foot, with your right foot off the ground.
Don't worry too much about balance for now.
Shift your weight around in any way that feels comfortable.
"""


let rightText = """
Time for the right side!
Stand on your right foot, with your left foot off the ground.
Don't worry too much about balance for now.
Shift your weight around in any way that feels comfortable.
"""

class CalibrationViewController: RunningViewController {
    
    @IBOutlet weak var calibrationText: UILabel!
    @IBOutlet weak var leftStack: UIStackView!
    @IBOutlet weak var middleStack: UIStackView!
    @IBOutlet weak var rightStack: UIStackView!
    
    var updateDictionary: [UILabel: Int]!
    var currentStage: String!

    /* Smallest sensor maximum that we've seen so far */
    let minimumExpectedValue = 20
    let repeatTime = 0.3
    let stageTime = 30.0
    var countdown = 30.0/0.3
    
    /* Largest sensor value received */
    var largestLHeel: Int!
    var largestLMid: Int!
    var largestLToe: Int!
    var largestRHeel: Int!
    var largestRMid: Int!
    var largestRToe: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDictionary = [:]
        initWeights()
        clearMeasurements()
    }
    
    func initWeights() {
        largestLHeel = minimumExpectedValue
        largestLMid = minimumExpectedValue
        largestLToe = minimumExpectedValue
        largestRHeel = minimumExpectedValue
        largestRMid = minimumExpectedValue
        largestRToe = minimumExpectedValue
    }
    
    func clearMeasurements() {
        calibrationText.text = calibrationWelcomePageText
        leftStack.isHidden = true
        middleStack.isHidden = true
        rightStack.isHidden = true
        finishButton.isHidden = true
    }
    
    func showStackViews() {
        /* TODO: make nice transition*/
        leftStack.isHidden = false
        middleStack.isHidden = false
        rightStack.isHidden = false
    }
    
    func beginCalibration() {
        StartPauseButton.setTitle(" ", for: .normal)
        calibrationText.text = startButtonPressedText
        finishButton.setTitle("Continue", for: .normal)
    }
    
    override func pressedFinishRun(_ sender: Any) {
        if finishButton.titleLabel!.text == "Continue" {
            currentStage = tipToeText
            performCalibration()
        }
    }
    
    func performCalibration() {
        let stageTimer = Timer.scheduledTimer(
            timeInterval: stageTime,
            target: self,
            selector: #selector(runCalibrationStages),
            userInfo: nil,
            repeats: true)
        runCalibrationStages(sender: stageTimer)
    }
    
    @objc func runCalibrationStages(sender: Timer) {
        if (currentStage != nil) {
            switch (currentStage) {
            case tipToeText:
                currentStage = heelText
                calibrateToes()
            case heelText:
                currentStage = leftText
                calibrateHeels()
            case leftText:
                currentStage = rightText
                calibrateLeft()
            case rightText:
                currentStage = nil
                sender.invalidate()
                calibrateRight()
            default:
                print("ERROR: unknown text for currentStage")
            }
        } else {
            print("ERROR: current stage not defined")
        }
    }
    
    @IBAction func pressedStart(_ sender: Any) {
        showStackViews()
        finishButton.isHidden = false
        beginCalibration()
    }
    
    /* Figure out which sensors are relevant */
    /* Check relevant sensors for values */
    /* If greater than min expected value, set local maxima timer */
    /* Every time a new maxima is found, reset local maxima timer */
    /* If stageTimeOut when local maxima timer is set, then the stage was done correctly */
    /* If timeout on local maxima timer, move to next stage */
    
    func calibrateToes(){
        
        _ = Timer.scheduledTimer(
            timeInterval: repeatTime,
            target: self,
            selector: #selector(updateData),
            userInfo: [lfrontText, rfrontText],
            repeats: true)
        
        calibrationText.text = tipToeText
        /* TODO: set helper/reminder timer */
    }

    func calibrateHeels(){
        calibrationText.text = heelText
    }
    
    func calibrateLeft(){
        calibrationText.text = leftText
    }
    
    func calibrateRight(){
        calibrationText.text = rightText
    }
    
    @objc func updateData(sender: Timer) {
        let labels = sender.userInfo as! Array<UILabel>
        for label in labels {
            var labelMaxima: Int!
            switch label {
            case lfrontText:
                labelMaxima = largestLToe
            case lmidText:
                labelMaxima = largestLMid
            case lbackText:
                labelMaxima = largestLHeel
            case rfrontText:
                labelMaxima = largestRToe
            case rmidText:
                labelMaxima = largestRMid
            case rbackText:
                labelMaxima = largestRHeel
            default:
                labelMaxima = 0
                print("ERROR: Unknown label in calibration timer user info")
            }
            let updatedLabelValue = updateDictionary[label]
            if (updatedLabelValue ?? 0 > labelMaxima) {
                labelMaxima = updatedLabelValue
                print("Maxima: \(labelMaxima ?? -1)")
            }
        }
        
        updateDictionary.removeAll()
        countdown -= 1
        if (countdown == 0) {
            sender.invalidate()
        }
    }
    
    @objc func stageTimeOut() {
        /* End calibration */
        /* Don't complete the rest of perform calibration */
    }

    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
                
        if let e = error {
            statusUpdate("ERROR in updating peripheral value \(e)")
            return
        }
        guard let value = characteristic.value else {return}
        let array = [UInt8](value)
        var dataStrBin = array.map { String($0, radix: 2) }.joined()
        dataStrBin.remove(at:dataStrBin.startIndex)
        dataStrBin.remove(at: dataStrBin.startIndex)
        guard let data = Int(dataStrBin, radix: 2) else {
            print("couldn't convert data to a decimal, returning")
            return
        }
        let newDataPoint = dataPoint(time: Date(), val: Double(data))
        switch characteristic.uuid {
            case LeftHardwarePeripheral.frontCharUUID:
                lfrontText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.lfrontArr.append(newDataPoint)
                    if (updateDictionary[lfrontText] ?? 0<data){
                        updateDictionary.updateValue(data, forKey: lfrontText)
                    }
                }
            case LeftHardwarePeripheral.midCharUUID:
                lmidText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.lmidArr.append(newDataPoint)
                    if (updateDictionary[lmidText] ?? 0<data){
                        updateDictionary.updateValue(data, forKey: lmidText)
                    }
                }
            case LeftHardwarePeripheral.backCharUUID:
                lbackText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.lbackArr.append(newDataPoint)
                    if (updateDictionary[lbackText] ?? 0<data){
                        updateDictionary.updateValue(data, forKey: lbackText)
                    }
                }
            case RightHardwarePeripheral.frontCharUUID:
                rfrontText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.rfrontArr.append(newDataPoint)
                    if (updateDictionary[rfrontText] ?? 0<data){
                        updateDictionary.updateValue(data, forKey: rfrontText)
                    }
                }
            case RightHardwarePeripheral.midCharUUID:
                rmidText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.rmidArr.append(newDataPoint)
                    if (updateDictionary[rmidText] ?? 0<data){
                        updateDictionary.updateValue(data, forKey: rmidText)
                    }
                }
            case RightHardwarePeripheral.backCharUUID:
                rbackText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.rbackArr.append(newDataPoint)
                    if (updateDictionary[rbackText] ?? 0<data){
                        updateDictionary.updateValue(data, forKey: rbackText)
                    }
                }
            case LeftHardwarePeripheral.readUUID:
                statusUpdate("read characteristic changed")
        default:
            statusUpdate("ERROR in processing peripheral data")
        }
        
        return
    }
}
