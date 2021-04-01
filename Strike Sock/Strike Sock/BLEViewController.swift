//
//  BLEViewController.swift
//  Strike Sock
//  This view controller should be extended
//  for any view controller that connects to
//  BLE.
//
//  Created by Anna Diemel on 3/31/21.
//

import Foundation
import UIKit
import CoreBluetooth
import CorePlot

class BLEViewController: UIViewController,
                         CBPeripheralDelegate,
                         CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var frontText: UILabel!
    @IBOutlet weak var midText: UILabel!
    @IBOutlet weak var backText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusText.text = "Initializing"
        frontText.text = "No data"
        midText.text = "No data"
        backText.text = "No data"
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func statusUpdate(_ text:String) {
        statusText.text = text
        print(text)
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
