//
//  HomeViewController.swift
//  Home
//
//  Created by Jack Lee on 12/22/15.
//  Copyright © 2015 itri. All rights reserved.
//

import UIKit
import HomeKit
import Crashlytics

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
    
    let updateQueue = dispatch_queue_create("org.itri.HMCatalog.CharacteristicUpdateQueue", DISPATCH_QUEUE_SERIAL)
    var updateValueTimer: NSTimer!
    var myAccessories = [HMAccessory]()
    var newTimer:dispatch_source_t!

    @IBOutlet weak var bedroom: UIButton!
    @IBOutlet weak var livingroom: UIButton!
    @IBOutlet weak var garage: UIButton!
    @IBOutlet weak var lbl_browsing: UILabel!
    @IBOutlet weak var info: UIActivityIndicatorView!
    @IBOutlet weak var txt_msg: UITextView!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    
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

        txt_msg.layoutManager.allowsNonContiguousLayout = false
        txt_msg.text = ""
        
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
        txt_msg.text = str
        
        accessoryBrowser =  HMAccessoryBrowser()
        accessoryBrowser?.delegate =  self
    }
    
    func contentChanged(str: String)
    {
        txt_msg.text = txt_msg.text + str
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [unowned self] in
        dispatch_async(self.updateQueue) {
        
            // do some task
            dispatch_async(dispatch_get_main_queue(), {
                // update some UI
                let l = self.txt_msg.text.characters.count
                let range = NSMakeRange(1, l)
                self.txt_msg.scrollRangeToVisible(range)
            });
        };
    }
    
    @IBAction func refresh(sender: UIBarButtonItem)
    {
        contentChanged("\n")
        updateHomes()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        fg()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        bg()
        super.viewWillDisappear(animated)
    }
    
    func bg() {
        if updateValueTimer != nil {
            updateValueTimer.invalidate()
        }
        RemoveDispatchSource(newTimer)
        accessoryBrowser?.stopSearchingForNewAccessories()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
 
    func fg() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bg", name: UIApplicationWillResignActiveNotification, object: nil)
        if updateValueTimer != nil {
            updateValueTimer.fire()
        }
        if newTimer != nil {
            newTimer = CreateDispatchTimer(UInt64(2 * Double(NSEC_PER_SEC)), leeway: UInt64(0.05 * Double(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), block: {
                self.updateCharacteristics()
            })
        }
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
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
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
                homeStore.home = homeStore.homeManager.primaryHome
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
                        
                        if (r.accessories.count > 0) {
                            for (var i=0; i<r.accessories.count; i++) {
                                myAccessories.append(r.accessories[i])
                                print("\(i)=\(myAccessories[i])")
                            }
                            
                            //updateValueTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateCharacteristics", userInfo: nil, repeats: true)
                            newTimer = CreateDispatchTimer(UInt64(2 * Double(NSEC_PER_SEC)), leeway: UInt64(0.05 * Double(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), block: {
                                self.updateCharacteristics()
                            })
                        }
                        
                        for a in r.accessories
                        {
                            print("\t\t\(a.name)")
                            t += "\t\t\t\(a.name)\n"
                            a.delegate = self
                            
                            for s in a.services
                            {
                                print("\t\t\tservices.name=\(s.name)")
                                print("\t\t\tservices.localizedDescription=\(s.localizedDescription)")
                                print("\t\t\tservices.accessory.reachable=\(s.accessory?.reachable)")
                                
                                t += "\t\t\t\tservices.localizedDescription=\(s.localizedDescription)\n"
                                    + "\t\t\t\tservices.accessory.reachable=\(s.accessory?.reachable)\n"
                                
                                var j:Int = 0
                                for c in s.characteristics
                                {
                                    c.notificationEnabled
                                    c.readValueWithCompletionHandler { error in
                                        //dispatch_sync(self.updateQueue) {
                                        dispatch_async(self.updateQueue) {
                                            
                                            dispatch_async(dispatch_get_main_queue()) {
                                                t += "\t\t\t\t\tcharacteristics=\(c.localizedDescription):\(c.value)\n"
                                                //self.txt_msg.text = self.txt_msg.text + t + "\n"
                                                self.contentChanged(t + "\n")
                                                print("\t\t\t\tcharacteristics=\(c.localizedDescription):\(c.value)")

                                                if (c.localizedDescription.hasPrefix("目前")) {
                                                    if c.localizedDescription.hasPrefix("目前家") {
                                                        if let state = c.value {
                                                            if state.integerValue == 1 {
                                                                self.lbl1.text = "\(c.localizedDescription):Closed"
                                                            } else {
                                                                self.lbl1.text = "\(c.localizedDescription):Open"
                                                            }
                                                        }
                                                    } else if c.localizedDescription.hasPrefix("目前相") {
                                                        self.lbl2.text = "\(c.localizedDescription):\(c.value!)"
                                                    } else if c.localizedDescription.hasPrefix("目前溫") {
                                                        self.lbl3.text = "\(c.localizedDescription):\(c.value!)"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    j++
                                }
                                print("\t\t--------------------------------------------------------------")
                                t += "\t\t\t\t--------------------------------------------------------------\n"
                            }
                            
                        }
                    }
                    //txt_msg.text = txt_msg.text + t + "\n"
                    contentChanged(t + "\n")
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
                if let _ = error
                {
                    print("\taddHomeWithName: \(error!)")
                    //self.txt_msg.text = self.txt_msg.text + "\n\(error)" + "\n"
                    self.contentChanged("\n\(error)" + "\n")
                }
                else
                {
                    self.homeManager.updatePrimaryHome(self.homeStore.homeManager.homes[0]) { error in
                        if let error = error {
                            self.displayError(error)
                            return
                        }
                        
                        print("\(self.homeManager.primaryHome)")
                        self.updatePrimaryHome()
                    }
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
    
    func updateCharacteristics()
    {
        for a in myAccessories
        {
            let date = NSDate()
            let formatter = NSDateFormatter()
            formatter.timeStyle = .LongStyle
            print("\t\t\(a.name):\(formatter.stringFromDate(date))")
            contentChanged(formatter.stringFromDate(date) + "\n")
            
            for s in a.services
            {
//                print("\t\t\tservices.name=\(s.name)")
//                print("\t\t\tservices.localizedDescription=\(s.localizedDescription)")
//                print("\t\t\tservices.accessory.reachable=\(s.accessory?.reachable)")
                
                var j:Int = 0
                for c in s.characteristics
                {
                    c.notificationEnabled
                    c.readValueWithCompletionHandler { error in
                        //dispatch_sync(self.updateQueue) {
                        dispatch_async(self.updateQueue) {
                            
                            //self.contentChanged("\(s.name):\(s.localizedDescription)\n")
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if (c.localizedDescription.hasPrefix("目前")) {
                                    
                                    if c.localizedDescription.hasPrefix("目前家") {
                                        if let state = c.value {
                                            if state.integerValue == 1 {
                                                self.lbl1.text = "\(c.localizedDescription):Closed"
                                            } else {
                                                self.lbl1.text = "\(c.localizedDescription):Open"
                                            }
                                        }
                                    } else if c.localizedDescription.hasPrefix("目前相") {
                                        self.lbl2.text = "\(c.localizedDescription):\(c.value!)"
                                    } else if c.localizedDescription.hasPrefix("目前溫") {
                                        self.lbl3.text = "\(c.localizedDescription):\(c.value!)"
                                    }
                                }
                            }
                        }
                    }
                    
                    j++
                }
                //print("\t\t--------------------------------------------------------------")
            }
            
        }
    }
    
    func CreateDispatchTimer(interval: UInt64, leeway: UInt64, queue: dispatch_queue_t, block: dispatch_block_t) -> dispatch_source_t
    {
        let timer: dispatch_source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)

        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), interval, leeway)
        dispatch_source_set_event_handler(timer, block)
        dispatch_resume(timer)
        
        return timer
    }
    
    func RemoveDispatchSource(source: dispatch_source_t)
    {
        print("\t\tcancel dispatch !!")
        dispatch_source_cancel(source)
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
            txt_msg.text = txt_msg.text + "\n" + self.title! + "\n"
            self.updateHomes()
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
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
        txt_msg.text = str
    }

    
    // MARK: - HMHomeDelegate
    func homeDidUpdateName(home: HMHome)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
        //txt_msg.text = str
        contentChanged(str)
    }
    
    func home(home: HMHome, didAddAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
        //txt_msg.text = str
        contentChanged(str)
    }
    
    func home(home: HMHome, didRemoveAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
        //txt_msg.text = str
        contentChanged(str)
    }
    
    // MARK: - deinit
    deinit {
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if updateValueTimer != nil {
            updateValueTimer.invalidate()
            updateValueTimer = nil
        }
    }
    
    
    // MARK: - 
    func accessoryBrowser(browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)")
        print("\t\(accessory.name)")
        lbl_browsing.text = "didFindNewAccessory()"
        //info.stopAnimating()

        let str:String = txt_msg.text + "\(__FUNCTION__).name=\(accessory.name)\n"
        //txt_msg.text = str
        contentChanged(str)
    }
    
    func accessoryBrowser(browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory)
    {
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        let str:String = txt_msg.text + "\(__FUNCTION__)\n"
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
        print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__):\(accessory.name)")
    }
    
    func accessory(accessory: HMAccessory, service: HMService, didUpdateValueForCharacteristic characteristic: HMCharacteristic)
    {
        if characteristic.value == nil {
            return;
        }
        if (characteristic.localizedDescription.hasPrefix("目前")) {
            if characteristic.localizedDescription.hasPrefix("目前家") {
                if let state = characteristic.value {
                    if state.integerValue == 1 {
                        self.lbl1.text = "\(characteristic.localizedDescription):Closed"
                    } else {
                        self.lbl1.text = "\(characteristic.localizedDescription):Open"
                    }
                }
            } else if characteristic.localizedDescription.hasPrefix("目前相") {
                self.lbl2.text = "\(characteristic.localizedDescription):\(characteristic.value!)"
            } else if characteristic.localizedDescription.hasPrefix("目前溫") {
                self.lbl3.text = "\(characteristic.localizedDescription):\(characteristic.value!)"
            }
            //contentChanged(characteristic.localizedDescription + "\n")
        }
        
        //print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)")
        characteristic.readValueWithCompletionHandler { error in
            //dispatch_sync(self.updateQueue) {
            dispatch_async(self.updateQueue) {
                dispatch_async(dispatch_get_main_queue()) {
                    print("\(NSStringFromClass(self.dynamicType))-\(__FUNCTION__)=\(characteristic.localizedDescription):\(characteristic.value)")
                }
            }
        }

    }
}
