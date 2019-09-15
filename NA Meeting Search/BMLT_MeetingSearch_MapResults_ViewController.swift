//
//  BMLT_MeetingSearch_MapResults_ViewController.swift
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
import MapKit

/* ###################################################################################################################################### */
/**
 This is the "Map Results" root view controller.
 */
class BMLT_MeetingSearch_MapResults_ViewController: BMLT_MeetingSearch_Results_Base_ViewController, MKMapViewDelegate {
    /// The segue ID for brininging in a list view for an aggregate marker (red).
    private let _showMeetingListSegueID = "show-breakout-list-segue-id"
    /// The segue ID for bringing in a details page for a single meeting (blue marker).
    private let _showMeetingDetailsSegueID = "show-breakout-details-segue-id"
    /// An ID for the popover view controller for aggregate lists.
    private let _presentListPopoverID = "present-list-controller-id"
    
    /* ################################################################## */
    /**
     This is our map view. It fills the entire screen.
     */
    @IBOutlet weak var mapView: MKMapView!
    
    /* ################################################################## */
    /**
     This is the segmented control that lets us select the map type.
     */
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!

    // MARK: - IB Methods
    /* ##################################################################################################################################*/
    
    /* ################################################################## */
    /**
     Reacts to the map type control being changed.
     
     - parameter sender: The segmented control that triggered this.
     */
    @IBAction func mapTypeControlChanged(_ sender: UISegmentedControl) {
        let mapTypeIndex = sender.selectedSegmentIndex
        self.prefs.mapTypeIndex = mapTypeIndex
        self.mapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
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
        sharedPrintController.printPageRenderer = BMLT_MeetingSearch_MapResults_PageRenderer(meetings: self.searchResults, mapFormatter: self.mapView.viewPrintFormatter())
        sharedPrintController.present(from: self.view.frame, in: self.view, animated: false, completionHandler: nil)
    }

    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called when the view is loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // No swipes, because map.
        self.swipeLeftGestureRecognizer = nil
        self.swipeRightGestureRecognizer = nil
        self.myTabBarIndex = 1

        // Set up localized names for the map type control.
        for i in 0..<self.mapTypeSegmentedControl.numberOfSegments {
            if let segmentTitle = self.mapTypeSegmentedControl.titleForSegment(at: i) {
                self.mapTypeSegmentedControl.setTitle(segmentTitle.localizedVariant, forSegmentAt: i)
            }
        }
        
        let mapTypeIndex = self.prefs.mapTypeIndex
        self.mapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
        self.mapTypeSegmentedControl.selectedSegmentIndex = mapTypeIndex

        // We do this in order to prevent the background tap recognizer from interfering with the map.
        self.tappedInBackgroundGestureRecognizer.cancelsTouchesInView = false
        
        if #available(iOS 13.0, *) {
            if let tintColor = self.view.tintColor {
                self.mapTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: tintColor], for: .normal)
                self.mapTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setMapRegion()
    }
    
    /* ################################################################## */
    /**
     Called when we want to open a list for a multi-meeting marker.
     
     - parameter segue: The segue being called.
     - parameter sender: The data we're attaching to the segue (a list of meeting nodes).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == self._showMeetingListSegueID {
            if let destination = segue.destination as? BMLT_MeetingSearch_ListResults_ViewController {
                destination.searchLocation = self.searchLocation
                destination.pushedByMap = true
                if let searchResults = sender as? [BMLTiOSLibMeetingNode] {
                    destination.searchResults = searchResults
                }
            }
        } else {
            if segue.identifier == self._showMeetingDetailsSegueID {
                if let destination = segue.destination as? BMLT_MeetingSearch_Details_ViewController {
                    if let meetingData = sender as? BMLTiOSLibMeetingNode {
                        destination.searchLocation = self.searchLocation
                        destination.meetingData = meetingData
                    }
                }
            }
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Called to open a list for a bunch of meetings attached to a red marker.
     */
    func openList(_ inMeetingList: [BMLTiOSLibMeetingNode], inPopoverRect: CGRect! = nil) {
        if !inMeetingList.isEmpty {
            if nil != inPopoverRect {
                if let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: self._presentListPopoverID) as? BMLT_MeetingSearch_ListResults_ViewController {
                    popoverContent.preferredContentSize = CGSize(width: 320, height: 480)
                    popoverContent.searchLocation = self.searchLocation
                    popoverContent.pushedByMap = true
                    popoverContent.searchResults = inMeetingList
                    popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
                    if let popover = popoverContent.popoverPresentationController {
                        popover.sourceView = self.mapView
                        popover.sourceRect = inPopoverRect
                        popover.backgroundColor = popoverContent.alternateGradientTopColor
                        self.present(popoverContent, animated: true, completion: nil)
                    }
                }
            } else {
                self.performSegue(withIdentifier: self._showMeetingListSegueID, sender: inMeetingList)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called to open a detail screen for a blue marker.
     */
    func openDetails(_ inMeetingData: BMLTiOSLibMeetingNode) {
        self.performSegue(withIdentifier: self._showMeetingDetailsSegueID, sender: inMeetingData)
    }
    
    /* ################################################################## */
    /**
     Called when the view is loaded.
     */
    func setMapRegion() {
        var northEast = CLLocationCoordinate2DMake(-360, -360)
        var southWest = CLLocationCoordinate2DMake(360, 360)
        for meeting in self.searchResults {
            let meetingCoords = meeting.locationCoords
            
            northEast.latitude = max((meetingCoords?.latitude)!, northEast.latitude)
            northEast.longitude = max((meetingCoords?.longitude)!, northEast.longitude)
            
            southWest.latitude = min((meetingCoords?.latitude)!, southWest.latitude)
            southWest.longitude = min((meetingCoords?.longitude)!, southWest.longitude)
        }
        
        if nil != self.searchLocation {
            northEast.latitude = max(self.searchLocation.latitude, northEast.latitude)
            northEast.longitude = max(self.searchLocation.longitude, northEast.longitude)
            
            southWest.latitude = min(self.searchLocation.latitude, southWest.latitude)
            southWest.longitude = min(self.searchLocation.longitude, southWest.longitude)
        }
        
        if (-360 < northEast.latitude) && (-360 < northEast.longitude) && (360 > southWest.latitude) && (360 > southWest.longitude) {
            let center = CLLocationCoordinate2D(latitude: (northEast.latitude + southWest.latitude) / 2.0, longitude: (northEast.longitude + southWest.longitude) / 2.0)
            let span = MKCoordinateSpan(latitudeDelta: fabs(northEast.latitude - southWest.latitude) * 2.5, longitudeDelta: abs(northEast.longitude - southWest.longitude) * 2.25)
            
            let spanRegion = MKCoordinateRegion.init(center: center, span: span)
            
            self.mapView.setRegion(spanRegion, animated: true)
        }
    }

    // MARK: MKMapViewDelegate Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This delivers a marker view to the map.
     We add a button to the callout so we can bring in directions and show the address.
     
     - parameter mapView: The map view object
     - parameter viewFor: The annotation object we'll be creating the view for
     
     - returns: A marker view.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: BMLT_MeetingSearch_Annotation.self) {
            let reuseID = ""
            if let myAnnotation = annotation as? BMLT_MeetingSearch_Annotation {
                let markerView = BMLT_MeetingSearch_MapMarkerAnnotationView(annotation: myAnnotation, draggable: false, reuseID: reuseID)
                markerView.canShowCallout = (0 == (annotation as? BMLT_MeetingSearch_Annotation)?.meetings.count)
                
                return markerView
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This delivers a marker view to the map.
     We add a button to the callout so we can bring in directions and show the address.
     
     - parameter mapView: The map view object
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = BMLT_MeetingSearch_MapMarkerAnnotationView.generateAnnotations(forMapView: mapView, meetings: self.searchResults)
        
        mapView.addAnnotations(annotations)
    }
    
    /* ################################################################## */
    /**
     This is called when the user selects an annotation..
     
     - parameter mapView: The map view object
     - parameter view: The selected annotation.
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationView = view as? BMLT_MeetingSearch_MapMarkerAnnotationView {
            // The reason that we do this, is to leave the map the way we found it.
            self.mapView.deselectAnnotation(view.annotation, animated: false)
            if 0 < annotationView.meetings.count {  // One meeting (blue) goes straight to details.
                if 1 == annotationView.meetings.count {
                    self.openDetails(annotationView.meetings[0])
                } else { // Multiple (red) markers either open up a popover or bring in a "short" list.
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                        var frameRect = view.frame
                        // This centers the rect in the middle of the marker blob.
                        frameRect.origin.x += (frameRect.size.width * 0.35)
                        frameRect.origin.y += (frameRect.size.height * 0.35)
                        frameRect.size = CGSize.zero
                        self.openList(annotationView.meetings, inPopoverRect: frameRect)
                   } else {
                        self.openList(annotationView.meetings)
                    }
                }
            }
        }
    }
}
