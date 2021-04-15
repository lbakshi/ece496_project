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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //selectedSession = Session(range: 10.0)

        guard let startTime = selectedSession?.startTime else {
            print("failed to get correct session object")
            return
        }
        guard let endTime = selectedSession?.endTime else {
            print("failed to get an end time for this session")
            return
        }
        self.title = stringFromDate(startTime)
        
        selectedSession?.printSession()
        insights = Analytics(sess: selectedSession!)

        let newGraph = CPTXYGraph(frame: hostView.frame)
        if let host = self.hostView {
            host.hostedGraph = newGraph
        }

        let theme = CPTTheme(named: .darkGradientTheme)
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
            x.majorIntervalLength   = (plotRange < 60 ? 2 : oneMin) as NSNumber
            x.orthogonalPosition    = 0.0
            x.minorTicksPerInterval = 0
            
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 10
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 0.0

            y.labelingPolicy = .none
        }
        

        newGraph.add(generatePlotLine("lf", CPTColor.magenta()),to: plotSpace)
        newGraph.add(generatePlotLine("lm", CPTColor.blue()),to: plotSpace)
        newGraph.add(generatePlotLine("lb", CPTColor.purple()),to: plotSpace)
        newGraph.add(generatePlotLine("rf", CPTColor.red()),to: plotSpace)
        newGraph.add(generatePlotLine("rm", CPTColor.orange()),to: plotSpace)
        newGraph.add(generatePlotLine("rb", CPTColor.yellow()),to: plotSpace)

        
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
            case ("lf" as NSString):
                return insights?.secsData[Int(record)].lfAv
            case ("lm" as NSString):
                return insights?.secsData[Int(record)].lmAv
            case ("lb" as NSString):
                return insights?.secsData[Int(record)].lbAv
            case ("rf" as NSString):
                return insights?.secsData[Int(record)].rfAv
            case ("rm" as NSString):
                return insights?.secsData[Int(record)].rmAv
            case ("rb" as NSString):
                return insights?.secsData[Int(record)].rbAv
            default:
                return nil
            }
        @unknown default:
            return nil
        }
    }
        
}
