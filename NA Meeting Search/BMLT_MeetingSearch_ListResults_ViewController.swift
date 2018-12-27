//
//  BMLT_MeetingSearch_ListResults_ViewController.swift
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

/* ###################################################################################################################################### */
/**
 This is the "List Results" root view controller.
 */
@IBDesignable class BMLT_MeetingSearch_ListResults_ViewController: BMLT_MeetingSearch_Results_Base_ViewController, UITableViewDataSource, UITableViewDelegate {
    private let _segueID = "meeting-detail-from-list-segue-id"
    
    /* ################################################################## */
    /**
     This is the top color of the background gradient if this was not the main list.
     */
    @IBInspectable var alternateGradientTopColor: UIColor = UIColor.black
    
    /* ################################################################## */
    /**
     This is the bottom color of the background gradient if this was not the main list.
     */
    @IBInspectable var alternateGradientBottomColor: UIColor = UIColor.darkGray
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var sortSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var tableConstraint: NSLayoutConstraint!
    
    /* ################################################################## */
    /**
     This is true if this was not the main list.
     */
    var pushedByMap: Bool = false
    
    /* ################################################################## */
    /**
     This is true if this was a "Today" search (affects the sorting).
     */
    var todaySearch: Bool = false
    
    // MARK: Private Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This sorts the results, according to the selector switch.
     
     - parameter inByDistance: This is true, if the switch is set to "Sort by Distance".
     */
    private func _sortResults(_ inByDistance: Bool) {
        // This is a bit of a "kludge." In the case of "Today," if we are in Saturday, we expect Saturday (or whetever weekday comes first) to appear before Sunday.
        let isTodaySearch = (0 == BMLT_MeetingSearch_AppDelegate.delegateObject.mainTabController.selectedIndex)
        self.prefs.sortResultsByDistance = inByDistance
        self.searchResults = self.searchResults.sorted(by: {
            if inByDistance {
                return $0.distanceInKm < $1.distanceInKm
            } else {
                let firstWeekday = Calendar.current.firstWeekday
                var weekday1 = $0.weekdayIndex - firstWeekday
                var weekday2 = $1.weekdayIndex - firstWeekday
                
                if 0 > weekday1 {
                    weekday1 += 7
                }
                
                if 0 > weekday2 {
                    weekday2 += 7
                }
                
                if isTodaySearch && (0 == weekday1) && (6 == weekday2) {
                    return false
                } else {
                    if isTodaySearch && (6 == weekday1) && (0 == weekday2) {
                        return true
                    } else {
                        if weekday1 != weekday2 {
                            return weekday1 < weekday2
                        } else {
                            let startTime1 = $0.startTime
                            let startTime2 = $1.startTime
                            
                            let startTimeAsInteger1 = ((startTime1?.hour)! * 100) + (startTime1?.minute)!
                            let startTimeAsInteger2 = ((startTime2?.hour)! * 100) + (startTime2?.minute)!
                            
                            return startTimeAsInteger1 < startTimeAsInteger2
                        }
                    }
                }
            }
        })
        
        self.searchResultsTableView.reloadData()
    }

    // MARK: IB Handler Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when the sort segmented switch changes value.
     
     - parameter sender: The IB Object that called this (the segmented switch).
     */
    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        self._sortResults((1 == selectedIndex))
    }
    
    /* ################################################################## */
    /**
     Reacts to the NavBar "Action" button being hit.
     
     - parameter sender: The IB Object that called this (the action button -ignored).
     */
    @IBAction override func actionButtonHit(_ sender: Any) {
        let sharedPrintController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "print Job"
        sharedPrintController.printPageRenderer = BMLT_MeetingSearch_ListResults_PageRenderer(meetings: self.searchResults)
        sharedPrintController.present(from: self.view.frame, in: self.view, animated: false, completionHandler: nil)
    }

    // MARK: - Base Class Override IB Handler Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Reacts to the NavBar "Done" button being hit.
     */
    @IBAction override func doneButtonHit(_ sender: Any) {
        // If we were called from the map page, then we're a simple modal screen or popover, and all we need to do is dismiss.
        if self.pushedByMap {
            self.dismiss(animated: true, completion: nil)
        } else {    // Otherwise, just fall through.
            super.doneButtonHit(sender)
        }
    }

    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view is loaded.
     */
    override func viewDidLoad() {
        // We do this if we were called from the map, which means we aren't the main list. We use a different color to indicate this.
        if self.pushedByMap {
            self.gradientTopColor = self.alternateGradientTopColor
            self.gradientBottomColor = self.alternateGradientBottomColor
        }
        
        super.viewDidLoad()

        self.myTabBarIndex = 0
        if nil == self.searchLocation {
            self.sortSegmentedSwitch.isHidden = true
            self.tableConstraint.constant = 0
        } else {
            if let segment0Title = self.sortSegmentedSwitch.titleForSegment(at: 0) {
                self.sortSegmentedSwitch.setTitle(segment0Title.localizedVariant, forSegmentAt: 0)
            }
            
            if let segment1Title = self.sortSegmentedSwitch.titleForSegment(at: 1) {
                self.sortSegmentedSwitch.setTitle(segment1Title.localizedVariant, forSegmentAt: 1)
            }
            self.sortSegmentedSwitch.selectedSegmentIndex = self.prefs.sortResultsByDistance ? 1 : 0
            self._sortResults(self.prefs.sortResultsByDistance)
        }
        
        // We do this in order to prevent the background tap recognizer from interfering with the list.
        self.tappedInBackgroundGestureRecognizer.cancelsTouchesInView = false
    }
    
    /* ################################################################## */
    /**
     Called when we are about to dosee-doh out the door.
     
     - parameter segue: The segue being called.
     - parameter sender: The data we're attaching to the segue (our meeting results).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == self._segueID {
            if let destination = segue.destination as? BMLT_MeetingSearch_Details_ViewController {
                if let meetingData = sender as? BMLTiOSLibMeetingNode {
                    destination.searchLocation = self.searchLocation
                    destination.meetingData = meetingData
                }
            }
        }
    }

    // MARK: - UITableViewDataSource Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     How many rows?.
     
     - parameter tableView: The UITableView Object
     - parameter section: The section being checked (ignored).
     
     - returns: The number of search results to display.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    /* ################################################################## */
    /**
     Returns a cell object that represents a single meeting.
     
     - parameter tableView: The UITableView that called this
     - parameter cellForRowAt: The section row, as an IndexPath (0-based, and we only have 1 section -0).
     
     - returns: A new UITableViewCell object for the given meeting.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meeting = self.searchResults[indexPath.row]
        let reuseID: String = String(meeting.id)
        
        let ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseID)
        
        if let cell = UINib(nibName: "BMLT_MeetingSearch_Results_TableCellView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? BMLT_MeetingSearch_Results_TableCellView {
            cell.meetingDescriptionTextView.text = meeting.description
            
            if nil != self.searchLocation {
                var distance: Double = 0
                let distanceFormat = "BMLTNAMeetingSearch-DistanceFormat".localizedVariant
                let units = self.prefs.distanceUnits
                
                if "BMLTNAMeetingSearch-DistanceUnitsMiles" == units {
                    distance = meeting.distanceInMiles
                } else {
                    if "BMLTNAMeetingSearch-DistanceUnitsKm" == units {
                        distance = meeting.distanceInKm
                    }
                }
                
                cell.distanceLabel.text = String(format: distanceFormat, distance) + units.localizedVariant
            } else {
                cell.distanceLabel.text = ""
            }
            
            var bounds: CGRect = CGRect.zero
            bounds.size.height = tableView.rowHeight
            bounds.size.width = tableView.bounds.size.width
            if 0 == (indexPath.row % 2) {
                let backgroundColor = self.view.tintColor.withAlphaComponent(0.6)
                cell.distanceLabel.textColor = self.gradientTopColor
                cell.meetingDescriptionTextView.textColor = self.gradientTopColor
                ret.backgroundColor = backgroundColor
            } else {
                cell.distanceLabel.textColor = self.view.tintColor
                cell.meetingDescriptionTextView.textColor = self.view.tintColor
                ret.backgroundColor = UIColor.clear
            }
            ret.bounds = bounds
            cell.frame = bounds
            ret.addSubview(cell)
        }
        
        return ret
    }

    // MARK: UITableViewDelegate Protocol Methods
    /* ##################################################################################################################################*/
    /**
     This reacts to a table row being selected. What we do, is refuse to select it, but honor the attempt.
     It will bring in a detail screen for the selected meeting.
     
     - parameter tableView: The UITableView that called this
     - parameter indexPath: The section row, as an IndexPath (0-based, and we only have 1 section -0).
     
     - returns: nil (all the time)
     */
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let meetingInfo = self.searchResults[indexPath.row]
        self.performSegue(withIdentifier: self._segueID, sender: meetingInfo)
        
        return nil
    }
}

/* ###################################################################################################################################### */
/**
 */
class BMLT_MeetingSearch_Results_TableCellView: UIView {
    @IBOutlet weak var meetingDescriptionTextView: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
}
