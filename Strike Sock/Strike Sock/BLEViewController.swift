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
    private var leftPeripheral: CBPeripheral!
    private var rightPeripheral: CBPeripheral!
    
    var connectedLeft: Bool!
    var connectedRight: Bool!
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var lfrontText: UILabel!
    @IBOutlet weak var lmidText: UILabel!
    @IBOutlet weak var lbackText: UILabel!
    @IBOutlet weak var rfrontText: UILabel!
    @IBOutlet weak var rmidText: UILabel!
    @IBOutlet weak var rbackText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("target uuids are \(LeftHardwarePeripheral.serviceUUID.uuidString.lowercased()) & \(RightHardwarePeripheral.serviceUUID.uuidString.lowercased())")
        initText()
        connectedRight = false
        connectedLeft = false
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func initText() {
        statusText.text = "Initializing"
        lfrontText.text = "No data"
        lmidText.text = "No data"
        lbackText.text = "No data"
        rfrontText.text = "No data"
        rmidText.text = "No data"
        rbackText.text = "No data"
    }
    
    func statusUpdate(_ text:String) {
        /* If BLE connection is good, just say that*/
        if (didConnectSuccessfully()) {
            statusText.text = "Bluetooth Paired Successfully"
        } else {
            statusText.text = text
        }
        print(text)
    }
    
    /* To be overriden by subclasses. */
    func showGoodBLEConnection() {}
    
    func didConnectSuccessfully() -> Bool {
        return connectedRight && connectedLeft
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        statusUpdate("Central State update")
        if central.state != .poweredOn {
            statusUpdate("Central is not powered on")
        } else {
            statusUpdate("Central scanning for \(LeftHardwarePeripheral.serviceUUID) & \(RightHardwarePeripheral.serviceUUID)");
            centralManager.scanForPeripherals(withServices: [LeftHardwarePeripheral.serviceUUID, RightHardwarePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var detectedServiceUuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []
        if let detectedOverflowUuids = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID] {
            detectedServiceUuids.append(contentsOf: detectedOverflowUuids)
        }
        for detectedServiceUuid in detectedServiceUuids {
            print("Detected serviceUuid: \(detectedServiceUuid)")
        }
        
        if (detectedServiceUuids.contains(LeftHardwarePeripheral.serviceUUID)) {
            self.leftPeripheral = peripheral
            self.leftPeripheral.delegate = self
            statusUpdate("Connecting to the left peripheral")
            self.centralManager.connect(self.leftPeripheral, options: nil)
        } else if (detectedServiceUuids.contains(RightHardwarePeripheral.serviceUUID)) {
            self.rightPeripheral = peripheral
            self.rightPeripheral.delegate = self
            statusUpdate("Connecting to the right peripheral")
            self.centralManager.connect(self.rightPeripheral, options: nil)
        }
        
        if(self.leftPeripheral != nil && self.rightPeripheral != nil) {
            print("found both peripherals, stopping scan")
            self.centralManager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.leftPeripheral {
            statusUpdate("Connected to the left peripheral")
            peripheral.discoverServices([LeftHardwarePeripheral.serviceUUID])
            connectedLeft = true
        } else if (peripheral == self.rightPeripheral) {
            statusUpdate("Connected to the right peripheral")
            peripheral.discoverServices([RightHardwarePeripheral.serviceUUID])
            connectedRight = true
        }
        if (connectedLeft && connectedRight) {
            showGoodBLEConnection()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            statusUpdate("ERROR in disconnecting peripheral \(e)")
            return
        }
        if peripheral == leftPeripheral {
            connectedLeft = false
            centralManager.scanForPeripherals(withServices: [LeftHardwarePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
        if peripheral == rightPeripheral {
            connectedRight = false
            centralManager.scanForPeripherals(withServices: [RightHardwarePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            statusUpdate("ERROR in discovering services \(e)")
            return
        }
        if let services = peripheral.services {
            for service in services {
                if service.uuid == LeftHardwarePeripheral.serviceUUID {
                    statusUpdate("Left Service Found")
                    
                    peripheral.discoverCharacteristics([LeftHardwarePeripheral.frontCharUUID, LeftHardwarePeripheral.midCharUUID, LeftHardwarePeripheral.backCharUUID], for: service)
                }
                if service.uuid == RightHardwarePeripheral.serviceUUID {
                    statusUpdate("Right Service Found")
                    
                    peripheral.discoverCharacteristics([RightHardwarePeripheral.frontCharUUID, RightHardwarePeripheral.midCharUUID, RightHardwarePeripheral.backCharUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            if let e = error {
                statusUpdate("ERROR in updating notification state \(e)")
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
                if characteristic.uuid == LeftHardwarePeripheral.frontCharUUID {
                    statusUpdate("left Front sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                }else if characteristic.uuid == LeftHardwarePeripheral.midCharUUID {
                    statusUpdate("left Mid sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == LeftHardwarePeripheral.backCharUUID {
                    statusUpdate("left Back sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == RightHardwarePeripheral.frontCharUUID {
                    statusUpdate("right Front sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                }else if characteristic.uuid == RightHardwarePeripheral.midCharUUID {
                    statusUpdate("right Mid sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == RightHardwarePeripheral.backCharUUID {
                    statusUpdate("right Back sensor characteristic found")
                    peripheral.setNotifyValue(true, for: characteristic)
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
