//
//  CompleteRunViewController.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 3/29/21.
//

import UIKit
import Foundation
import CorePlot

class CompleteRunViewController: UIViewController & CPTPlotDataSource {
  

    private let oneDay : Double = 24 * 60 * 60
    private let oneMin : Double = 60

    @IBOutlet var hostView : CPTGraphHostingView!

    private var graph : CPTXYGraph? = nil

    private var plotData = [Double]()
    
    private let dataInterval = 0.5
    
    private var plotRange = 0.0
    
    private var insights : Analytics?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var strikeType: UILabel!
    @IBOutlet weak var consistency: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var lfLabel: UILabel!
    @IBOutlet weak var lmLabel: UILabel!
    @IBOutlet weak var lbLabel: UILabel!
    @IBOutlet weak var rfLabel: UILabel!
    @IBOutlet weak var rmLabel: UILabel!
    @IBOutlet weak var rbLabel: UILabel!
    var selectedMinute = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //selectedSession = Session(range: 600.0)

        guard let startTime = selectedSession?.startTime else {
            print("failed to get correct session object")
            return
        }
        guard let _ = selectedSession?.endTime else {
            print("failed to get an end time for this session")
            return
        }
        self.title = stringFromDate(startTime)
        
        //selectedSession?.printSession()
        insights = Analytics(sess: selectedSession!)

        setupGraph()
        setupSlider()
        moveToMinute()
        
    }
    @IBAction func sliderChanged(_ sender: UISlider) {
        let interval = 1
        let incomingValue = Int(sender.value / Float(interval) ) * interval
        sender.value = Float(incomingValue)
        selectedMinute = Int(sender.value)
        moveToMinute()
    }
    @IBAction func segmentSwitched(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.2, animations: {
            switch sender.selectedSegmentIndex {
            case 0:
                self.slider.isHidden = true
                self.showOverall()
            default:
                self.slider.isHidden = false
                self.moveToMinute()
            }
        })
    }
    
    func showOverall() {
        strikeType.text = insights?.strikeType.rawValue
        consistency.text = (insights?.consistency.format())! + "%"
        balance.text = insights?.getBalance()
        lfLabel.text = insights?.lFMBVec[0].format()
        lmLabel.text = insights?.lFMBVec[1].format()
        lbLabel.text = insights?.lFMBVec[2].format()
        rfLabel.text = insights?.rFMBVec[0].format()
        rmLabel.text = insights?.rFMBVec[1].format()
        rbLabel.text = insights?.rFMBVec[2].format()
    }
    
    
    func moveToMinute() {
        let minData = insights?.minuteData[selectedMinute]
        strikeType.text = minData?.strikeType.rawValue
        consistency.text = (minData?.consistency.format())! + "%"
        balance.text = minData?.getBalance()
        lfLabel.text = minData?.lFMBVec[0].format()
        lmLabel.text = minData?.lFMBVec[1].format()
        lbLabel.text = minData?.lFMBVec[2].format()
        rfLabel.text = minData?.rFMBVec[0].format()
        rmLabel.text = minData?.rFMBVec[1].format()
        rbLabel.text = minData?.rFMBVec[2].format()
    }
    
    func setupSlider() {
        slider.value = 0.0
        slider.minimumValue = 0
        slider.maximumValue = Float((insights?.minuteData.count)!-1)
        
    }
    
    func setupGraph() {
        let newGraph = CPTXYGraph(frame: hostView.frame)
        if let host = self.hostView {
            host.hostedGraph = newGraph
        }

        let theme = CPTTheme(named: .slateTheme)
        newGraph.apply(theme)
        
        //newGraph.backgroundColor = CPTColor.white().cgColor
        //newGraph.zPosition = 1_000

        newGraph.paddingLeft = 0.0
        newGraph.paddingRight = 0.0
        newGraph.paddingTop = 0.0
        newGraph.paddingBottom = 0.0

        newGraph.plotAreaFrame?.masksToBorder = false;
        newGraph.plotAreaFrame?.borderLineStyle = nil
        newGraph.plotAreaFrame?.cornerRadius = 0.0
        newGraph.plotAreaFrame?.paddingTop = 0.0
        newGraph.plotAreaFrame?.paddingLeft = 0.0
        newGraph.plotAreaFrame?.paddingBottom = 0.0
        newGraph.plotAreaFrame?.paddingRight = 0.0
        
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        let plotRange = insights!.secsData.count
        
        plotSpace.allowsUserInteraction = true
        plotSpace.allowsMomentumX = true
        plotSpace.xRange = CPTPlotRange(locationDecimal: 0.0, lengthDecimal: Decimal(plotRange))
        plotSpace.yRange = CPTPlotRange(locationDecimal: 0.0, lengthDecimal: 100.0)
        
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = (plotRange < 60 ? 30 : oneMin) as NSNumber
            x.orthogonalPosition    = 0.0
            x.minorTicksPerInterval = 0
            x.labelingPolicy = .none
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 10
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 0.0

            y.labelingPolicy = .none
        }
        
        //
        newGraph.add(generatePlotLine("L Front", CPTColor.magenta()),to: plotSpace)
        newGraph.add(generatePlotLine("L Mid", CPTColor.blue()),to: plotSpace)
        newGraph.add(generatePlotLine("L Back", CPTColor.purple()),to: plotSpace)
        newGraph.add(generatePlotLine("R Front", CPTColor.red()),to: plotSpace)
        newGraph.add(generatePlotLine("R Mid", CPTColor.orange()),to: plotSpace)
        newGraph.add(generatePlotLine("R Back", CPTColor.yellow()),to: plotSpace)

        
        let legend = CPTLegend(graph: newGraph)
        newGraph.legend = legend
        newGraph.legendAnchor = .top
        newGraph.legendDisplacement = CGPoint(x: 0.0, y: -5.0)
        legend.isHidden = false
        legend.fill = CPTFill(color: CPTColor.darkGray().withAlphaComponent(0.5))
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor(genericGray: 0.75)
        titleStyle.fontSize = 11.0
        legend.textStyle = titleStyle;
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 0.75
        lineStyle.lineColor = CPTColor(genericGray: 0.45)
        legend.borderLineStyle = lineStyle
        legend.cornerRadius = 5.0
        legend.swatchSize = CGSize(width: 25.0, height: 25.0)
        legend.numberOfRows = 1
//        recognizer.numberOfTouchesRequired = 1
//        recognizer.numberOfTapsRequired = 2
//        self.addGestureRecognizer(recognizer)
        
        
        self.graph = newGraph
    }
    
    func generatePlotLine(_ identifier: String, _ color: CPTColor) -> CPTScatterPlot{
        let plot = CPTScatterPlot()
        plot.identifier = identifier as NSString
        plot.dataSource = self
        plot.cachePrecision = .double
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineJoin = .round
        lineStyle.lineCap = .round
        lineStyle.lineWidth = 3.0
        lineStyle.lineColor = color
        plot.dataLineStyle = lineStyle
        return plot
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt((insights?.secsData.count)!)
    }
    
    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
    {
        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            return (Double(record)) as NSNumber
            
        case .Y:
            switch plot.identifier{
            case ("L Front" as NSString):
                return insights?.secsData[Int(record)].lfAv
            case ("L Mid" as NSString):
                return insights?.secsData[Int(record)].lmAv
            case ("L Back" as NSString):
                return insights?.secsData[Int(record)].lbAv
            case ("R Front" as NSString):
                return insights?.secsData[Int(record)].rfAv
            case ("R Mid" as NSString):
                return insights?.secsData[Int(record)].rmAv
            case ("R Back" as NSString):
                return insights?.secsData[Int(record)].rbAv
            default:
                return nil
            }
        @unknown default:
            return nil
        }
    }
        
}
