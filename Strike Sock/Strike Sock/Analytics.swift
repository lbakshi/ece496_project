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

struct perSecData {
    var lfAv, lmAv, lbAv, rfAv, rmAv, rbAv: Double
    var startTimeInterval: Int
    var lFMBVec : [Double]
    var rFMBVec : [Double]
    var avLRBalance : [Double]
    var countlf, countlm, countlb, countrf, countrm, countrb: Int
    
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
        lFMBVec = normalize([self.lfAv, self.lmAv, self.lbAv])
        rFMBVec = normalize([self.rfAv, self.rmAv, self.rbAv])
        avLRBalance = normalize([self.lfAv + self.lmAv + self.lbAv, self.rfAv + self.rmAv + self.rbAv])
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
    var startTimeInterval : Int
    
    init(timeInt:Int = 0) {
        lfAv = 0
        lmAv = 0
        lbAv = 0
        rfAv = 0
        rmAv = 0
        rbAv = 0
        secData = []
        avLRBalance = []
        lFMBVec = []
        rFMBVec = []
        avLRBalance = []
        self.startTimeInterval = timeInt
    }
}

class Analytics {
    var session : Session
    var startTime : Date
    var minuteData : [perMinData]
    var secsData : [perSecData]
    
    init( sess : Session ) {
        self.session = sess
        self.startTime = sess.startTime ?? Date()
        minuteData = []
        secsData = []
        generateAnalyzedDate()
    }
    
    func generateAnalyzedDate() {
        var lfInd = 0, lmInd = 0, lbInd = 0, rfInd = 0, rmInd = 0, rbInd = 0
        
        guard let endTime = session.endTime else { return }
        
        var currMinIdx = -1
        
        for index in 0...getFlooredSecond(date: endTime) {
            if (index % 60 == 0) {
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
            minuteData[currMinIdx].secData.append(secData)
        }
    }
    
    func iterateThroughSecond(currInd: Int, currSec: Int, arr: [dataPoint], sens:Sensor, node: perSecData) -> (Int, perSecData) {
        var index = currInd
        var tempNode = node
        while (arr.count > index && getFlooredSecond(date: arr[index].time) <= currSec) {
            if (getFlooredSecond(date: arr[currInd].time) == currSec) {
                switch sens {
                case .lf:
                    tempNode.addData(lf: arr[index].val)
                case .lm:
                    tempNode.addData(lm: arr[index].val)
                case .lb:
                    tempNode.addData(lb: arr[index].val)
                case .rf:
                    tempNode.addData(rf: arr[index].val)
                case .rm:
                    tempNode.addData(rm: arr[index].val)
                case .rb:
                    tempNode.addData(rb: arr[index].val)
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
