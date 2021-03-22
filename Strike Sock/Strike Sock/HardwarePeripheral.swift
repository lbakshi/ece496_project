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
    
    public static let serviceUUID = CBUUID.init(string: "dea53006-ea01-4939-a384-1573aae78dca")
    public static let frontCharUUID = CBUUID.init(string: "e7725f91-84af-4527-b045-6f7d3cc1b67d")
    public static let midCharUUID = CBUUID.init(string: "ab77fad9-d27b-4c46-8b44-771be5c01072")
    public static let backCharUUID = CBUUID.init(string: "1c005070-4bbd-428e-86bd-0287d7775a1e")
}
