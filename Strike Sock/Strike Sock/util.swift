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
