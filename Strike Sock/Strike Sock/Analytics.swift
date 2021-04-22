//
//  Analytics.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 4/13/21.
//

import Foundation

enum Sensor {
    case lf
    case lm
    case lb
    case rf
    case rm
    case rb
}

class StrikeType {
    static let front = [0.6, 0.2, 0.2]
    static let mid = [0.33, 0.33, 0.33]
    static let back = [0.2, 0.2, 0.6]
    static let strikeMappings : [Strike : [Double]] = [.front : front, .mid : mid, .back: back]
}

enum Strike : String{
    case front = "Front"
    case mid = "Mid"
    case back = "Back"
}

struct perSecData {
    var lfAv, lmAv, lbAv, rfAv, rmAv, rbAv: Double
    var startTimeInterval: Int
    var lFMBVec : [Double]
    var rFMBVec : [Double]
    var avLRBalance : [Double]
    var countlf, countlm, countlb, countrf, countrm, countrb: Int
    var strikeType : Strike
    
    init(timeInt:Int = 0) {
        lfAv = 0
        lmAv = 0
        lbAv = 0
        rfAv = 0
        rmAv = 0
        rbAv = 0
        startTimeInterval = timeInt
        lFMBVec = []
        rFMBVec = []
        avLRBalance = []
        countlf = 0
        countlm = 0
        countlb = 0
        countrf = 0
        countrm = 0
        countrb = 0
        strikeType = .front
    }
    
    mutating func addData(lf: Double = -1, lm: Double = -1, lb: Double = -1, rf: Double = -1, rm: Double = -1, rb: Double = -1) {
        if lf > 0.0 {
            self.countlf += 1
            self.lfAv = calculateNewAv(newVal: lf, oldAv: self.lfAv, newCount: self.countlf)
            return
        }
        if lm > 0.0 {
            self.countlm += 1
            self.lmAv = calculateNewAv(newVal: lm, oldAv: self.lmAv, newCount: self.countlm)
            return
        }
        if lb > 0.0 {
            self.countlb += 1
            self.lbAv = calculateNewAv(newVal: lb, oldAv: self.lbAv, newCount: self.countlb)
            return
        }
        if rf > 0.0{
            self.countrf += 1
            self.rfAv = calculateNewAv(newVal: rf, oldAv: self.rfAv, newCount: self.countrf)
            return
        }
        if rm > 0.0 {
            self.countrm += 1
            self.rmAv = calculateNewAv(newVal: rm, oldAv: self.rmAv, newCount: self.countrm)
            return
        }
        if rb > 0.0 {
            self.countrb += 1
            self.rbAv = calculateNewAv(newVal: rb, oldAv: self.rbAv, newCount: self.countrb)
            return
        }
    }
    
    mutating func closeSelf() {
        lFMBVec = ratio([self.lfAv, self.lmAv, self.lbAv])
        rFMBVec = ratio([self.rfAv, self.rmAv, self.rbAv])
        avLRBalance = ratio([self.lfAv + self.lmAv + self.lbAv, self.rfAv + self.rmAv + self.rbAv])
        strikeType = decideStrikeType(left: lFMBVec, right: rFMBVec)
        //print("closing second data, the strike type is \(strikeType.rawValue)")
    }
    
    func calculateNewAv(newVal:Double, oldAv:Double, newCount:Int) -> Double{
        return (newVal + (Double(newCount) - 1.0)*oldAv)/Double(newCount)
    }
    
    
}

struct perMinData {
    var lfAv, lmAv, lbAv, rfAv, rmAv, rbAv: Double
    var secData : [perSecData]
    var avLRBalance : [Double]
    var lFMBVec : [Double]
    var rFMBVec : [Double]
    var consistency : Double
    var strikeType : Strike
    var startTimeInterval : Int
    var countFront : Int
    var countMid : Int
    var countBack : Int
    
    init(timeInt:Int = 0) {
        lfAv = 0
        lmAv = 0
        lbAv = 0
        rfAv = 0
        rmAv = 0
        rbAv = 0
        consistency = 0.0
        countFront = 0
        countMid = 0
        countBack = 0
        secData = []
        avLRBalance = []
        lFMBVec = []
        rFMBVec = []
        avLRBalance = []
        strikeType = .front
        self.startTimeInterval = timeInt
    }
    
    mutating func closeSelf() {
        
        if (avLRBalance.count != 0 ) {
            return
        }
        
        secData.forEach( {value in
            self.lfAv += value.lfAv
            self.lmAv += value.lmAv
            self.lbAv += value.lbAv
            self.rfAv += value.rfAv
            self.rmAv += value.rmAv
            self.rbAv += value.rbAv
            switch value.strikeType {
            case .front:
                countFront += 1
            case .mid:
                countMid += 1
            case .back:
                countBack += 1
            }
        })
        self.lfAv = self.lfAv/Double(secData.count)
        self.lmAv = self.lmAv/Double(secData.count)
        self.lbAv = self.lbAv/Double(secData.count)
        self.rfAv = self.rfAv/Double(secData.count)
        self.rmAv = self.rmAv/Double(secData.count)
        self.rbAv = self.rbAv/Double(secData.count)
        
        lFMBVec = ratio([self.lfAv, self.lmAv, self.lbAv])
        rFMBVec = ratio([self.rfAv, self.rmAv, self.rbAv])
        avLRBalance = ratio([self.lfAv + self.lmAv + self.lbAv, self.rfAv + self.rmAv + self.rbAv])
        strikeType = decideStrikeType(left: lFMBVec, right: rFMBVec)
        switch strikeType {
        case .front:
            consistency = Double(countFront)/Double(secData.count)
        case .mid:
            consistency = Double(countMid)/Double(secData.count)
        case .back:
            consistency = Double(countBack)/Double(secData.count)
        }
//        print("consistency data, counts: \(countFront), \(countMid), \(countBack), sec data count is \(secData.count)")
//        print("Closed minute data, \(self.lfAv), \(self.lmAv), \(self.lbAv), \(self.rfAv), \(self.rmAv), \(self.rbAv)")
//        print("left vector \(lFMBVec), right vector \(rFMBVec), consistency \(consistency), balance \(avLRBalance)")
    }
    
    func getBalance()->String {
        return "\(avLRBalance[0].format())/\(avLRBalance[1].format())"
    }
}

class Analytics {
    var session : Session
    var startTime : Date
    var minuteData : [perMinData]
    var secsData : [perSecData]
    //overall data
    var avLRBalance : [Double]
    var lFMBVec : [Double]
    var rFMBVec : [Double]
    var consistency : Double
    var strikeType : Strike
    
    var maxima:Maxima?
    
    init( sess : Session ) {
        maxima = Maxima.loadData()
        self.session = sess
        self.startTime = sess.startTime ?? Date()
        minuteData = []
        secsData = []
        avLRBalance = []
        lFMBVec = []
        rFMBVec = []
        consistency = 0.0
        strikeType = .front
        generateAnalyzedDate()
    }
    
    func generateAnalyzedDate() {
        var lfInd = 0, lmInd = 0, lbInd = 0, rfInd = 0, rmInd = 0, rbInd = 0
        var lf = 0.0, lm = 0.0, lb = 0.0, rf = 0.0, rm = 0.0, rb = 0.0
        var countFront = 0, countMid = 0, countBack = 0
        
        guard let endTime = session.endTime else { return }
        
        var currMinIdx = -1
        
        for index in 0...getFlooredSecond(date: endTime) {
            //print("analyzing second \(index)")
            if (index % 60 == 0) {
                //print("hit the top of a minute")
                if (currMinIdx>=0) {
                    minuteData[currMinIdx].closeSelf()
                }
                minuteData.append( perMinData(timeInt: index) )
                currMinIdx += 1
            }
            
            var secData = perSecData(timeInt: index)
            (lfInd, secData) = iterateThroughSecond(currInd: lfInd, currSec: index, arr: session.lfrontArr, sens: .lf, node: secData)
            (lmInd, secData) = iterateThroughSecond(currInd: lmInd, currSec: index, arr: session.lmidArr, sens: .lm, node: secData)
            (lbInd, secData) = iterateThroughSecond(currInd: lbInd, currSec: index, arr: session.lbackArr, sens: .lb, node: secData)
            (rfInd, secData) = iterateThroughSecond(currInd: rfInd, currSec: index, arr: session.rfrontArr, sens: .rf, node: secData)
            (rmInd, secData) = iterateThroughSecond(currInd: rmInd, currSec: index, arr: session.rmidArr, sens: .rm, node: secData)
            (rbInd, secData) = iterateThroughSecond(currInd: rbInd, currSec: index, arr: session.rbackArr, sens: .rb, node: secData)

            secsData.append(secData)
            secData.closeSelf()
            minuteData[currMinIdx].secData.append(secData)
            
            lf += secData.lfAv
            lm += secData.lmAv
            lb += secData.lbAv
            rf += secData.rfAv
            rm += secData.rmAv
            rb += secData.rbAv
            
            //overall data
            switch secData.strikeType {
            case .front:
                countFront += 1
            case .mid:
                countMid += 1
            case .back:
                countBack += 1
            }
            
        }
        if (currMinIdx >= 0) {
            minuteData[currMinIdx].closeSelf()
        }
        
        //overall data
        var maxCount = 0
        maxCount = checkStrikeMax(countFront, maxCount, .front)
        maxCount = checkStrikeMax(countMid, maxCount, .mid)
        maxCount = checkStrikeMax(countBack, maxCount, .back)

        lFMBVec = ratio([lf/Double(secsData.count), lm/Double(secsData.count), lb/Double(secsData.count)])
        rFMBVec = ratio([rf/Double(secsData.count), rm/Double(secsData.count), rb/Double(secsData.count)])
        avLRBalance = ratio([ (lf+lm+lb)/Double(secsData.count), (rf+rm+rb)/Double(secsData.count) ])
    }
    
    func checkStrikeMax(_ count:Int, _ maxCount:Int, _ type: Strike) -> Int{
        var max = maxCount
        if (count > max) {
            strikeType = type
            consistency = Double(count)/Double(secsData.count)
            max = count
        }
        return max
    }
    
    func getBalance()->String {
        return "\(avLRBalance[0].format())/\(avLRBalance[1].format())"
    }
    
    func iterateThroughSecond(currInd: Int, currSec: Int, arr: [dataPoint], sens:Sensor, node: perSecData) -> (Int, perSecData) {
        var index = currInd
        var tempNode = node
        while (arr.count > index && getFlooredSecond(date: arr[index].time) <= currSec) {
            if (getFlooredSecond(date: arr[currInd].time) == currSec) {
                switch sens {
                case .lf:
                    tempNode.addData(lf: arr[index].val/Double(maxima?.largestLToe ?? 20))
                case .lm:
                    tempNode.addData(lm: arr[index].val/Double(maxima?.largestLMid ?? 20))
                case .lb:
                    tempNode.addData(lb: arr[index].val/Double(maxima?.largestLHeel ?? 20))
                case .rf:
                    tempNode.addData(rf: arr[index].val/Double(maxima?.largestRToe ?? 20))
                case .rm:
                    tempNode.addData(rm: arr[index].val/Double(maxima?.largestRMid ?? 20))
                case .rb:
                    tempNode.addData(rb: arr[index].val/Double(maxima?.largestRHeel ?? 20))
                }
            }
            index+=1
        }
        return (index, tempNode)
    }
    
    func getFlooredSecond( date: Date ) -> Int {
        return Int(floor(date.timeIntervalSince(startTime)))
    }
    
}
