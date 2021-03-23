//
//  ViewController.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 2/16/21.
//

import UIKit
import CoreBluetooth
import CorePlot

class RunningViewController: UIViewController, CBPeripheralDelegate,
                      CBCentralManagerDelegate {

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var runningSession : Session = Session()
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var frontText: UILabel!
    @IBOutlet weak var midText: UILabel!
    @IBOutlet weak var backText: UILabel!
    @IBOutlet weak var StartPauseButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusText.text = "Initializing"
        frontText.text = "No data"
        midText.text = "No data"
        backText.text = "No data"
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    @IBAction func pressedStartPauseButton(_ sender: Any) {
        switch StartPauseButton.titleLabel!.text {
        case "Start":
            StartPauseButton.titleLabel!.text = "Pause"
            finishButton.isHidden = false
            runningSession.start()
        case "Pause":
            StartPauseButton.titleLabel!.text = "Continue"
            runningSession.isUpdating = false
        default:
            StartPauseButton.titleLabel!.text = "Pause"
            runningSession.isUpdating = true
        }
    }
    
    @IBAction func pressedFinishRun(_ sender: Any) {
        runningSession.end()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        statusUpdate("Central State update")
        if central.state != .poweredOn {
            statusUpdate("Central is not powered on")
        } else {
            statusUpdate("Central scanning for \(HardwarePeripheral.serviceUUID)");
            centralManager.scanForPeripherals(withServices: [HardwarePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.centralManager.stopScan()
        
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            statusUpdate("Connected to the sock")
            peripheral.discoverServices([HardwarePeripheral.serviceUUID])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == HardwarePeripheral.serviceUUID {
                    statusUpdate("Service Found")
                    
                    peripheral.discoverCharacteristics([HardwarePeripheral.frontCharUUID, HardwarePeripheral.midCharUUID, HardwarePeripheral.backCharUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            statusUpdate("Notification State Updated for \(characteristic.description) - \(characteristic.isNotifying)")
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == HardwarePeripheral.frontCharUUID {
                    statusUpdate("Front sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                    statusUpdate("Set Alert Notify True")
                }else if characteristic.uuid == HardwarePeripheral.midCharUUID {
                    statusUpdate("Mid sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                    statusUpdate("Set Alert Notify True")
                } else if characteristic.uuid == HardwarePeripheral.backCharUUID {
                    statusUpdate("Back sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                    statusUpdate("Set Alert Notify True")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        statusUpdate("Some value did update on the BLE device")
        if let e = error {
            statusUpdate("ERROR in updating peripheral value \(e)")
            return
        }
        guard let data = descriptorDescription(for: descriptor) else { return }
        
        let newDataPoint = dataPoint(time: Date(), val: Double(data) ?? 0.0)
        switch descriptor.characteristic.uuid {
            case HardwarePeripheral.frontCharUUID:
                statusUpdate("Updating the measure/read characteristic to \(data)")
                frontText.text = data
                if (runningSession.isUpdating) {
                    runningSession.frontArr.append(newDataPoint)
                }
            case HardwarePeripheral.midCharUUID:
                midText.text = data
                if (runningSession.isUpdating) {
                    runningSession.midArr.append(newDataPoint)
                }
            case HardwarePeripheral.backCharUUID:
                backText.text = data
                if (runningSession.isUpdating) {
                    runningSession.backArr.append(newDataPoint)
                }
        default:
            statusUpdate("ERROR in processing peripheral data")
        }
        
        return
    }
    
    func statusUpdate(_ text:String) {
        statusText.text = text
        print(text)
    }
    
    func descriptorDescription(for descriptor: CBDescriptor) -> String? {

        var description: String?
        var value: String?

        switch descriptor.uuid.uuidString {
        case CBUUIDCharacteristicFormatString:
            if let data = descriptor.value as? Data {
                description = "Characteristic format: "
                value = data.description
            }
        case CBUUIDCharacteristicUserDescriptionString:
            if let val = descriptor.value as? String {
                description = "User description: "
                value = val
            }
        case CBUUIDCharacteristicExtendedPropertiesString:
            if let val = descriptor.value as? NSNumber {
                description = "Extended Properties: "
                value = val.description
            }
        case CBUUIDClientCharacteristicConfigurationString:
            if let val = descriptor.value as? NSNumber {
                description = "Client characteristic configuration: "
                value = val.description
            }
        case CBUUIDServerCharacteristicConfigurationString:
            if let val = descriptor.value as? NSNumber {
                description = "Server characteristic configuration: "
                value = val.description
            }
        case CBUUIDCharacteristicAggregateFormatString:
            if let val = descriptor.value as? String {
                description = "Characteristic aggregate format: "
                value = val
            }
        default:
            break
        }

        if let desc=description, let val = value  {
            return "\(desc)\(val)"
        } else {
            return nil
        }
    }
}
