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
    
    var largestLHeel: Int = 20
    var largestLMid: Int = 20
    var largestLToe: Int = 20
    var largestRHeel: Int = 20
    var largestRMid: Int = 20
    var largestRToe: Int = 20
    
    var loadedMaxima : Maxima?
    
    /* Largest sensor value received */
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDictionary = [:]
        loadedMaxima = Maxima.loadData()
        clearMeasurements()
    }
    
    func refreshMaximas() {
        loadedMaxima?.update(lf: largestLToe, lm: largestLMid, lb: largestLHeel, rf: largestRToe, rm: largestRMid, rb: largestRHeel)
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
                    Looking for highest pressure on toes...
                """
            case tipToeText:
                currentStage = heelText
                maximaInfo = """
                    Looking for highest pressure on heels...
                """
            case heelText:
                currentStage = leftText
                maximaInfo = """
                    Looking for highest pressure on left foot...
                """
            case leftText:
                currentStage = rightText
                maximaInfo = """
                    Looking for highest pressure on right foot...
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
    
    func updateMaximaInfo() {
        var maximaInfo = ""
        if (currentStage != nil) {
            switch (currentStage) {
            case tipToeText:
                maximaInfo = """
                    Largest left toe value: \(largestLToe)
                    Largest right toe value: \(largestRToe)
                """
            case heelText:
                maximaInfo = """
                    Largest left heel value: \(largestLHeel)
                    Largest right heel value: \(largestRHeel)
                """
            case leftText:
                maximaInfo = """
                    Largest left toe value: \(largestLToe )
                    Largest left mid value: \(largestLMid)
                    Largest left heel value: \(largestLHeel)
                """
            case rightText:
                maximaInfo = """
                    Largest right toe value: \(largestRToe)
                    Largest right mid value: \(largestRMid)
                    Largest right heel value: \(largestRHeel)
                """
            default:
                print("ERROR: unknown text for currentStage")
            }
            maximaText.text = maximaInfo
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

        var didChange = false
        switch characteristic.uuid {
            case LeftHardwarePeripheral.frontCharUUID:
                lfrontText.text = String(data)
                if (data > largestLToe) {
                    largestLToe = data
                    didChange = true
                }
            case LeftHardwarePeripheral.midCharUUID:
                lmidText.text = String(data)
                if (data > largestLMid) {
                    largestLMid = data
                    didChange = true
                }
            case LeftHardwarePeripheral.backCharUUID:
                lbackText.text = String(data)
                if (data > largestLHeel) {
                    largestLHeel = data
                    didChange = true
                }
            case RightHardwarePeripheral.frontCharUUID:
                rfrontText.text = String(data)
                if (data > largestRToe) {
                    largestRToe = data
                    didChange = true
                }
            case RightHardwarePeripheral.midCharUUID:
                rmidText.text = String(data)
                if (data > largestRMid) {
                    largestRMid = data
                    didChange = true
                }
            case RightHardwarePeripheral.backCharUUID:
                rbackText.text = String(data)
                if (data > largestRHeel) {
                    largestRHeel = data
                    didChange = true
                }
        default:
            statusUpdate("ERROR in processing peripheral data")
            return
        }
        if didChange {
            print("Writing new maxima: \(data)")
            updateMaximaInfo()
            refreshMaximas()
        }
        return
    }
}

class Maxima : Codable {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("StrikeSockMaxima")
    var largestLHeel: Int
    var largestLMid: Int
    var largestLToe: Int
    var largestRHeel: Int
    var largestRMid: Int
    var largestRToe: Int
    
    init() {
        largestRMid = 20
        largestRHeel = 20
        largestRToe = 20
        largestLMid = 20
        largestLHeel = 20
        largestLToe = 20
    }
    /**
     updates the maxima if they exceed the currently stored value. If a certain sensor doesn't need an update, just don't pass in it's parameter
     l/r is left/right, f/m/b is front/mid/back
     */
    func update(lf:Int = 0, lm:Int = 0, lb:Int = 0, rf:Int = 0, rm:Int = 0, rb:Int = 0) {
        if lf > largestLToe {
            largestLToe = lf
        }
        if lm > largestLMid {
            largestLMid = lm
        }
        if lb > largestLHeel {
            largestLHeel = lb
        }
        if rf > largestRToe {
            largestRToe = rf
        }
        if rm > largestRMid {
            largestRMid = rm
        }
        if rb > largestRHeel {
            largestRHeel = rb
        }
        let _ = Maxima.saveData(self)
    }
    
    static func saveData(_ dataArr: Maxima) -> Bool {
        var outputData = Data()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dataArr) {
            if String(data: encoded, encoding: .utf8) != nil {
                outputData = encoded
            } else { return false }
            do {
                try outputData.write(to: ArchiveURL)
            } catch let error as NSError {
                print(error)
                return false
            }
            return true
        }
        else { return false }
    }
    
    /*
     function to load data from JSON
     */
    static func loadData() -> Maxima? {
        let decoder = JSONDecoder()
        var outData = Maxima()
        let tempData: Data
        
        do {
            tempData = try Data(contentsOf: ArchiveURL)
        } catch let error as NSError {
            print(error)
            return outData
        }
        if let decoded = try? decoder.decode(Maxima.self, from: tempData) {
            outData = decoded
        }
        return outData
    }
}
