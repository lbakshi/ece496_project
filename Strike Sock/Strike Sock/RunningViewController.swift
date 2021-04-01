//
//  RunningViewController.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 2/16/21.
//

import UIKit
import CoreBluetooth
import CorePlot

class RunningViewController: BLEViewController {
    
    var runningSession : Session = Session()
    
    @IBOutlet weak var StartPauseButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !runningSession.complete {
            runningSession.end()
        } else {
            return
        }
    }
    
    @IBAction func pressedStartPauseButton(_ sender: Any) {
        switch StartPauseButton.titleLabel!.text {
        case "Start":
            StartPauseButton.setTitle("Pause", for: .normal)
            finishButton.isHidden = false
            runningSession.start()
        case "Pause":
            StartPauseButton.setTitle("Continue", for: .normal)
            runningSession.isUpdating = true
        default:
            StartPauseButton.setTitle("Pause", for: .normal)
            runningSession.isUpdating = false
        }
    }
    
    @IBAction func pressedFinishRun(_ sender: Any) {
        runningSession.end()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        statusUpdate("Some value did update on the BLE device")
        if let e = error {
            statusUpdate("ERROR in updating peripheral value \(e)")
            return
        }
        guard let value = characteristic.value else {return}
        let data = value.map { String(format: "%02x", $0) }.joined()
        statusUpdate("Data in hex? \(data)")
        let dataStr = String(decoding: value, as: UTF8.self)
        statusUpdate("Data in UTF 8 \(dataStr)")
        let array = [UInt8](value)
        let dataStrBin = array.map { String($0, radix: 2) }.joined()
        statusUpdate("Data in binary: \(dataStrBin)")
        let newDataPoint = dataPoint(time: Date(), val: Double(dataStr) ?? 0.0)
        switch characteristic.uuid {
            case HardwarePeripheral.frontCharUUID:
                statusUpdate("Updating the measure/read characteristic to \(dataStr)")
                frontText.text = dataStr
                if (runningSession.isUpdating) {
                    runningSession.frontArr.append(newDataPoint)
                }
            case HardwarePeripheral.midCharUUID:
                midText.text = dataStr
                if (runningSession.isUpdating) {
                    runningSession.midArr.append(newDataPoint)
                }
            case HardwarePeripheral.backCharUUID:
                backText.text = dataStr
                if (runningSession.isUpdating) {
                    runningSession.backArr.append(newDataPoint)
                }
            case HardwarePeripheral.readUUID:
                statusUpdate("read characteristic changed")
        default:
            statusUpdate("ERROR in processing peripheral data")
        }
        
        return
    }
}
