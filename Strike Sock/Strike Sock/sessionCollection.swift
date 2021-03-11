//
//  sessionCollection.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 3/10/21.
//

import Foundation

class SessionCollection: Codable {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("StrikeSockJSON")
    
    var sessionArr : [Session]
    
    init() {
        sessionArr = []
    }
    
    func addSession(_ session:Session) {
        sessionArr.append(session)
    }
    
    func deleteSession(_ session:Session) {
        sessionArr.removeAll(where: {$0.startTime == session.startTime})
    }
    
    /*
     function to save Duke folk data
     */
    static func saveData(_ dataArr: SessionCollection) -> Bool {
        var outputData = Data()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dataArr) {
            if String(data: encoded, encoding: .utf8) != nil {
                outputData = encoded
            } else { return false }
            do {
                try outputData.write(to: ArchiveURL)
            } catch let error as NSError {
                print(error)
                return false
            }
            return true
        }
        else { return false }
    }
    
    /*
     function to load data from JSON
     */
    static func loadData() -> SessionCollection? {
        let decoder = JSONDecoder()
        var outData = SessionCollection()
        let tempData: Data
        
        do {
            tempData = try Data(contentsOf: ArchiveURL)
        } catch let error as NSError {
            print(error)
            return outData
        }
        if let decoded = try? decoder.decode(SessionCollection.self, from: tempData) {
            outData = decoded
        }
        return outData
    }
}
