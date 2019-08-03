//
//  BMLT_MeetingSearch_Today_ViewController.swift
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
import BMLTiOSLib

/* ######################################################################################################################################*/
/**
 This is the main controller for the "Meetings Today" search.
 */
class BMLT_MeetingSearch_Today_ViewController: BMLT_MeetingSearch_RootViewController {
    // MARK: - Private Instance Fixed Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is our Segue ID.
     */
    private let _segueID: String = "perform-today-meeting-search-segue-id"

    // MARK: - IB Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is the big fat button that the user presses.
     */
    @IBOutlet weak var theBigSearchButton: BMLT_MeetingSearch_AnimatedButtonView!
    
    /* ################################################################## */
    /**
     This contains our activity view.
     */
    @IBOutlet weak var theActivityView: UIView!
    
    /* ################################################################## */
    /**
     This contains our prompt label.
     */
    @IBOutlet weak var thePromptView: UIView!
    
    /* ################################################################## */
    /**
     This is the label that talks about trying a connection.
     */
    @IBOutlet weak var connectionPromptLabel: UILabel!
    
    // MARK: - IB Handlers
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the user hits the big button.
     */
    @IBAction func searchButtonHit( _ inSender: UIButton ) {
        if nil != BMLT_MeetingSearch_Prefs.prefs.commObject {
            self.startSearch()
        } else {
            self.theBigSearchButton.showMeGray = false
            self.theBigSearchButton.startAnimation()
            self.theActivityView.isHidden = false
            self.thePromptView.isHidden = false
            BMLT_MeetingSearch_Prefs.prefs.commObject = BMLTiOSLib(inRootServerURI: BMLT_MeetingSearch_Prefs.prefs.rootURI, inDelegate: BMLT_MeetingSearch_AppDelegate.delegateObject)
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view is loaded. We set the localized string for the label here.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.theBigSearchButton.startAnimation()
        self.connectionPromptLabel.text = self.connectionPromptLabel.text?.localizedVariant
    }
    
    // MARK: - Internal Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This pushes in the search progress screen, which handles everything after that.
     */
    func startSearch() {
        self.performSegue(withIdentifier: self._segueID, sender: nil)
    }
    
    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called as the segue is about to happen.
     We use this opportunity to tell the progress screen what we want done (simple location lookup, followed by today and tomorrow).
     
     - parameter segue: The segue being exercised.
     - parameter sender: Any extra info we want attached (ignored).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == self._segueID {
            if let destination = segue.destination as? BMLT_MeetingSearch_Progress_ViewController {
                destination.lookUpLocationFirst = true
                destination.useSearchCriteria = false
            }
        }
    }
}
