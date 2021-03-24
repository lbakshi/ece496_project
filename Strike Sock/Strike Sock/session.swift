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
    var frontArr:[dataPoint]
    var midArr:[dataPoint]
    var backArr:[dataPoint]
    var isUpdating:Bool
    var complete:Bool
    
    init() {
        frontArr = []
        midArr = []
        backArr = []
        isUpdating = false
        complete = false
    }
    
    func start() {
        self.startTime = Date()
        isUpdating = true
    }
    
    func update(front: Double?, mid: Double?, back: Double?) {
        if let val = front {
            frontArr.append(dataPoint(time: Date(), val: val))
        }
        
        if let val = mid {
            midArr.append(dataPoint(time: Date(), val: val))
        }
        
        if let val = back {
            backArr.append(dataPoint(time: Date(), val: val))
        }
    }
    /*
     ends the session and saves it to the user's data
     */
    func end() {
        if let _ = self.endTime {
        } else {
            self.endTime = Date()
        }
        isUpdating = false
        complete = true
        
        let arr = SessionCollection.loadData() ?? SessionCollection()
        arr.addSession(self)
        print("saving session state")
        let _ = SessionCollection.saveData(arr)
    }
    

}
