//
//  CompleteRunViewController.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 3/29/21.
//

import UIKit
import Foundation
import CorePlot

class CompleteRunViewController: UIViewController, CPTPlotDataSource {

    private let oneDay : Double = 24 * 60 * 60
    private let oneMin : Double = 60

    @IBOutlet var hostView : CPTGraphHostingView!

    private var graph : CPTXYGraph? = nil

    private var plotData = [Double]()
    
    private let dataInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        let refDate = DateFormatter().date(from: "12:00")

        // Create graph
        let newGraph = CPTXYGraph(frame: .zero)

        let theme = CPTTheme(named: .darkGradientTheme)
        newGraph.apply(theme)

        if let host = self.hostView {
            host.hostedGraph = newGraph
        }

        // Setup scatter plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace

        let interval = endTime.timeIntervalSince(startTime) * 2 //*2 for the data interval
        
        //interval in seconds
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: (NSInteger(interval)) as NSNumber)
        plotSpace.yRange = CPTPlotRange(location: 0.0, length: 150.0)

        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = oneMin*2 as NSNumber
            x.orthogonalPosition    = 0.0
            x.minorTicksPerInterval = 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let timeFormatter = CPTTimeFormatter(dateFormatter:dateFormatter)
            timeFormatter.referenceDate = refDate
            x.labelFormatter            = timeFormatter
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 10
            y.minorTicksPerInterval = 1
            y.orthogonalPosition    = 0

            y.labelingPolicy = .none
        }

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot(frame: .zero)
        dataSourceLinePlot.identifier = "Date Plot" as NSString
        
        self.plotData = newPlotData()

        if let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as? CPTMutableLineStyle {
            lineStyle.lineWidth              = 3.0
            lineStyle.lineColor              = .green()
            dataSourceLinePlot.dataLineStyle = lineStyle
        }

        dataSourceLinePlot.dataSource = self
        newGraph.add(dataSourceLinePlot)

        self.graph = newGraph
    }

    func newPlotData() -> [Double]
    {
        var newData: [Double] = []
        
        for datapoint in selectedSession!.frontArr {
            newData.append(datapoint.val)
        }
        return newData
    }

    // MARK: - Plot Data Source Methods
    func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        return UInt(self.plotData.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
    {
        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            return (oneDay * Double(record)) as NSNumber
            
        case .Y:
            return self.plotData[Int(record)] as NSNumber

        @unknown default:
            return nil
        }
    }


}
