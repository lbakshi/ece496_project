//
//  CalibrationViewController.swift
//  Strike Sock
//
//  Created by Anna Diemel on 3/29/21.
//

import UIKit
import CoreBluetooth
import CorePlot

class CalibrationViewController: UIViewController,
                                 CBPeripheralDelegate,
                                 CBCentralManagerDelegate{
        
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var runningSession : Session = Session()

    @IBOutlet weak var calibrationStatus: UILabel!
    @IBOutlet weak var frontStatus: UILabel!
    @IBOutlet weak var middleStatus: UILabel!
    @IBOutlet weak var backStatus: UILabel!
    @IBOutlet weak var calibrationDescriptor: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calibrationStatus.text = "Initializing"
        frontStatus.text = "No data"
        middleStatus.text = "No data"
        backStatus.text = "No data"
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
