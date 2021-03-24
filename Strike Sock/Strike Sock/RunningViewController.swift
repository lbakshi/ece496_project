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
        statusUpdate("Connecting to the sock")
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            statusUpdate("Connected to the sock")
            peripheral.discoverServices([HardwarePeripheral.serviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            statusUpdate("ERROR in disconnecting peripheral \(e)")
            return
        }
        centralManager.scanForPeripherals(withServices: [HardwarePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            statusUpdate("ERROR in discovering services \(e)")
            return
        }
        if let services = peripheral.services {
            for service in services {
                if service.uuid == HardwarePeripheral.serviceUUID {
                    statusUpdate("Service Found")
                    
                    peripheral.discoverCharacteristics([HardwarePeripheral.frontCharUUID, HardwarePeripheral.midCharUUID/*, HardwarePeripheral.backCharUUID*/], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            if let e = error {
                statusUpdate("ERROR in updaing notification state \(e)")
                return
            }
            statusUpdate("Notification State Updated for \(characteristic.description) - \(characteristic.isNotifying)")
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let e = error {
            statusUpdate("ERROR in discovering characteristics \(e)")
            return
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == HardwarePeripheral.frontCharUUID {
                    statusUpdate("Front sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                    statusUpdate("Set Alert Notify True, attempting to read value once")
                    peripheral.readValue(for: characteristic)
                }else if characteristic.uuid == HardwarePeripheral.midCharUUID {
                    statusUpdate("Mid sensor characteristic found")
                    //peripheral.setNotifyValue(true, for: characteristic)
                    //statusUpdate("Set Alert Notify True")
                } else if characteristic.uuid == HardwarePeripheral.backCharUUID {
                    statusUpdate("Back sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                    statusUpdate("Set Alert Notify True")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        statusUpdate("Some descriptor did update on the BLE device")
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
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        statusUpdate("Some value did update on the BLE device")
        if let e = error {
            statusUpdate("ERROR in updating peripheral value \(e)")
            return
        }
        guard let value = characteristic.value else {return}
        let dataStr = String(decoding: value, as: UTF8.self)
        statusUpdate("Got data \(dataStr)")
        
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
        default:
            statusUpdate("ERROR in processing peripheral data")
        }
        
        return
    }

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
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
