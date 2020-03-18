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
    
    var kSDKUserName = "Superman"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onJoinMeetingBtnTouched(_ sender: Any) {
        let meetingNo = self.MeetingNumber.text
        print("meetingNo " + (meetingNo ?? ""))

        self.MeetingNumber.endEditing(true)

        if meetingNo != "" {
            self.joinMeeting(meetingNo ?? "")
        }
    }
    
    func joinMeeting(_ meetingNo : String) {
        if meetingNo == "" {
            print("Please enter a meeting number")
            return
        } else {
            if let service = MobileRTC.shared().getMeetingService() {
                service.delegate = self
                var paramDict = [AnyHashable : Any]()
                paramDict["kMeetingParam_Username"] = kSDKUserName
                paramDict["kMeetingParam_MeetingNumber"] = meetingNo
                
                let response = service.joinMeeting(with: paramDict)
                
                print("onJoinMeeting, response \(response.rawValue.description)")
            }
        }
    }
}

extension ViewController : MobileRTCMeetingServiceDelegate {
    
}

