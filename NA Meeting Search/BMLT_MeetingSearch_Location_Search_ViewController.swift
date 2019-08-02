//
//  BMLT_MeetingSearch_Location_Search_ViewController.swift
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

/* ###################################################################################################################################### */
/**
 This class contains the root "Location Search" screen.
 */
class BMLT_MeetingSearch_Location_Search_ViewController: BMLT_MeetingSearch_RootViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: - Private Instance Properties
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
        This is the segue ID for starting the search, and bringing in the progress screen.
     */
    private let _mainSearchSegueID: String = "perform-location-meetings-in-range-search-segue-id"
    
    /* ################################################################## */
    /**
     This is the opacity of the busy overlay.
     */
    private let _overlayOpacity: CGFloat = 0.15
    
    /* ################################################################## */
    /**
        This is our initial zoom level.
     */
    private let _initialZoom = 0.35
    
    /* ################################################################## */
    /**
     This will hold our location manager.
     */
    private var _locationManager: CLLocationManager! = nil
    
    /* ################################################################## */
    /**
     This will hold a geocoder object, for looking up addresses.
     */
    private var _geocoderObject: CLGeocoder! = nil
    
    /* ################################################################## */
    /**
     We can do two tries to determine location. This is set to true after the first one.
     */
    private var _locationFailedOnce: Bool = false

    // MARK: - IB Instance Properties
    /* ##################################################################################################################################*/
    /// Label for "Find Meetings Within"
    @IBOutlet weak var findMeetingsWithinLabel: UILabel!
    /// The text field for entering distance.
    @IBOutlet weak var distanceTextField: UITextField!
    /// The text field, denoting distance units.
    @IBOutlet weak var unitLabel: UILabel!
    /// The stepper, for the distance value.
    @IBOutlet weak var distanceValueStepper: UIStepper!
    /// The switch for turning auto-radius mode on or off.
    @IBOutlet weak var autoSwitch: UISwitch!
    /// The button near the top, for setting the map to the entered location.
    @IBOutlet weak var setLocationButton: UIButton!
    /// The button for performing the search.
    @IBOutlet weak var performBasicSearchButton: UIButton!
    /// The label for the search string entry.
    @IBOutlet weak var stringSearchLabel: UILabel!
    /// The text field, for the search string.
    @IBOutlet weak var stringSearchTextField: UITextField!
    /// The map view.
    @IBOutlet weak var mapView: MKMapView!
    /// The activity indicator, for locating the search string place.
    @IBOutlet weak var stringSearchActivityIndicator: UIActivityIndicatorView!
    /// The segmented control at the bottom, for selecting the map type.
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!

    // MARK: - Instance Properties
    /* ##################################################################################################################################*/
    /// The distance, as an integer, of the radius; in whatever our distance units are.
    var distance: Int = 0
    /// The annotation for the map marker.
    var mapAnnotation: BMLT_MeetingSearch_Annotation! = nil
    /// A semaphore, for marking when the map has been set up.
    var initialMapSetDone: Bool = false
    /// the current search location.
    var searchLocation: CLLocationCoordinate2D! = nil
    /// The string to use for looking up a location.
    var searchString: String = ""
    /// The overlay for the radius when in non-auto mode.
    var distanceOverlay: MKCircle! = nil

    // MARK: - IB Action Methods
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
     Reacts to the location button over the map being hit.
     
     - parameter: ignored.
     */
    @IBAction func locationButtonHit(_ : Any) {
        self.showActivityIndicator()
        self.removeDistanceOverlay()
        self.startLookingUpMyLocation()
    }

    /* ################################################################## */
    /**
     Called when the button to change the map location to the string address is hit.
     
     - parameter: ignored
     */
    @IBAction func setLocationButtonHit(_ : Any!) {
        if !self.searchString.isEmpty {
            self.tappedInBackground()   // Put away the keyboard.
            self.lookUpAddress(self.searchString)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the auto switch changes state.
     
     - parameter: ignored
     */
    @IBAction func autoSwitchChanged(_ : UISwitch) {
        self.checkSearchButtonEnabledStatus()
    }
    
    /* ################################################################## */
    /**
     Called when the distance stepper is hit.
     
     - parameter ssendder: The stepper control.
     */
    @IBAction func stepperHit(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        self.distance = newValue
        self.addDistanceOverlay()
        self.distanceTextField.text = String(newValue)
        self.checkSearchButtonEnabledStatus()
    }
    
    /* ################################################################## */
    /**
     Called when the findd meetings button is hit.
     
     - parameter: ignored
     */
    @IBAction func doSearchHit(_ : Any!) {
        self.stopLookingUpMyLocation()
        if (nil != searchLocation) && (!self.autoSwitch.isOn || (0 < self.distance)) {
            self.performSegue(withIdentifier: self._mainSearchSegueID, sender: nil)
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
        self.setLocationButton.setTitle(setLocationButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.performBasicSearchButton.setTitle(performBasicSearchButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.findMeetingsWithinLabel.text = self.findMeetingsWithinLabel.text?.localizedVariant
        self.stringSearchLabel.text = self.stringSearchLabel.text?.localizedVariant
        self.stringSearchTextField.placeholder = self.stringSearchTextField.placeholder?.localizedVariant
        self.unitLabel.text = (BMLT_MeetingSearch_Prefs.usingKilometeres ? "BMLTNAMeetingSearch-DistanceUnitsKm-Short" : "BMLTNAMeetingSearch-DistanceUnitsMiles-Short").localizedVariant

        // Set up localized names for the map type control.
        for i in 0..<self.mapTypeSegmentedControl.numberOfSegments {
            if let segmentTitle = self.mapTypeSegmentedControl.titleForSegment(at: i) {
                self.mapTypeSegmentedControl.setTitle(segmentTitle.localizedVariant, forSegmentAt: i)
            }
        }
        
        let mapTypeIndex = self.prefs.mapTypeIndex
        self.mapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
        self.mapTypeSegmentedControl.selectedSegmentIndex = mapTypeIndex
        self.distance = Int(ceil(self.prefs.defaultDistanceValue))
        self.distanceValueStepper.value = Double(self.distance)
        self.distanceTextField.text = String(self.distance)
        self.searchLocation = nil
        self.checkSearchButtonEnabledStatus()
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchString = ""
        self.stringSearchTextField.text = ""
        self.checkSearchButtonEnabledStatus()
        var goodLoc: Bool = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                break
                
            case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
                goodLoc = true
            @unknown default:
                fatalError("WTF, Dude?")
            }
        }
        
        if !goodLoc {
            BMLT_MeetingSearch_AppDelegate.displayAlert("BMLTNAMeetingSearchError-LocationFailHeader", inMessage: "BMLTNAMeetingSearchError-LocationOffText", presentedBy: self)
        } else {
            self.initialMapSetDone = false
            if nil == self.searchLocation {
                self.removeDistanceOverlay()
                self.startLookingUpMyLocation()
            }
        }

        self.setUpMap()
    }
    
    /* ################################################################## */
    /**
     Called just before the view will disappear.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopLookingUpMyLocation()
        self.stopLookingUpAddress()
    }

    /* ################################################################## */
    /**
     This is called as the segue is about to happen.
     We use this opportunity to tell the progress screen what we want done (simple location lookup, followed by today and tomorrow).
     
     - parameter segue: The segue being exercised.
     - parameter sender: Any extra info we want attached (ignored).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == self._mainSearchSegueID {
            if let destination = segue.destination as? BMLT_MeetingSearch_Progress_ViewController {
                if nil != self.searchLocation {
                    destination.criteriaObject.clearAll()
                    destination.searchLocation = self.searchLocation
                    destination.lookUpLocationFirst = false
                    destination.useSearchCriteria = true
                    destination.searchWasAMapSearch = true
                    if !self.autoSwitch.isOn {
                        destination.criteriaObject.searchRadius = -1 * Float(self.prefs.autoSearchDensity)
                    } else {
                        destination.criteriaObject.searchRadius = Float(self.distance)
                    }
                }
            }
        }
    }

    // MARK: - Instance Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     Checks the state of the various IB items, and enables/disables/hides, as necessary.
     */
    func checkSearchButtonEnabledStatus() {
        if !self.autoSwitch.isOn {
            self.distanceTextField.text = ""
        } else {
            self.distanceValueStepper.value = Double(self.distance)
            if (self.distanceTextField.text?.isEmpty)! {
                self.distanceTextField.text = String(self.distance)
            }
        }
        
        self.setLocationButton.isEnabled = !self.searchString.isEmpty
        self.distanceValueStepper.isEnabled = self.autoSwitch.isOn
        self.distanceTextField.isEnabled = self.autoSwitch.isOn
        self.performBasicSearchButton.isEnabled = !self.autoSwitch.isOn || (0 < self.distance)
        // See if we need to add a circle overlay.
        self.addDistanceOverlay()
    }
    
    /* ################################################################## */
    /**
     Set up our map to show the meeting location.
     */
    func setUpMap() {
        if nil != self.mapView {
            DispatchQueue.main.async {
                self.removeBlackMarker()
                self.removeDistanceOverlay()
                let mapTypeIndex = self.prefs.mapTypeIndex
                self.mapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
                self.mapTypeSegmentedControl.selectedSegmentIndex = mapTypeIndex
                if nil != self.searchLocation {
                    // Add the black marker.
                    self.addBlackMarker()
                    // First time through, we center and zoom the map.
                    if !self.initialMapSetDone {
                        self.initialMapSetDone = true
                        let span = MKCoordinateSpan(latitudeDelta: self._initialZoom, longitudeDelta: 0)
                        let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: self.searchLocation, span: span)
                        self.mapView.setRegion(newRegion, animated: true)
                    } else {    // Otherwise, we just center the map.
                        self.mapView.setCenter(self.searchLocation, animated: true)
                    }
                    
                    self.hideActivityIndicator()

                    // See if we need to add a circle overlay.
                    self.addDistanceOverlay()
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Removes the black marker from the map.
     */
    func removeBlackMarker() {
        if nil != self.mapAnnotation {
            self.mapView.removeAnnotation(self.mapAnnotation)
            self.mapAnnotation = nil
        }
    }
    
    /* ################################################################## */
    /**
     Adds the black marker at the current search location.
     */
    func addBlackMarker() {
        self.removeBlackMarker()
        if  nil != self.searchLocation {
            self.mapAnnotation = BMLT_MeetingSearch_Annotation(coordinate: self.searchLocation)
            self.mapView.addAnnotation(self.mapAnnotation)
        }
    }
    
    /* ################################################################## */
    /**
     Removes the disatance overlay circle.
     */
    func removeDistanceOverlay() {
        if nil != self.distanceOverlay {
            self.mapView.removeOverlay(self.distanceOverlay)
            self.distanceOverlay = nil
        }
    }
    
    /* ################################################################## */
    /**
     Applies the distance overlay circle.
     */
    func addDistanceOverlay() {
        self.removeDistanceOverlay()
        if self.autoSwitch.isOn && (0 < self.distance) && (nil != self.searchLocation) {
            let distanceInKM: Double = Double(self.distance) * (BMLT_MeetingSearch_Prefs.usingKilometeres ? 1.0 : 1.60934)
            self.distanceOverlay = MKCircle(center: self.searchLocation, radius: distanceInKM * 1000)
            self.mapView.addOverlay(self.distanceOverlay)
        }
    }

    /* ################################################################## */
    /**
     This simply starts looking for where the user is at.
     */
    func startLookingUpMyLocation() {
        self.showActivityIndicator()
        self.searchLocation = nil
        self._locationManager = CLLocationManager()
        self._locationManager.requestWhenInUseAuthorization()
        self._locationManager.delegate = self
        self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self._locationManager.startUpdatingLocation()
    }

    /* ################################################################## */
    /**
     This stops the location manager lookups.
     */
    func stopLookingUpMyLocation() {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
            self._locationManager.delegate = nil
            self._locationManager = nil
        }
    }
    
    /* ################################################################## */
    /**
     This simply starts looking for where the user is at.
     
     - parameter inString: The string to be looked up.
     */
    func lookUpAddress(_ inString: String) {
        self.stopLookingUpAddress()
        self.stopLookingUpMyLocation()
        self.showActivityIndicator()
        self._geocoderObject = CLGeocoder()
        self._geocoderObject.geocodeAddressString(inString) { (inPlaceMarks: [CLPlacemark]?, inError: Error?) in
            self.handleGeocoderResponse(inPlaceMarks: inPlaceMarks, inError: inError)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the geocoder replies.
     
     - parameter inPlaceMarks: An array of placemark objects that correspond to the geocoder results.
     - parameter inError: Any error that occurred.
     */
    func handleGeocoderResponse(inPlaceMarks: [CLPlacemark]?, inError: Error?) {
        self.stopLookingUpAddress()
        if nil == inError {
            if let placeMarks = inPlaceMarks {
                if !placeMarks.isEmpty {
                    self.searchLocation = placeMarks[0].location?.coordinate
                    self.setUpMap()
                }
            }
        }
    }

    /* ################################################################## */
    /**
     This stops the location manager lookups.
     */
    func stopLookingUpAddress() {
        if nil != self._geocoderObject {
            self._geocoderObject.cancelGeocode()
            self._geocoderObject = nil
        }
    }

    /* ################################################################## */
    /**
     Shows the activity indicator, hiding the search string items.
     */
    func showActivityIndicator() {
        self.stringSearchTextField.isHidden = true
        self.stringSearchLabel.isHidden = true
        self.setLocationButton.isHidden = true
        self.stringSearchActivityIndicator.isHidden = false
    }
    
    /* ################################################################## */
    /**
     Hides the activity indicator, restoring the search string items.
     */
    func hideActivityIndicator() {
        self.stringSearchActivityIndicator.isHidden = true
        self.stringSearchTextField.isHidden = false
        self.stringSearchLabel.isHidden = false
        self.setLocationButton.isHidden = false
    }

    // MARK: - UITextFieldDelegate Methods
    /* ##################################################################################################################################*/
    /* ################################################################## */
    /**
     This is called when something is typed in a text field.
     
     We interpret the result of the typing, and either allow or disallow it, based on those results.
     
     We also update our distance and search string properties.
     
     - parameter textField: The text field affected.
     - parameter shouldChangeCharactersIn: A range that denotes which existing characters will be replaced by...
     - parameter replacementString: The string to replace the above characters.
     
     - returns: True, if the replacement is allowed.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var ret: Bool = false
        
        if let originalString = textField.text as NSString? {
            let newString = originalString.replacingCharacters(in: range, with: string)
            if textField == self.distanceTextField {
                self.distance = 0
                self.addDistanceOverlay()
                if nil != newString.range(of: "^([0-9]+?)$", options: .regularExpression) {
                    if let newValue = Int(newString) {
                        if newValue <= Int(self.distanceValueStepper.maximumValue) {
                            self.distance = newValue
                            self.addDistanceOverlay()
                            self.distanceValueStepper.value = Double(newValue)
                            ret = true
                        }
                    }
                } else {
                    if newString.isEmpty {
                        ret = true
                    }
                }
            } else {
                self.searchString = newString
                ret = true
            }
        }
        
        self.checkSearchButtonEnabledStatus()
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when the return/done key is hit.
     
     It closes the text field, and starts the search or sets the location.
     
     - parameter textField: The text field affected.
     
     - returns: True, if the return is OK (all the time).
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.stringSearchTextField {
            self.setLocationButtonHit(self.setLocationButton)
        } else {
            self.doSearchHit(self.performBasicSearchButton)
        }
        return true
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
                let markerView = BMLT_MeetingSearch_MapMarkerAnnotationView(annotation: myAnnotation, draggable: true, reuseID: reuseID)
                markerView.canShowCallout = false   // No callout.
                markerView.isSelected = true    // I do this to prevent the "two taps to select" issue.
                return markerView
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This responds to a marker being moved.
     
     - parameter mapView: The MKMapView object that contains the marker being moved.
     - parameter annotationView: The annotation that was changed.
     - parameter didChange: The new state of the marker.
     - parameter fromOldState: The previous state of the marker.
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .dragging:
            self.removeDistanceOverlay()
            self.showActivityIndicator()
            
        case .none:
            if .dragging == oldState {  // If this is a drag ending, we extract the new coordinates, and change the meeting object.
                self.searchLocation = view.annotation?.coordinate
                let span = self.mapView.region.span
                let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: self.searchLocation, span: span)
                self.mapView.setRegion(newRegion, animated: true)
                self.addDistanceOverlay()
                self.hideActivityIndicator()
           }
            
        default:
            break
        }
    }
    
    /* ################################################################## */
    /**
     This provides the map circle overlay (If we have a specific distance selected).
     
     - parameter mapView: The MKMapView object that contains the overlay.
     - parameter rendererFor: The overlay object.
     
     - returns: The renderer (a simple translucent circle).
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(self._overlayOpacity)
        return renderer
    }
    
    // MARK: Internal CLLocationManagerDelegate Methods
    /* ##################################################################################################################################*/
    /**
     This is called if the location manager suffers a failure.
     
     - parameter manager: The Location Manager object that had the error.
     - parameter didFailWithError: The error in question.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.stopLookingUpMyLocation()
        if self._locationFailedOnce {   // If at first, you don't succeed...
            self._locationFailedOnce = false
            BMLT_MeetingSearch_AppDelegate.displayAlert("BMLTNAMeetingSearchError-LocationFailHeader", inMessage: "BMLTNAMeetingSearchError-LocationFailText", presentedBy: self)
            self.hideActivityIndicator()
        } else {    // We try two times.
            self._locationFailedOnce = true
            self.startLookingUpMyLocation()
        }
    }
    
    /* ################################################################## */
    /**
     Callback to handle found locations.
     
     - parameter manager: The Location Manager object that had the event.
     - parameter didUpdateLocations: an array of updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.stopLookingUpMyLocation()
        for location in locations where 1.0 > location.timestamp.timeIntervalSinceNow {
            // Ignore cached locations. Wait for the real.
            self.stopLookingUpMyLocation()
            self.searchLocation = location.coordinate
            self.setUpMap()
        }
    }
}
