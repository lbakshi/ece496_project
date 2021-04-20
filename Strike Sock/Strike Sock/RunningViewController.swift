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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeLabels()
        stylizeButtons()
    }
    
    func stylizeLabels() {
        /* Status text: centralized and segmented out */
        statusText.backgroundColor = UIColor.systemOrange
        statusText.textColor = UIColor.white
        statusText.font = UIFont.boldSystemFont(ofSize: 16)
        statusText.layer.cornerRadius = 12
        statusText.layer.masksToBounds = true
    }
    
    func stylizeButtons() {
        StartPauseButton.setTitleColor(UIColor.systemRed, for: .normal)
        finishButton.setTitleColor(UIColor.systemRed, for: .normal)
    }
    
    override func showGoodBLEConnection() {
        statusText.backgroundColor = UIColor.systemRed
        /* TODO: permanently change status text to show good connection */
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
            case LeftHardwarePeripheral.frontCharUUID:
                lfrontText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.lfrontArr.append(newDataPoint)
                }
            case LeftHardwarePeripheral.midCharUUID:
                lmidText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.lmidArr.append(newDataPoint)
                }
            case LeftHardwarePeripheral.backCharUUID:
                lbackText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.lbackArr.append(newDataPoint)
                }
            case RightHardwarePeripheral.frontCharUUID:
                rfrontText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.rfrontArr.append(newDataPoint)
                }
            case RightHardwarePeripheral.midCharUUID:
                rmidText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.rmidArr.append(newDataPoint)
                }
            case RightHardwarePeripheral.backCharUUID:
                rbackText.text = String(data)
                if (runningSession.isUpdating) {
                    runningSession.rbackArr.append(newDataPoint)
                }
            case LeftHardwarePeripheral.readUUID:
                statusUpdate("read characteristic changed")
        default:
            statusUpdate("ERROR in processing peripheral data")
        }
        
        return
    }
}
