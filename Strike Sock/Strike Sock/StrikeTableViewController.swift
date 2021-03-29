//
//  StrikeTableViewController.swift
//  Strike Sock
//
//  Created by Lakshya Bakshi on 3/10/21.
//

import UIKit

var selectedSession : Session?

class StrikeTableViewController: UITableViewController {

    var sessionColl : SessionCollection = SessionCollection()
    override func viewDidLoad() {
        super.viewDidLoad()

        loadInitialData()
        self.tableView.reloadData()
    }
    /**
     load data from JSON if possible, otherwise use the default construction and save that to JSON
     */
    func loadInitialData() {
        if let tempColl = SessionCollection.loadData() {
            sessionColl = tempColl
        } else {
            let _ = SessionCollection.saveData(sessionColl)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sessionColl.sessionArr.count
    }
    
    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionProtoCell", for: indexPath) as! SessionProtoCell
        let tempSession:Session = sessionColl.sessionArr[indexPath.row]
        guard let time = tempSession.startTime else { return cell }
        cell.cellLabel.text = stringFromDate(time)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sessionColl.sessionArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let _ = SessionCollection.saveData(sessionColl)
            self.tableView.reloadData()
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSession = sessionColl.sessionArr[indexPath.row]
        print("selected session is \(stringFromDate(selectedSession!.startTime!))")
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? CompleteRunViewController {
            print("setting destination view controller")
            //destVC.session = selectedSession
        } else {
            print("error in setting destination session")
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

class SessionProtoCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
}
