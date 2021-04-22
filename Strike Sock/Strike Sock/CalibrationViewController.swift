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

var largestLHeel: Int = 20
var largestLMid: Int = 20
var largestLToe: Int = 20
var largestRHeel: Int = 20
var largestRMid: Int = 20
var largestRToe: Int = 20


class CalibrationViewController: RunningViewController {
    
    @IBOutlet weak var calibrationText: UILabel!
    @IBOutlet weak var maximaText: UILabel!
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
    
    func refreshMaximas() {
        largestLHeel = (updateDictionary[lbackText] ?? 0>largestLHeel) ? updateDictionary[lbackText]! : largestLHeel
        largestLMid = (updateDictionary[lmidText] ?? 0>largestLMid) ? updateDictionary[lmidText]! : largestLMid
        largestLToe = (updateDictionary[lfrontText] ?? 0>largestLMid) ? updateDictionary[lfrontText]! : largestLToe
        largestRHeel = (updateDictionary[rbackText] ?? 0>largestRHeel) ? updateDictionary[rbackText]! : largestRHeel
        largestRMid = (updateDictionary[rmidText] ?? 0>largestRMid) ? updateDictionary[rmidText]! : largestRMid
        largestRToe = (updateDictionary[rfrontText] ?? 0>largestRMid) ? updateDictionary[rfrontText]! : largestRToe
    }
    
    func clearMeasurements() {
        calibrationText.text = calibrationWelcomePageText
        maximaText.text = ""
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
        var maximaInfo = ""
        if (currentStage != nil) {
            switch (currentStage) {
            case loadingText:
                currentStage = tipToeText
                maximaInfo = """
                    Largest left toe value: \(largestLToe ?? 0)
                    Largest right toe value: \(largestRToe ?? 0)
                """
            case tipToeText:
                currentStage = heelText
                maximaInfo = """
                    Largest left heel value: \(largestLHeel ?? 0)
                    Largest right heel value: \(largestRHeel ?? 0)
                """
            case heelText:
                currentStage = leftText
                maximaInfo = """
                    Largest left toe value: \(largestLToe ?? 0)
                    Largest left mid value: \(largestLMid ?? 0)
                    Largest left heel value: \(largestLHeel ?? 0)
                """
            case leftText:
                currentStage = rightText
                maximaInfo = """
                    Largest right toe value: \(largestRToe ?? 0)
                    Largest right mid value: \(largestRMid ?? 0)
                    Largest right heel value: \(largestRHeel ?? 0)
                """
            case rightText:
                currentStage = finishedText
                finishButton.setTitle("Restart", for: .normal)
            case finishedText:
                sender.invalidate()
                currentStage = nil
            default:
                print("ERROR: unknown text for currentStage")
            }
            calibrationText.text = currentStage
            maximaText.text = maximaInfo
            
        } else {
            /* This will also be reached after the end of calibration */
            //print("ERROR: current stage not defined")
            finishButton.setTitle("Restart", for: .normal)
            calibrationText.text = " "
            maximaText.text = "No longer calibrating"
        }
    }
    
    @IBAction func pressedStart(_ sender: Any) {
        showStackViews()
        finishButton.isHidden = false
        performCalibration()
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
        var relevantLabel = UILabel()
        switch characteristic.uuid {
            case LeftHardwarePeripheral.frontCharUUID:
                relevantLabel = lfrontText
            case LeftHardwarePeripheral.midCharUUID:
                relevantLabel = lmidText
            case LeftHardwarePeripheral.backCharUUID:
                relevantLabel = lbackText
            case RightHardwarePeripheral.frontCharUUID:
                relevantLabel = rfrontText
            case RightHardwarePeripheral.midCharUUID:
                relevantLabel = rmidText
            case RightHardwarePeripheral.backCharUUID:
                relevantLabel = rbackText
        default:
            statusUpdate("ERROR in processing peripheral data")
            return
        }
        relevantLabel.text = String(data)
        if updateDictionary[relevantLabel] ?? 0 < data {
            updateDictionary.updateValue(data, forKey: relevantLabel)
        }
        refreshMaximas()
        return
    }
}
