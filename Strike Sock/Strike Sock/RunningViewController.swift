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
        let array = [UInt8](value)
        var dataStrBin = array.map { String($0, radix: 2) }.joined()
        dataStrBin.remove(at:dataStrBin.startIndex)
        dataStrBin.remove(at: dataStrBin.startIndex)
        statusUpdate("Data in binary: \(dataStrBin)")
        guard let data = Int(dataStrBin, radix: 2) else {
            print("couldn't convert data to a decimal, returning")
            return
        }
        statusUpdate("data as decimal is \(data)")
        let newDataPoint = dataPoint(time: Date(), val: Double(data))
        switch characteristic.uuid {
            case HardwarePeripheral.frontCharUUID:
                frontText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.frontArr.append(newDataPoint)
                }
            case HardwarePeripheral.midCharUUID:
                midText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.midArr.append(newDataPoint)
                }
            case HardwarePeripheral.backCharUUID:
                backText.text = String(data)
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
