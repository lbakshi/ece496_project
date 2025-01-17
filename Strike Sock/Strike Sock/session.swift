//
//  session.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 3/10/21.
//

import Foundation

struct dataPoint:Codable {
    var time: Date
    var val: Double
}


class Session : Codable {
    
    var startTime:Date?
    var endTime:Date?
    var lfrontArr:[dataPoint]
    var lmidArr:[dataPoint]
    var lbackArr:[dataPoint]
    var rfrontArr:[dataPoint]
    var rmidArr:[dataPoint]
    var rbackArr:[dataPoint]
    var isUpdating:Bool
    var complete:Bool
    
    init() {
        lfrontArr = []
        lmidArr = []
        lbackArr = []
        rfrontArr = []
        rmidArr = []
        rbackArr = []
        isUpdating = false
        complete = false
    }
    
    init(range:Double) {
        lfrontArr = []
        lmidArr = []
        lbackArr = []
        rfrontArr = []
        rmidArr = []
        rbackArr = []
        isUpdating = false
        complete = true
        self.startTime = Date()
        self.endTime = Date(timeIntervalSinceNow: range)
        for f in stride(from: 0, through: range, by: 0.5) {
            lfrontArr.append(dataPoint(time: Date(timeIntervalSinceNow: f), val: Double.random(in: 0...20)))
            lmidArr.append(dataPoint(time: Date(timeIntervalSinceNow: f), val: Double.random(in: 0...20)))
            lbackArr.append(dataPoint(time: Date(timeIntervalSinceNow: f), val: Double.random(in: 0...20)))
            rfrontArr.append(dataPoint(time: Date(timeIntervalSinceNow: f), val: Double.random(in: 0...20)))
            rmidArr.append(dataPoint(time: Date(timeIntervalSinceNow: f), val: Double.random(in: 0...20)))
            rbackArr.append(dataPoint(time: Date(timeIntervalSinceNow: f), val: Double.random(in: 0...20)))
        }
    }
    
    func start() {
        self.startTime = Date()
        isUpdating = true
    }
    
    /*
     ends the session and saves it to the user's data
     */
    func end() {
        if complete {
            return
        }
        if let _ = self.endTime {
        } else {
            self.endTime = Date()
        }
        isUpdating = false
        complete = true
        
        if let _ = self.startTime {
            let arr = SessionCollection.loadData() ?? SessionCollection()
            arr.addSession(self)
            print("saving session state")
            let _ = SessionCollection.saveData(arr)
        }
    }
    
    func printSession() {
        print("left Front arr has \(lfrontArr.count) entries")
        print("left Mid arr has \(lmidArr.count) entries")
        print("left back arr has \(lbackArr.count) entries")
        print("left front Arr entries are")
        for entry in lfrontArr {
            print("\(entry.val)", terminator: ", ")
        }
    }
    

}

