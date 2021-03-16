//
//  HardwarePeripheral.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 2/23/21.
//

import Foundation
import UIKit
import CoreBluetooth

class HardwarePeripheral : NSObject {
    
    public static let serviceUUID = CBUUID.init(string: "b4250400-fb4b-4746-b2b0-93f0e61122c6")
    public static let frontCharUUID = CBUUID.init(string: "b4250401-fb4b-4746-b2b0-93f0e61122c6")
    public static let midCharUUID = CBUUID.init(string: "b4250402-fb4b-4746-b2b0-93f0e61122c6")
    public static let backCharUUID = CBUUID.init(string: "b4250403-fb4b-4746-b2b0-93f0e61122c6")
}
