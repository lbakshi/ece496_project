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

let tipToeText = """
Beginning calibration...
Shift weight onto the balls of your feet.
Don't worry too much about balance for now.
If you can, try jumping on your tip toes.
Your calves will thank you later!
"""

let heelText = """
Shift your weight back onto your heels.
Try walking around on your heels,
with your toes lifted off the ground.
Just don't try this when you're running!
"""

let leftText = """
Halfway done!


Stand on your left foot,
with your right foot off the ground.
Don't worry too much about balance for now.
Shift your weight around
in any way that feels comfortable.
"""


let rightText = """
Stand on your right foot,
with your left foot off the ground.
Don't worry too much about balance for now.
Shift your weight around
in any way that feels comfortable.
"""

let finishedText = """
Calibration Complete.
Continue using your device as usual.
"""

let earlyExitText = """
Calibration cancelled prematurely.
If you did not mean to do this, simply press Restart.
"""

let errorText = """
ERROR in Calibration.
Please retry.
"""

let loadingText = """
Loading...
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
    
    func userEndsCalibrationEarly() {
        calibrationText.text = earlyExitText
        finishButton.setTitle("Restart", for: .normal)
        /* TODO */
        /* Not bad data, just user choice */
    }
    
    override func pressedFinishRun(_ sender: Any) {
        let stageText = finishButton.titleLabel!.text
        if stageText == "Restart" {
            performCalibration()
        } else if stageText == "Cancel" {
            userEndsCalibrationEarly()
        }
    }
    
    func performCalibration() {
        currentStage = loadingText
        StartPauseButton.setTitle(" ", for: .normal)
        finishButton.setTitle("Cancel", for: .normal)
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
            case loadingText:
                currentStage = tipToeText
            case tipToeText:
                currentStage = heelText
            case heelText:
                currentStage = leftText
            case leftText:
                currentStage = rightText
            case rightText:
                currentStage = finishedText
                finishButton.setTitle("Restart", for: .normal)
            case finishedText:
                sender.invalidate()
                currentStage = nil
            default:
                print("ERROR: unknown text for currentStage")
            }
        } else {
            /* This will also be reached after the end of calibration */
            print("ERROR: current stage not defined")
            finishButton.setTitle("Restart", for: .normal)
        }
        calibrationText.text = (currentStage != nil) ? currentStage : " "
    }
    
    @IBAction func pressedStart(_ sender: Any) {
        showStackViews()
        finishButton.isHidden = false
        performCalibration()
    }
    
    /* Figure out which sensors are relevant */
    /* Check relevant sensors for values */
    /* If greater than min expected value, set local maxima timer */
    /* Every time a new maxima is found, reset local maxima timer */
    /* If stageTimeOut when local maxima timer is set, then the stage was done correctly */
    /* If timeout on local maxima timer, move to next stage */
    
    /**
     _ = Timer.scheduledTimer(
         timeInterval: repeatTime,
         target: self,
         selector: #selector(updateData),
         userInfo: [lfrontText, rfrontText],
         repeats: true)
     */
    
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
        /* Inform user that calibration was not successful */
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
