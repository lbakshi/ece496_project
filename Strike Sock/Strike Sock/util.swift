//
//  util.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 3/10/21.
//

import Foundation

func stringFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, MMM d, h:mm a"
    return formatter.string(from: date)
}

func dateFromtString(_ str: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy HH:mm"
    return formatter.date(from: str)!
}

func ratio(_ arr: [Double]) -> [Double] {
    if (arr.count == 0) {
        return []
    }
    var sum = 0.0
    arr.forEach{ val in sum += val /*Double(pow(val, 2))*/ }
    //sum = sum.squareRoot()
    var out: [Double] = []
    for val in arr {
        out.append(val/sum)
    }
    return out
}

func rmsError(_ arr1: [Double], _ arr2: [Double]) -> Double{
    if arr1.count != arr2.count {
        return -1
    }
    var sum = 0.0
    for idx in 0..<arr1.count {
        sum += pow(arr1[idx]-arr2[idx],2)
    }
    return sum.squareRoot()/Double(arr1.count)
}

func decideStrikeType(left : [Double], right: [Double]) -> Strike{
    var minError: Double = Double(MAXFLOAT)
    var currMatch:Strike = .front
    let concatLRArr : [Double] = left + right
    for strikeType in StrikeType.strikeMappings.keys {
        let strikeConcatArr = StrikeType.strikeMappings[strikeType]!+StrikeType.strikeMappings[strikeType]!
        let err = rmsError(concatLRArr, strikeConcatArr)
        if err < 0 {
            print("got error of -1")
        }
        if err < minError {
            currMatch = strikeType
            minError = err
        }
    }
    return currMatch
}

extension Double {
    func format(f: String = ".1") -> String {
        return String(format: "%\(f)f", self*100)
    }
}
