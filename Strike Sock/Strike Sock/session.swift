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
    
    func end() {
        self.endTime = Date()
        isUpdating = false
        complete = true
    }
    

}
