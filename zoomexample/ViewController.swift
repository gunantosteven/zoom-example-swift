//
//  ViewController.swift
//  zoomexample
//
//  Created by GBU on 17/03/20.
//  Copyright © 2020 Spinergy. All rights reserved.
//

import UIKit
import MobileRTC

class ViewController: UIViewController {

    @IBOutlet weak var meetingNumberTextField: UITextField! {
        didSet {
            meetingNumberTextField.delegate = self
        }
    }
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextfield: UITextField! {
        didSet {
            passwordTextfield.delegate = self
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var createScheduleMeetingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var meetingItems : [MeetingItem]?
    
    var authService : MobileRTCAuthService? {
        if let authService = MobileRTC.shared().getAuthService() {
            authService.delegate = self
            authService.clientKey = Constant.kSDKAppKey
            authService.clientSecret = Constant.kSDKAppSecret
            authService.jwtToken = ""
            authService.sdkAuth()
            return authService
        } else {
            return nil
        }
    }
    var meetingService : MobileRTCMeetingService? {
        if let meetingService = MobileRTC.shared().getMeetingService() {
            meetingService.delegate = self
            return meetingService
        } else {
            return nil
        }
    }
    var preMeetingService : MobileRTCPremeetingService? {
        if let preMeetingService = MobileRTC.shared().getPreMeetingService() {
            preMeetingService.delegate = self
            return preMeetingService
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUser()
    }
    
    func loadUser() {
        self.view.makeToastActivity(.center)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else {
              return
            }
            if let authService = self.authService {
                if authService.isLoggedIn() {
                    self.messageLabel.text = "You login in as " + (authService.getAccountInfo()?.getUserName() ?? "")
                    self.createScheduleMeetingButton.isEnabled = true
                    self.loadListMeeting()
                } else {
                    self.messageLabel.text = "non-login user" + (authService.getAccountInfo()?.getUserName() ?? "")
                    self.createScheduleMeetingButton.isEnabled = false
                    self.meetingItems?.removeAll()
                    self.tableView.reloadData()
                }
            }
            self.view.hideToastActivity()
        }
    }
    
    func loadListMeeting() {
        if let preMeetingService = self.preMeetingService {
            preMeetingService.listMeeting()
        }
    }

    @IBAction func onJoinMeetingBtnTouched(_ sender: Any) {
        let meetingNo = self.meetingNumberTextField.text
        print("meetingNo " + (meetingNo ?? ""))
        
        view.endEditing(true)

        self.joinMeeting(meetingNo ?? "")
    }
    
    func joinMeeting(_ meetingNo : String) {
        if meetingNo == "" {
            if let authService = authService { // try meeting with login
                if authService.isLoggedIn() {
                    if let meetingService = meetingService {
                        meetingService.customizeMeetingTitle("Simple meeting")
                        var param = MobileRTCMeetingStartParam()
                        let user = MobileRTCMeetingStartParam4LoginlUser()
                        param = user
                        param.meetingNumber = ""
                        param.isAppShare = false
                        
                        let ret = meetingService.startMeeting(with: param)
                        
                        print("onMeetNow ret \(ret)")
                    }
                } else {
                    messageLabel.text = "Please enter a meeting number"
                }
            }
        } else {
            if let meetingService = meetingService { // try meeting witn non-login
                let kSDKUserName = "Superman"
                var paramDict = [AnyHashable : Any]()
                paramDict["kMeetingParam_Username"] = kSDKUserName
                paramDict["kMeetingParam_MeetingNumber"] = meetingNo
                
                let response = meetingService.joinMeeting(with: paramDict)
                
                print("onJoinMeeting, response \(response.rawValue.description)")
            }
        }
    }
    
    @IBAction func createScheduleMeetingTouched(_ sender: Any) {
        let alert = UIAlertController(title: "Meeting Topic", message: "Set your meeting topic", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            if let text = alert.textFields?[0].text {
                self.createScheduleMeeting(text)
            }
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter meeting title:"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func createScheduleMeeting(_ title : String) {
        if let preMeetingService = preMeetingService {
            if let item = preMeetingService.createMeetingItem() {
                item.setMeetingTopic(title)
                item.setStartTime(Date())
                item.setTimeZoneID(NSTimeZone.default.abbreviation()!)
                item.setDurationInMinutes(60)
                
                preMeetingService.scheduleMeeting(item, withScheduleFor: usernameTextField.text)
                preMeetingService.destroy(item)
            }
            preMeetingService.listMeeting()
        }
    }
    
    @IBAction func loginBtnTouched(_ sender: Any) {
        loginWithEmail()
    }
    
    func loginWithEmail() {
        if let authService = authService {
            authService.delegate = self
            authService.login(withEmail: usernameTextField.text ?? "", password: passwordTextfield.text ?? "", remeberMe: true)
            authService.sdkAuth()
            loadUser()
        }
        view.endEditing(true)
    }
    
    @IBAction func logoutBtnTouched(_ sender: Any) {
        logout()
    }
    
    func logout() {
        if let authService = authService {
            if authService.isLoggedIn() {
                authService.logoutRTC()
                loadUser()
            }
        }
    }
    
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let meetingItem = self.meetingItems?[indexPath.row] {
            meetingNumberTextField.text = meetingItem.meetingNumber
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let preMeetingService = preMeetingService, let meetingItem = self.meetingItems?[indexPath.row] {
                if let item = preMeetingService.getMeetingItem(byUniquedID: UInt64(meetingItem.meetingNumber) ?? 0) {
                    if preMeetingService.deleteMeeting(item) {
                        meetingItems?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingItemsCell", for: indexPath)
        if let meetingItem = self.meetingItems?[indexPath.row] {
            cell.textLabel?.text = meetingItem.topic
            cell.detailTextLabel?.text = meetingItem.meetingNumber
        }
        return cell
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension ViewController : MobileRTCMeetingServiceDelegate {

}

extension ViewController : MobileRTCAuthDelegate {
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        print(returnValue)
        self.view.makeToast("\(returnValue)")
    }
    
    func onMobileRTCLogoutReturn(_ returnValue: Int) {
        print(returnValue)
        self.view.makeToast("\(returnValue)")
    }
}

extension ViewController : MobileRTCPremeetingDelegate {
    func sinkSchedultMeeting(_ result: PreMeetingError, meetingUniquedID uniquedID: UInt64) {
        print("sinkSchedultMeeting result \(result)")
        self.view.makeToast("sinkSchedultMeeting result \(result)")
    }
    
    func sinkEditMeeting(_ result: PreMeetingError, meetingUniquedID uniquedID: UInt64) {
        print("sinkEditMeeting result \(result)")
        self.view.makeToast("sinkEditMeeting result \(result)")
    }
    
    func sinkDeleteMeeting(_ result: PreMeetingError) {
        print("sinkDeleteMeeting result \(result)")
        self.view.makeToast("sinkDeleteMeeting result \(result)")
    }
        
    func sinkListMeeting(_ result: PreMeetingError, withMeetingItems array: [Any]) {
        if let items = array as? [MobileRTCMeetingItem]  {
            for item in items {
                print("item meeting number \(item.getMeetingNumber())")
            }
            self.meetingItems = items.map( { return MeetingItem(topic: $0.getMeetingTopic() ?? "", meetingNumber: $0.getMeetingNumber().description) } )
            self.tableView.reloadData()
        }
        
        print("sinkListMeeting result \(result) \(array.count)")
        self.view.makeToast("sinkListMeeting result \(result) \(array.count)")
    }
}
