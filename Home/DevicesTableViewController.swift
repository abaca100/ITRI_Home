//
//  DevicesTableViewController.swift
//  Home
//
//  Created by Jack Lee on 12/16/15.
//  Copyright © 2015 itri. All rights reserved.
//

import UIKit
import HomeKit

class DevicesTableViewController: UITableViewController, HMHomeManagerDelegate, HMHomeDelegate {

    struct Identifiers {
        static let homeCell = "HomeCell"
    }
    
    var homeManager: HMHomeManager?
    var homes = [HMHome]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ITRI Apple HomeKit Test"
        
        self.homeManager = HMHomeManager()
        self.homeManager?.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHomes", name: "UpdateHomesNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePrimaryHome", name: "UpdatePrimaryHomeNotification", object: nil)

        homes = (self.homeManager?.homes)!
        print("\(homes)")
        
        for home in homes {
            home.delegate = self
        }
    }

    // delegate HMHomeManagerDelegate
    func homeManagerDidUpdateHomes(manager: HMHomeManager)
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        print("\(self.homeManager?.homes)")
        
        homes = (self.homeManager?.homes)!

        if homes.isEmpty
        {
            self.homeManager?.addHomeWithName("ITRI", completionHandler: { newHome, error in
                if let _ = error {
                    print("error \(error)")
                    return
                }
                
                self.homes = (self.homeManager?.homes)!
                
                let roomName = "Live Room"
                self.homeManager?.addHomeWithName(roomName, completionHandler: { newRoom, error in
                    if let _ = error {
                        print("error \(error)")
                    }
                })
                
                let bedRoom = "Bed Room"
                self.homeManager?.addHomeWithName(bedRoom, completionHandler: { newRoom, error in
                    if let _ = error {
                        print("error \(error)")
                    }
                })
            })
        }
        
        homes = (self.homeManager?.homes)!
        print("homes.count=\(homes.count)")
        tableView.reloadData()
        
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateHomesNotification", object: self)
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        for h in (self.homeManager?.homes)!
        {
            self.homeManager?.removeHome(h, completionHandler: { _ in })
        }
        homes = (self.homeManager?.homes)!
        tableView.reloadData()
    }
    
    func homeManagerDidUpdatePrimaryHome(manager: HMHomeManager)
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName("UpdatePrimaryHomeNotification", object: self)
    }
    
    func updateHomes()
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
    }
    
    func updatePrimaryHome()
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
    }
    
    // delegate HMHomeDelegate
    func homeDidUpdateName(home: HMHome) {
        
    }
    
    func home(home: HMHome, didAddAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    func home(home: HMHome, didRemoveAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return homes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.homeCell, forIndexPath: indexPath)
        let home = homes[indexPath.row]
        
        cell.textLabel?.text = home.name
        cell.detailTextLabel?.text = NSLocalizedString("My Home", comment: "My Home")
        
        return cell
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
