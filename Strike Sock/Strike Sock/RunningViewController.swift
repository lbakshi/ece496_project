//
//  ViewController.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 2/16/21.
//

import UIKit
import CoreBluetooth
import CorePlot

class RunningViewController: UIViewController, CBPeripheralDelegate,
                      CBCentralManagerDelegate {

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var runningSession : Session?
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var frontText: UILabel!
    @IBOutlet weak var midText: UILabel!
    @IBOutlet weak var backText: UILabel!
    
    @IBOutlet weak var graphView: CPTGraphHostingView!
    var plotData = [Double](repeating: 0.0, count: 1000)
    var plot : CPTScatterPlot!
    var maxDataPoints = 100
    var frameRate = 5.0
    var alphaValue = 0.25
    var timer : Timer?
    var currentIndex: Int!
    var timeDuration:Double = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusText.text = "Initializing"
        frontText.text = "No data"
        midText.text = "No data"
        backText.text = "No data"
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        initializeGraph()
    }
    @IBAction func generateData(_ sender: Any) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: self.timeDuration, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        statusUpdate("Central State update")
        if central.state != .poweredOn {
            statusUpdate("Central is not powered on")
        } else {
            statusUpdate("Central scanning for \(HardwarePeripheral.serviceUUID)");
            centralManager.scanForPeripherals(withServices: [HardwarePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.centralManager.stopScan()
        
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            statusUpdate("Connected to the sock")
            peripheral.discoverServices([HardwarePeripheral.serviceUUID])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == HardwarePeripheral.serviceUUID {
                    statusUpdate("Service Found")
                    
                    peripheral.discoverCharacteristics([HardwarePeripheral.frontCharUUID, HardwarePeripheral.midCharUUID, HardwarePeripheral.backCharUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == HardwarePeripheral.frontCharUUID {
                    statusUpdate("Front sensor characteristic found")
                } else if characteristic.uuid == HardwarePeripheral.midCharUUID {
                    statusUpdate("Mid sensor characteristic found")
                } else if characteristic.uuid == HardwarePeripheral.backCharUUID {
                    statusUpdate("Back sensor characteristic found")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let e = error {
            statusUpdate("ERROR in updating peripheral value \(e)")
            return
        }
        guard let data = descriptorDescription(for: descriptor) else { return }
        
        switch descriptor.characteristic.uuid {
            case HardwarePeripheral.frontCharUUID:
                frontText.text = data
            case HardwarePeripheral.midCharUUID:
                midText.text = data
            case HardwarePeripheral.backCharUUID:
                backText.text = data
        default:
            statusUpdate("ERROR in processing peripheral data")
        }
        
        return
    }
    
    func statusUpdate(_ text:String) {
        statusText.text = text
        print(text)
    }
    
    func descriptorDescription(for descriptor: CBDescriptor) -> String? {

        var description: String?
        var value: String?

        switch descriptor.uuid.uuidString {
        case CBUUIDCharacteristicFormatString:
            if let data = descriptor.value as? Data {
                description = "Characteristic format: "
                value = data.description
            }
        case CBUUIDCharacteristicUserDescriptionString:
            if let val = descriptor.value as? String {
                description = "User description: "
                value = val
            }
        case CBUUIDCharacteristicExtendedPropertiesString:
            if let val = descriptor.value as? NSNumber {
                description = "Extended Properties: "
                value = val.description
            }
        case CBUUIDClientCharacteristicConfigurationString:
            if let val = descriptor.value as? NSNumber {
                description = "Client characteristic configuration: "
                value = val.description
            }
        case CBUUIDServerCharacteristicConfigurationString:
            if let val = descriptor.value as? NSNumber {
                description = "Server characteristic configuration: "
                value = val.description
            }
        case CBUUIDCharacteristicAggregateFormatString:
            if let val = descriptor.value as? String {
                description = "Characteristic aggregate format: "
                value = val
            }
        default:
            break
        }

        if let desc=description, let val = value  {
            return "\(desc)\(val)"
        } else {
            return nil
        }
    }
}

extension RunningViewController : CPTScatterPlotDataSource & CPTScatterPlotDelegate {
        
    @objc func fireTimer(){
        let graph = self.graphView.hostedGraph
        let plot = graph?.plot(withIdentifier: "mindful-graph" as NSCopying)
        if((plot) != nil){
            if(self.plotData.count >= maxDataPoints){
                self.plotData.removeFirst()
                plot?.deleteData(inIndexRange:NSRange(location: 0, length: 1))
            }
        }
        guard let plotSpace = graph?.defaultPlotSpace as? CPTXYPlotSpace else { return }
        
        let location: NSInteger
        if self.currentIndex >= maxDataPoints {
            location = self.currentIndex - maxDataPoints + 2
        } else {
            location = 0
        }
        
        let range: NSInteger
        
        if location > 0 {
            range = location-1
        } else {
            range = 0
        }
        
        let oldRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(range)), lengthDecimal: CPTDecimalFromDouble(Double(maxDataPoints-2)))
        let newRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(location)), lengthDecimal: CPTDecimalFromDouble(Double(maxDataPoints-2)))
    
        CPTAnimation.animate(plotSpace, property: "xRange", from: oldRange, to: newRange, duration:0.3)
        
        self.currentIndex += 1;
        let point = Double.random(in: 75...85)
        self.plotData.append(point)
        plot?.insertData(at: UInt(self.plotData.count-1), numberOfRecords: 1)
    }

    func initializeGraph(){
        configureGraphtView()
        configurePlot()
    }

    func configureGraphtView(){
        self.currentIndex = 0
        graphView.allowPinchScaling = false
        self.plotData.removeAll()
        //self.currentIndex = 0
               
        //Configure graph
        let graph = CPTXYGraph(frame: graphView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        graphView.hostedGraph = graph
        graph.backgroundColor = UIColor.black.cgColor
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingTop = 30.0
        graph.paddingRight = 15.0

        //Style for graph title
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.white()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 20.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle

        //Set graph title
        let title = "CorePlot"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: 0.0)
    
        let axisSet = graph.axisSet as! CPTXYAxisSet
                
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.white()
        axisTextStyle.fontName = "HelveticaNeue-Bold"
        axisTextStyle.fontSize = 10.0
        axisTextStyle.textAlignment = .center
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.white()
        lineStyle.lineWidth = 5
        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineColor = CPTColor.gray()
        gridLineStyle.lineWidth = 0.5


        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 20
            x.minorTicksPerInterval = 5
            x.labelTextStyle = axisTextStyle
            x.minorGridLineStyle = gridLineStyle
            x.axisLineStyle = lineStyle
            x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            x.delegate = self
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 5
            y.minorTicksPerInterval = 5
            y.minorGridLineStyle = gridLineStyle
            y.labelTextStyle = axisTextStyle
            y.alternatingBandFills = [CPTFill(color: CPTColor.init(componentRed: 255, green: 255, blue: 255, alpha: 0.03)),CPTFill(color: CPTColor.black())]
            y.axisLineStyle = lineStyle
            y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            y.delegate = self
        }
        
        // Set plot space
        let xMin = 0.0
        let xMax = 100.0
        let yMin = 65.0
        let yMax = 95.0
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
    }
    
    func configurePlot(){
        self.plot = CPTScatterPlot()
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineJoin = .round
        plotLineStile.lineCap = .round
        plotLineStile.lineWidth = 2
        plotLineStile.lineColor = CPTColor.white()
        plot.dataLineStyle = plotLineStile
        plot.curvedInterpolationOption = .catmullCustomAlpha
        plot.interpolation = .curved
        plot.identifier = "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol
        guard let graph = graphView.hostedGraph else { return }
        plot.dataSource = (self as CPTPlotDataSource)
        plot.delegate = (self as CALayerDelegate)
        graph.add(plot, to: graph.defaultPlotSpace)
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(self.plotData.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        switch CPTScatterPlotField(rawValue: Int(field))! {
            case .X:
                return NSNumber(value: Int(record) + self.currentIndex-self.plotData.count)
            case .Y:
                return self.plotData[Int(record)] as NSNumber
            default:
                return 0
        }
    }
}

