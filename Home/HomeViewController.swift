//
//  HomeViewController.swift
//  Home
//
//  Created by Jack Lee on 12/22/15.
//  Copyright © 2015 itri. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController, HMHomeDelegate, HMHomeManagerDelegate, HMAccessoryBrowserDelegate {

    // MARK: Properties
    var homeStore: HomeStore {
        return HomeStore.sharedStore
    }
    
    var home: HMHome! {
        return homeStore.home
    }

    @IBOutlet weak var bedroom: UIButton!
    @IBOutlet weak var livingroom: UIButton!
    @IBOutlet weak var garage: UIButton!
    @IBOutlet weak var lbl_browsing: UILabel!
    @IBOutlet weak var info: UIActivityIndicatorView!
    
    var accessoryBrowser: HMAccessoryBrowser?
    
    
    // MARK: - View
    override func viewDidLoad()
    {
        super.viewDidLoad()

        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHomes", name: "UpdateHomesNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePrimaryHome", name: "UpdatePrimaryHomeNotification", object: nil)

        homeStore.home?.delegate = self
        accessoryBrowser =  HMAccessoryBrowser()

        livingroom.titleLabel?.text = ""
        bedroom.titleLabel?.text = ""
        garage.titleLabel?.text = ""
    }

//    override func viewWillAppear(animated: Bool)
//    {
//        super.viewWillAppear(animated)
//        
//
//    }
    
    override func viewWillDisappear(animated: Bool)
    {
        accessoryBrowser?.stopSearchingForNewAccessories()
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
                    print("\(h.name)")
                    var i:Int = 0
                    for r in h.rooms
                    {
                        print("\t\(r.name)")
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
                            
                            for s in a.services
                            {
                                print("\t\t\t\(s.name)")
                                
                                var j:Int = 0
                                for c in s.characteristics
                                {
                                    print("\t\t\t\tc.metadata=\(c.metadata)")
                                    j++
                                }
                            }
                        }
                    }
                }
                
                accessoryBrowser?.startSearchingForNewAccessories()
                lbl_browsing.text = "startSearchingForNewAccessories()"
                info.startAnimating()
            }
        }
        else
        {
            print("\(homeStore.homeManager)")
            homeStore.homeManager.addHomeWithName("ITRI", completionHandler: { newHome, error in
                if let _ = error {
                    print("error \(error)")
                }
            })
            
            bedroom.titleLabel?.text = "_"
            livingroom.titleLabel?.text = "_"
            garage.titleLabel?.text = "_"
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
    
    
    // MARK: - 
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        print("\t\(accessory.name)")
        lbl_browsing.text = "didFindNewAccessory()"
        info.stopAnimating()
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func displayedServiceTypeForRow(row: Int) -> String {
        let serviceTypes = HMService.validAssociatedServiceTypes
        if row < serviceTypes.count {
            return HMService.localizedDescriptionForServiceType(serviceTypes[row])
        }
        
        return NSLocalizedString("None", comment: "None")
    }

    func serviceTypeIsSelectedForRow(row: Int, service: HMService) -> Bool {
        let serviceTypes = HMService.validAssociatedServiceTypes
        if row >= serviceTypes.count {
            return service.associatedServiceType == nil
        }
        
        if let associatedServiceType = service.associatedServiceType {
            return serviceTypes[row] == associatedServiceType
        }
        
        return false
    }

}
