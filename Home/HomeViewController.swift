//
//  HomeViewController.swift
//  Home
//
//  Created by Jack Lee on 12/22/15.
//  Copyright © 2015 itri. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController, HMHomeDelegate, HMHomeManagerDelegate, HMAccessoryBrowserDelegate, HMAccessoryDelegate {

    // MARK: Properties
    var homeStore: HomeStore {
        return HomeStore.sharedStore
    }
    
    var home: HMHome! {
        return homeStore.home
    }
    
    var homeManager: HMHomeManager {
        return homeStore.homeManager
    }
    

    @IBOutlet weak var bedroom: UIButton!
    @IBOutlet weak var livingroom: UIButton!
    @IBOutlet weak var garage: UIButton!
    @IBOutlet weak var lbl_browsing: UILabel!
    @IBOutlet weak var info: UIActivityIndicatorView!
    @IBOutlet weak var txt_msg: UITextView!
    
    var accessoryBrowser: HMAccessoryBrowser?
    var accessory: HMAccessory?
    
    
    // MARK: - View
    override func viewDidLoad()
    {
        super.viewDidLoad()

        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        
        homeManager.delegate = self

        livingroom.titleLabel?.text = ""
        bedroom.titleLabel?.text = ""
        garage.titleLabel?.text = ""

        accessory = HMAccessory()
        accessory?.delegate = self
        
        lbl_browsing.text = "viewDidLoad"

        txt_msg.text = ""
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
    }

    @IBAction func refresh(sender: UIBarButtonItem)
    {
        updateHomes()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        accessoryBrowser =  HMAccessoryBrowser()
        accessoryBrowser?.delegate =  self
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        accessoryBrowser?.stopSearchingForNewAccessories()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
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
    

    // MARK: - Observer
    func updateHomes()
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
        
        if !(homeStore.homeManager.primaryHome?.name == nil)
        {
//            for h in (homeStore.homeManager.homes)
//            {
//                homeStore.homeManager.removeHome(h, completionHandler: { _ in })
//            }
//            
//            self.title = "clear everything"
            if let _ = homeStore.homeManager.primaryHome
            {
                self.title = "PrimaryHome: \(homeStore.homeManager.primaryHome!.name)"
                
                for h in homeStore.homeManager.homes
                {
                    var t:String = "\t\(h.name)\n"
                    
                    print("\(h.name)")
                    var i:Int = 0
                    for r in h.rooms
                    {
                        print("\t\(r.name)")
                        t += "\t\t\(r.name)\n"

                        switch i {
                        case 0:
                            livingroom.titleLabel?.text = r.name
                        case 1:
                            bedroom.titleLabel?.text = r.name
                        case 2:
                            garage.titleLabel?.text = r.name
                        default: break
                        }
                        
                        i++
                        
                        for a in r.accessories
                        {
                            print("\t\t\(a.name)")
                            t += "\t\t\t\(a.name)\n"
                            
                            for s in a.services
                            {
                                print("\t\t\tservices.name=\(s.name)")
                                print("\t\t\tservices.localizedDescription=\(s.localizedDescription)")
                                print("\t\t\tservices.accessory.reachable=\(s.accessory?.reachable)")
                                
                                t += "\t" + s.name + "\n"
                                    + "\t\t\t\tservices.localizedDescription=\(s.localizedDescription)\n"
                                    + "\t\t\t\tservices.accessory.reachable=\(s.accessory?.reachable)\n"
                                
                                var j:Int = 0
                                for c in s.characteristics
                                {
                                    print("\t\t\t\tcharacteristics=\(c.localizedDescription):\(c.value)")
                                    t += "\t\t\t\t\tcharacteristics=\(c.localizedDescription):\(c.value)\n"
                                    j++
                                }
                                print("\t\t--------------------------------------------------------------")
                                t += "\t\t\t--------------------------------------------------------------"
                            }
                            
                        }
                    }
                    txt_msg.text = txt_msg.text + t
                }
                
                accessoryBrowser?.startSearchingForNewAccessories()
                lbl_browsing.text = "startSearchingForNewAccessories()"
                info.startAnimating()
            }
        }
        else
        {
            let myHome = "ITRI"
            homeStore.homeManager.addHomeWithName(myHome, completionHandler: { newHome, error in
                if let _ = error {
                    print("\taddHomeWithName: \(error!)")
                } else {
                    self.updatePrimaryHome()
                }
            })
            
            bedroom.titleLabel?.text = "_"
            livingroom.titleLabel?.text = "_"
            garage.titleLabel?.text = "_"
        }

        for h in homeManager.homes
        {
            h.delegate = self;
            print("\t\thomeManager.primaryHome?.name=\(h)")
        }

    }
    
    func updatePrimaryHome()
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        
        if let h = homeStore.homeManager.primaryHome
        {
            self.title = "PrimaryHome: \(homeStore.homeManager.primaryHome!.name)"
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
            
            self.title = "PrimaryHome: \(homeStore.homeManager.primaryHome!.name)"
        }
    }
    
    
    // MARK: - HMHomeManagerDelegate Methods
    
    /**
    Reloads data and view.
    
    This view controller, in most cases, will remain the home manager delegate.
    For this reason, this method will close all modal views and pop all detail views
    if the home store's current home is no longer in the home manager's list of homes.
    */
    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")

        updateHomes()
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
    }

    
    // MARK: - HMHomeDelegate
    func homeDidUpdateName(home: HMHome)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
    }
    
    func home(home: HMHome, didAddAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
        txt_msg.scrollRangeToVisible(txt_msg.selectedRange)
    }
    
    func home(home: HMHome, didRemoveAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
    }
    
    // MARK: - deinit
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - 
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        print("\t\(accessory.name)")
        lbl_browsing.text = "didFindNewAccessory()"
        //info.stopAnimating()

        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__).name=\(accessory.name)\n"
        txt_msg.text = str
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)\n"
        txt_msg.text = str
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func accessory(accessory: HMAccessory, didUpdateAssociatedServiceTypeForService service: HMService)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    func accessoryDidUpdateServices(accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    func accessoryDidUpdateReachability(accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
}
