//
//  BMLT_MeetingSearch_Info_ViewController.swift
//  NA Meeting Search
//
//  Created by BMLT-Enabled
//
//  https://bmlt.app/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 BMLT-Enabled
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

/* ###################################################################################################################################### */
/**
 This classs handles the "More Info" modal screen that is pulled in over the "Settings and Info" screen.
 */
class BMLT_MeetingSearch_Info_ViewController: BMLT_MeetingSearch_Subsequent_ViewController {
    // MARK: IB Properties
    /* ##################################################################################################################################*/
    /// This is the label for the screen header.
    @IBOutlet weak var headerLabel: UILabel!
    /// This is the button that displays the documentation page URI
    @IBOutlet weak var uriButton: UIButton!
    /// This is the scrollable text field, containing the bulk of the text.
    @IBOutlet weak var explanationText: UITextView!
    /// This is the button at the bottom of the screen, with "DONE."
    @IBOutlet weak var doneButton: UIButton!

    // MARK: IB Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the big button or the visit site button is hit.
     
     - parameter: ignored
     */
    @IBAction func beanieButtonHit(_ : Any) {
        let openLink = NSURL(string: "INFO-HELP-URI".localizedVariant)
        UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
    }
    
    /* ################################################################## */
    /**
     This is called to dismiss the screen.
     
     - parameter: ignored
     */
    @IBAction func doneButtonHit(_ : Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called after the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.setTitle(self.doneButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.uriButton.setTitle(self.uriButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.explanationText.text = self.explanationText.text.localizedVariant
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let format = self.headerLabel.text?.localizedVariant {
                    var appName = "ERROR"
                    var appVersion = "ERROR"
                    
                    if let appNameTemp = plistDictionary["CFBundleName"] as? NSString {
                        appName = appNameTemp as String
                    }
                    
                    if let versionTemp = plistDictionary["CFBundleShortVersionString"] as? NSString {
                        appVersion = versionTemp as String
                    }
                    
                    self.headerLabel.text = String(format: format, appName, appVersion)
                }
            }
        }
    }
}
