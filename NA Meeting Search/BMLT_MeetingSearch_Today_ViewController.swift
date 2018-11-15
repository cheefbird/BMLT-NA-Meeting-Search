//
//  BMLT_MeetingSearch_Today_ViewController.swift
//  NA Meeting Search
//
//  Created by MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BMLT is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

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
