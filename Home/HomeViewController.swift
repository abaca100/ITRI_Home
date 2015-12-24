//
//  HomeViewController.swift
//  Home
//
//  Created by Jack Lee on 12/22/15.
//  Copyright © 2015 itri. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController, HMHomeDelegate, HMHomeManagerDelegate {

    // MARK: Properties
    var homeStore: HomeStore {
        return HomeStore.sharedStore
    }
    
    var home: HMHome! {
        return homeStore.home
    }

    // MARK: - View
    override func viewDidLoad()
    {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHomes", name: "UpdateHomesNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePrimaryHome", name: "UpdatePrimaryHomeNotification", object: nil)
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        
        homeStore.home?.delegate = self
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBAction
    @IBAction func roomAction(sender: UIButton)
    {
        displayMessage((sender.titleLabel?.text)!, message: "hello")
    }
    
    // MARK: HMHomeManagerDelegate
    func homeManagerDidUpdateHomes(manager: HMHomeManager)
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
    }
    
    func homeManagerDidUpdatePrimaryHome(manager: HMHomeManager)
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
    }
    
    
    // MARK: - Observer
    func updateHomes()
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        
        print("\(homeStore.homeManager.homes)")
        
        if !(homeStore.homeManager.primaryHome?.name == nil)
        {
//            for h in (homeStore.homeManager.homes)
//            {
//                homeStore.homeManager.removeHome(h, completionHandler: { _ in })
//            }
            
            self.title = "PrimaryHome: \(homeStore.homeManager.primaryHome!.name)"
        }
        else
        {
            homeStore.homeManager.addHomeWithName("ITRI", completionHandler: { newHome, error in
                if let _ = error {
                    print("error \(error)")
                }
            })
        }

        if homeStore.homeManager.primaryHome?.rooms.count == 0
        {
            let h: HMHome = homeStore.homeManager.primaryHome!
            let roomName = "Living room"
            h.addRoomWithName(roomName, completionHandler: { newRoom, error in
                if let _ = error {
                    print("error \(error)")
                }
            })
            
            let bedRoom = "Bedroom"
            h.addRoomWithName(bedRoom, completionHandler: { newRoom, error in
                if let _ = error {
                    print("error \(error)")
                }
            })
            
            let garage = "Garage"
            h.addRoomWithName(garage, completionHandler: { newRoom, error in
                if let _ = error {
                    print("error \(error)")
                }
            })
        }
    }
    
    func updatePrimaryHome()
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
    }
    
    // MARK: - HMHomeDelegate
    func homeDidUpdateName(home: HMHome)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    func home(home: HMHome, didAddAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    func home(home: HMHome, didRemoveAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    // MARK: - deinit
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
