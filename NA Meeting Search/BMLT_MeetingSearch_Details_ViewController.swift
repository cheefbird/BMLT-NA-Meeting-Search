//
//  BMLT_MeetingSearch_Details_ViewController.swift
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
import MapKit
import BMLTiOSLib

/* ###################################################################################################################################### */
/**
 This controls the display of the single meetings details page.
 */
class BMLT_MeetingSearch_Details_ViewController: BMLT_MeetingSearch_Subsequent_ViewController, MKMapViewDelegate {
    // MARK: IB Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is the navigation bar object.
     */
    @IBOutlet weak var myNavigationBar: UINavigationBar!
    
    /* ################################################################## */
    /**
     This is the meeting name label across the top.
     */
    @IBOutlet weak var meetingNameLabel: UILabel!
    
    /* ################################################################## */
    /**
     This is the weekday and time, just below that.
     */
    @IBOutlet weak var meetingTimeLabel: UILabel!
    
    /* ################################################################## */
    /**
     This text view has the adress information.
     */
    @IBOutlet weak var addressTextView: UITextView!
    
    /* ################################################################## */
    /**
     If we have comments, they are displayed here.
     */
    @IBOutlet weak var commentsTextField: UITextView!
    
    /* ################################################################## */
    /**
     This allows us to expand the map if the comments aren't shown.
     */
    @IBOutlet weak var mapTopConstraint: NSLayoutConstraint!
    
    /* ################################################################## */
    /**
     This is the map that occupies most of the screen.
     */
    @IBOutlet weak var locationMapView: MKMapView!
    
    /* ################################################################## */
    /**
     This is the segmented control that lets us select the map type.
     */
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    /* ################################################################## */
    /**
     This is the NavBar button for directions.
     */
    @IBOutlet weak var directionsButton: UIBarButtonItem!
    
    /* ################################################################## */
    /**
     This is the button to show the route in the map.
     */
    @IBOutlet weak var routeButton: UIBarButtonItem!
    
    /* ################################################################## */
    /**
     This is displayed while the directions are being looked up.
     */
    @IBOutlet weak var busyView: UIView!

    // MARK: Instance Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     If the search was location-based, then we have the location here.
     */
    var searchLocation: CLLocationCoordinate2D! = nil
    
    /* ################################################################## */
    /**
     This is the data for the meeting we're looking at.
     */
    var meetingData: BMLTiOSLibMeetingNode! = nil
    
    /* ################################################################## */
    /**
     This is our map annotation.
     */
    var mapAnnotation: BMLT_MeetingSearch_Annotation! = nil
    
    // MARK: Instance Calculated Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This read-only property returns a URL that can be used to open a map in another app for directions.
     */
    var mapDirectionsURI: String {
        let dstLL = String(format: "sll=%f,%f", self.meetingData.locationCoords.latitude, self.meetingData.locationCoords.longitude)
        let addressString = "daddr=" + self.meetingData.basicAddress.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let baselineURI = "?" + dstLL + "&" + addressString
        
        // See if we have the Google Maps App installed. If so, does the user want to use it?
        if self.prefs.canUseGoogleMaps {
            return "comgooglemaps://" + baselineURI
        } else {
            return "https://maps.apple.com/" + baselineURI
        }
    }
    
    // MARK: IB Handler Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Reacts to the NavBar "Done" button being hit.
     */
    @IBAction func doneButtonHit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     Reacts to the NavBar "Action" button being hit.
     
     - parameter sender: The IB Object that called this (the action button -ignored).
     */
    @IBAction func actionButtonHit(_ sender: Any) {
        let sharedPrintController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "print Job"
        sharedPrintController.printPageRenderer = BMLT_MeetingSearch_SingleMeeting_PageRenderer(meeting: self.meetingData, mapFormatter: self.locationMapView.viewPrintFormatter())
        sharedPrintController.present(from: self.view.frame, in: self.view, animated: false, completionHandler: nil)
    }

    /* ################################################################## */
    /**
     Reacts to the NavBar "Show/Hide Route" button being hit.
     */
    @IBAction func routeButtonHit(_ sender: Any) {
        if "DIRECTIONS-BUTTON-ON".localizedVariant == self.routeButton.title {
            self.removeDirections()
        } else {
            self.placeDirections()
        }
    }
    
    /* ################################################################## */
    /**
     Reacts to the NavBar "Directions" button being hit.
     */
    @IBAction func directionsButtonHit(_ sender: Any!) {
        let directionsURI = self.mapDirectionsURI
        #if DEBUG
            print("DirectionsURI: \(directionsURI)")
        #endif
        
        if let openLink = URL(string: directionsURI) {
            UIApplication.shared.open(openLink, options: [:], completionHandler: nil)
        }
    }

    /* ################################################################## */
    /**
     Reacts to the map type control being changed.
     
     - parameter sender: The segmented control that triggered this.
     */
    @IBAction func mapTypeControlChanged(_ sender: UISegmentedControl) {
        let mapTypeIndex = sender.selectedSegmentIndex
        self.prefs.mapTypeIndex = mapTypeIndex
        self.locationMapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
    }
    
    // MARK: Internal Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Set up our map to show the meeting location.
     */
    func setUpMap() {
        if nil != self.locationMapView {
            if let mapLocation = self.meetingData.locationCoords {
                let mapTypeIndex = self.prefs.mapTypeIndex
                self.locationMapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
                self.mapTypeSegmentedControl.selectedSegmentIndex = mapTypeIndex
                self.mapAnnotation = BMLT_MeetingSearch_Annotation(coordinate: mapLocation, meeting: self.meetingData)
                self.locationMapView.addAnnotation(self.mapAnnotation)
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0)
                let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
                self.locationMapView.setRegion(newRegion, animated: false)
            }
        }
    }

    /* ################################################################## */
    /**
     Set up our map to show the meeting location.
     */
    func removeDirections() {
        for overlay in self.locationMapView.overlays {
            if !overlay.isKind(of: BMLT_MeetingSearch_Annotation.self) {
                self.locationMapView.removeOverlay(overlay)
            }
        }
        
        self.routeButton.title = "DIRECTIONS-BUTTON-OFF".localizedVariant
    }

    /* ################################################################## */
    /**
     Set up our map to show the meeting location.
     */
    func placeDirections() {
        if let meetingCoords = self.meetingData.locationCoords {
            self.routeButton.title = "DIRECTIONS-BUTTON-ON".localizedVariant
            self.busyView.isHidden = false
            let mePlacemark = MKPlacemark(coordinate: self.locationMapView.userLocation.coordinate)
            let meetingPlacemark = MKPlacemark(coordinate: meetingCoords)
            let directionsRequest = MKDirections.Request()
            directionsRequest.destination = MKMapItem(placemark: meetingPlacemark)
            directionsRequest.source = MKMapItem(placemark: mePlacemark)
            
            let directions = MKDirections(request: directionsRequest)
            
            directions.calculate(completionHandler: { (response, error) in
                self.busyView.isHidden = true
                if nil == error {
                    if let hardResponse = response {
                        var overlays: [MKOverlay] = []
                        for route in hardResponse.routes {
                            let overlayLine = route.polyline
                            overlays.append(overlayLine)
                        }
                        if 0 < overlays.count {
                            self.locationMapView.addOverlays(overlays, level: MKOverlayLevel.aboveRoads)
                            
                            var northEast = CLLocationCoordinate2DMake(-360, -360)
                            var southWest = CLLocationCoordinate2DMake(360, 360)
                            northEast.latitude = max(meetingCoords.latitude, northEast.latitude)
                            northEast.longitude = max(meetingCoords.longitude, northEast.longitude)
                            
                            southWest.latitude = min(meetingCoords.latitude, southWest.latitude)
                            southWest.longitude = min(meetingCoords.longitude, southWest.longitude)
                            
                            northEast.latitude = max(self.locationMapView.userLocation.coordinate.latitude, northEast.latitude)
                            northEast.longitude = max(self.locationMapView.userLocation.coordinate.longitude, northEast.longitude)
                            
                            southWest.latitude = min(self.searchLocation.latitude, southWest.latitude)
                            southWest.longitude = min(self.searchLocation.longitude, southWest.longitude)
                            
                            if (-360 < northEast.latitude) && (-360 < northEast.longitude) && (360 > southWest.latitude) && (360 > southWest.longitude) {
                                let center = CLLocationCoordinate2D(latitude: (northEast.latitude + southWest.latitude) / 2.0, longitude: (northEast.longitude + southWest.longitude) / 2.0)
                                let span = MKCoordinateSpan(latitudeDelta: fabs(northEast.latitude - southWest.latitude) * 2.5, longitudeDelta: abs(northEast.longitude - southWest.longitude) * 2.5)
                                
                                let spanRegion = MKCoordinateRegion.init(center: center, span: span)
                                
                                let fitRegion = self.locationMapView.regionThatFits(spanRegion)
                                
                                self.locationMapView.setRegion(fitRegion, animated: true)
                            }
                        }
                    }
                } else {
                    self.busyView.isHidden = true
                    BMLT_MeetingSearch_AppDelegate.displayAlert("BMLTNAMeetingSearchError-FailedDirectionsHeader", inMessage: "BMLTNAMeetingSearchError-NoDirectionsResultsText", presentedBy: self)
                }
            })
        }
    }
        
    // MARK: - Base Class Override Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     If we have no comments, then we make the map bigger.
     */
    override func viewDidLayoutSubviews() {
        // We expand the map if the contents field is empty. Don't want to waste space.
        if self.meetingData.comments.isEmpty {
            self.commentsTextField.isHidden = true
            self.mapTopConstraint.constant = 0
        }
        super.viewDidLayoutSubviews()
    }

    /* ################################################################## */
    /**
     Called when the view is loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = [self.meetingData]
        self.myNavigationBar.barTintColor = self.gradientTopColor
        self.meetingNameLabel.text = self.meetingData.name
        
        self.routeButton.title = "DIRECTIONS-BUTTON-OFF".localizedVariant
        self.directionsButton.title = self.directionsButton.title?.localizedVariant

        // Set the meeting name.
        self.meetingNameLabel.text = self.meetingData.name
        
        // Set the time, day and format text.
        if var hour = self.meetingData.startTimeAndDay.hour, let minute = self.meetingData.startTimeAndDay.minute {
            var time = ""
            
            if ((23 == hour) && (55 <= minute)) || ((0 == hour) && (0 == minute)) || (24 == hour) {
                time = "DETAILS-SCREEN-MIDNIGHT".localizedVariant
            } else if (12 == hour) && (0 == minute) {
                time = "DETAILS-SCREEN-NOON".localizedVariant
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                
                let dateString = formatter.string(from: Date())
                let amRange = dateString.range(of: formatter.amSymbol)
                let pmRange = dateString.range(of: formatter.pmSymbol)
                
                if !(pmRange == nil && amRange == nil) {
                    var amPm = formatter.amSymbol
                    
                    if 12 < hour {
                        hour -= 12
                        amPm = formatter.pmSymbol
                    } else if 12 == hour {
                        amPm = formatter.pmSymbol
                    }
                    time = String(format: "%d:%02d %@", hour, minute, amPm!)
                } else { time = String(format: "%d:%02d", hour, minute) }
            }
            
            let weekday = BMLT_MeetingSearch_Prefs.weekdayNameFromWeekdayNumber(self.meetingData.weekdayIndex)
            let localizedFormat = "DETAILS-SCREEN-MEETING-TIME-FORMAT".localizedVariant
            let formats = self.meetingData.formatsAsCSVList.isEmpty ? "" : " (" + self.meetingData.formatsAsCSVList + ")"
            self.meetingTimeLabel.text = String(format: localizedFormat, weekday, time) + formats
        }
        
        // Add the address information to that field.
        self.addressTextView.text = self.meetingData.basicAddress
        if !self.meetingData.comments.isEmpty { self.commentsTextField.text = self.meetingData.comments }
        
        // Set up localized names for the map type control.
        for i in 0..<self.mapTypeSegmentedControl.numberOfSegments { if let segmentTitle = self.mapTypeSegmentedControl.titleForSegment(at: i) { self.mapTypeSegmentedControl.setTitle(segmentTitle.localizedVariant, forSegmentAt: i) } }
        
        self.mapTypeSegmentedControl.selectedSegmentIndex = self.prefs.mapTypeIndex
        
        // We do this in order to prevent the background tap recognizer from interfering with the map.
        self.tappedInBackgroundGestureRecognizer.cancelsTouchesInView = false

        self.setUpMap()
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
                markerView.canShowCallout = true
                myAnnotation.title = "DIRECTIONS-BUTTON-CALLOUT".localizedVariant
                let directionsButton = UIButton(type: .infoLight)
                markerView.rightCalloutAccessoryView = directionsButton
                return markerView
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This renders the directions polylines.
     
     - parameter mapView: The map view object
     - parameter rendererFor: The overlay to be rendered.
     
     - returns: a new renderer for the overlay.
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    /* ################################################################## */
    /**
     This reacts to the callout directions button being touched in the meeting location marker.
     It will open the directions link for the meeting in whatever form the user wants.
     
     - parameter mapView: The map view object
     - parameter calloutAccessoryControlTapped: The control that was hit.
     */
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.directionsButtonHit(nil)
    }
}
