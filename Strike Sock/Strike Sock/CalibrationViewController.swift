//
//  CalibrationViewController.swift
//  Strike Sock
//
//  Created by Anna Diemel on 3/29/21.
//

import UIKit
import CoreBluetooth
import CorePlot

let calibrationWelcomePageText = """
Welcome to the calibration page!
By pressing Start, you will launch into a short calibration procedure that will ensure we get the best possible data out of your run. Prompts will appear on the screen that guide you through the process.
\n
Note: don't worry about recalibrating before every run. We'll remember your last calibration, so you only need to use this if something needs an update.
"""

let startButtonPressedText = """
Beginning calibration...
Press Pause to stop the calibration process.
"""


class CalibrationViewController: BLEViewController {
    
    @IBOutlet weak var calibrationText: UILabel!
    @IBOutlet weak var leftStack: UIStackView!
    @IBOutlet weak var middleStack: UIStackView!
    @IBOutlet weak var rightStack: UIStackView!
    @IBOutlet weak var startButtion: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearMeasurements()
    }
    
    func clearMeasurements() {
        calibrationText.text = calibrationWelcomePageText
        leftStack.isHidden = true
        middleStack.isHidden = true
        rightStack.isHidden = true
        finishButton.isHidden = true
    }
    
    func showStackViews() {
        leftStack.isHidden = false
        middleStack.isHidden = false
        rightStack.isHidden = false
    }
    
    func beginCalibration() {
        /* TODO: so much */
        calibrationText.text = startButtonPressedText
        finishButton.setTitle("Pause", for: .normal)
    }
    
    @IBAction func pressedStart(_ sender: Any) {
        /* TODO: make nice transition */
        showStackViews()
        finishButton.isHidden = false
        
        beginCalibration()
    }
    
    func performCalibration() {
        /* Calibration Stages:
         1. Stranding on tiptoe
         2. Leaning back on heels
         3. Standing on left leg
         4. Standing on right leg
         5. Some kind of active movement (jog or walk in place?)
         */
        
        /* for each calibration stage:
         1. Change prompts shown on screen to prompt the user
         2. Set timeout timer for the stage (error handling)
         - If timeout, cancel calibration early and prompt user to retry (display error/failed stage)
         3. Wait for user to follow the commands
         - Use reprompt timer that gives user more info (?) in case they're slow starting or don't get it
         - Have a minimum expected max that must be met for the calibration stage to be considered successful
         - If we've hit a maxima on the sensors after X amount of time, consider the calibration stage complete and continue to next
         */
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
