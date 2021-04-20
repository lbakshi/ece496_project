//
//  TitleViewController.swift
//  Strike Sock
//
//  Created by Anna Diemel on 4/4/21.
//

import Foundation
import UIKit

class TitleViewController: UIViewController {
    
    @IBOutlet weak var backgroundGradientView: UIView!
    var buttons: Array<UIButton>!
    var labels: Array<UILabel>!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var welcomeUserLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var startRunButton: UIButton!
    @IBOutlet weak var pastRunsButton: UIButton!
    @IBOutlet weak var calibrateButton: UIButton!
    @IBOutlet weak var aboutUsButton: UIButton!
    @IBOutlet weak var setUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.isHidden = true;
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    } 
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    func setUpView() {
        addGradient()
        addButtons()
        addLabels()
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        let topColor = UIColor.systemRed.cgColor
        let bottomColor = UIColor.systemOrange.cgColor
        
        gradient.frame = view.bounds
        gradient.colors = [topColor, bottomColor]
        
        gradient.shouldRasterize = true
        backgroundGradientView.layer.insertSublayer(gradient, at:0)
    }
    
    func addButtons(){
        buttons = [profileButton,startRunButton,pastRunsButton,calibrateButton,aboutUsButton,setUpButton]
        let buttonColor = UIColor.systemGray6
        for button in buttons {
            button.setTitleColor(buttonColor, for: .normal)
        }
    }
    
    func addLabels() {
        labels = [titleLabel, welcomeUserLabel]
        let labelColor = UIColor.black
        for label in labels {
            label.textColor = labelColor
        }
        // title label only
        titleLabel.font = UIFont(name: "Thonburi-Bold", size: 40)
    }
}
