//
//  HardwarePeripheral.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 2/23/21.
//

import Foundation
import UIKit
import CoreBluetooth

class LeftHardwarePeripheral : NSObject {
    
    public static let serviceUUID = CBUUID.init(string: "0x1826")
    public static let frontCharUUID = CBUUID.init(string: "0x2ACD")
    public static let midCharUUID = CBUUID.init(string: "0x2ACE")
    public static let backCharUUID = CBUUID.init(string: "0x2AD2")
    public static let readUUID = CBUUID.init(string: "0x2ACC")
}

class RightHardwarePeripheral : NSObject {
    public static let serviceUUID = CBUUID.init(string:"0x183E")
    public static let frontCharUUID = CBUUID.init(string: "0x2B3C")
    public static let midCharUUID = CBUUID.init(string: "0x2B3E")
    public static let backCharUUID = CBUUID.init(string: "0x2B41")
    public static let unuseda = CBUUID.init(string: "0x2B3B")
    public static let unusedb = CBUUID.init(string: "0x2B3D")
    public static let unusedc = CBUUID.init(string: "0x2B43")
    public static let unusedd = CBUUID.init(string: "0x2B44")
    public static let unusede = CBUUID.init(string: "0x2B45")
}
