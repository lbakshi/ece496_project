//
//  CalibrationViewController.swift
//  Strike Sock
//
//  Created by Anna Diemel on 3/29/21.
//

import UIKit
import CoreBluetooth
import CorePlot

class CalibrationViewController: BLEViewController {
    
    @IBOutlet weak var calibrationText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calibrationText.text = " "
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
