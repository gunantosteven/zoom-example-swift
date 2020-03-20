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

    @IBOutlet weak var MeetingNumber: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if let authService = self.authService {
                if authService.isLoggedIn() {
                    self.messageLabel.text = "You login in as " + (authService.getAccountInfo()?.getUserName() ?? "")
                } else {
                    self.messageLabel.text = "non-login user" + (authService.getAccountInfo()?.getUserName() ?? "")
                }
            }
            self.view.hideToastActivity()
        }
    }

    @IBAction func onJoinMeetingBtnTouched(_ sender: Any) {
        let meetingNo = self.MeetingNumber.text
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

extension ViewController : MobileRTCMeetingServiceDelegate {
    
}

extension ViewController : MobileRTCAuthDelegate {
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        print(returnValue)
    }
    
    func onMobileRTCLogoutReturn(_ returnValue: Int) {
        print(returnValue)
    }
}

