//
//  GoogleMapViewController.swift
//  HeroEyez-ClassRoom
//
//  Created by Delaplex Software
//  Copyright © 2016 Grays Communications LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

/**
 *  Protocol which will be adapted to its superclass to get notified on google sdk delegates.
 */
@objc protocol GoogleMapViewControllerDelegate
{
    /**
     This function will provide information that where the marker tap
     
     - parameter position: GMSMapView as map's surface & GMSMarker placed at a particular point on the map's surface
     */
    @objc optional func mapViewMarkerTapped(_ mapView: GMSMapView, marker: GMSMarker)
    
    @objc optional func mapViewMarkerInfoSnippetDidClose()
    
    @objc optional func mapViewMarkerInfoSnippetDidOpen()
    
    @objc optional func mapViewCordinateTap(_ mapView: GMSMapView, cordinate : CLLocationCoordinate2D)
    
    @objc optional func mapViewCordinateLongPress(_ mapView: GMSMapView, cordinate : CLLocationCoordinate2D)
    
    @objc optional func mapViewDidDrageed(_ mapView: GMSMapView, marker: GMSMarker!)
    
    @objc optional func idleMapViewAt(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
}

//MARK:-
/// Google map model class to be used for implementing google map with all the possible scenarios, route draw , pin plot , current location.
class GoogleMapViewController: UIViewController, GMSMapViewDelegate
{
    //MARK:- Variable Declerations - Setters
    /// Boolean value which will determine whether we should show the source and destination text fields or not , it is not functional as of now.
    
    var shouldShowSearchFields  : Bool!
    /// It will store the current location cordinate of the device.
    
    var currentLoc              = CLLocationCoordinate2D()
    
    /// Map type
    
    var mapType : MAPTYPE!      = nil
    
    var sourceMarker : CustomMarker!
    
    var destinationMarker : CustomMarker!
    
    var allowMapDrag : Bool!    = true
    
    var padding : CGFloat!
    
    var showCurrentLoc : Bool!    = true
    
    var showCurrentLocBTN : Bool! = false
    
    //MARK:- Variable Declerations - Getters
    var etaModelFetched             = ETAModel()
    
    var sourceSearchText            = String()
    
    var destinationSearchText       = String()
    
    var customMapView               = GMSMapView()
    
    //MARK:- Variable Declerations - ETA
    var totalDurationInSeconds: UInt = 0
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDuration: String!
    
    var delegate: GoogleMapViewControllerDelegate?
    
    var polyline : GMSPolyline!
    
    var path : GMSPath!
    
    //MARK:- Default Override Functions    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initGoogleMap()
    }
    
    /**
     When UIViewController's view fully loaded
     
     - parameter animated: true
     */
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    //MARK:- Custom Functions    
    /**
     When you initially instantiating the current class and want to plot marker all together.
     
     - parameter pCurrentLoc:             Current location of the device
     - parameter pSourceMarker:           Source marker sublass of custom marker with image and cordinate
     - parameter pDestinationMarker:       Destination marker sublass of custom marker with image and cordinate (Destination)
     - parameter pShouldShowSearchFields: True will show the text will , false will hide the text fields
     - parameter pMapType:                See MAPType enum
     - parameter pAlowMapDrag:            False will restrict the Map view dragging.
     
     - returns: nil
     */
    
    func initWithParameters(_ pCurrentLoc : CLLocationCoordinate2D, pSourceMarker : CustomMarker, pDestinationMarker : CustomMarker, pShouldShowSearchFields : Bool,  pMapType : MAPTYPE, pAlowMapDrag : Bool!) // Assigning data which was passed from parent class.
    {
        shouldShowSearchFields      = pShouldShowSearchFields
        
        currentLoc                  = pCurrentLoc
        
        sourceMarker                = pSourceMarker
        
        destinationMarker           = pDestinationMarker
        
        shouldShowSearchFields      = pShouldShowSearchFields
        
        mapType                     = pMapType
        
        allowMapDrag                = pAlowMapDrag
    }
    
    /**
     Setting up mapView according to requirement. (See enum Map type)
     
     - returns: nil
     */
    func initGoogleMap()
    {
        if mapType == .pinDrop
        {
            pinDropMap()
            
        }else if mapType == .routeDraw
        {
            
            
        }else if mapType == .currentLoc
        {
            currentLocationWithMap()
        }
        customizeButton(true)
    }
    
    /**
     Check for the customised button
     
     - parameter hidden: boolean value as Input
     */
    func customizeButton(_ hidden : Bool)
    {
        //        if let btn = customMapView .subviews .last
        //        {
        //            var frame = btn.frame
        //
        //            frame.size.height =  0.25 * (frame.size.height)
        //
        //            frame.size.width =  0.25 * (frame.size.width)
        //
        //            btn.frame = frame
        //
        //            btn.isHidden = false
        //        }
    }
    
    
    //    func changeCompassBtn()
    //    {
    //        for view: UIView in customMapView.subviews
    //        {
    //            var isRange = (view.description as NSString).range("GSMUISettingsView")
    //            if isRange.location != NSNotFound
    //            {
    //                for viewSub: UIView in view.subviews
    //                {
    //                    var isRange = (viewSub.description as NSStrinrangeeOf("GMSCompassButton")
    //                    if isRange.location != NSNotFound
    //                    {
    //                        var frame = viewSub.frame
    //                        frame.origin.y = 55
    //                        frame.origin.x = gmMapView.frame.size.width / 2
    //                        viewSub.frame = frame
    //                    }
    //
    //                }
    //            }
    //        }
    //    }
    
    /**
     It will be called if are instantiating the map with Pin drop enum type.
     */
    func pinDropMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude: self.currentLoc.latitude,
                                              longitude: self.currentLoc.longitude, zoom: 15)
        
        customMapView =  GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        if showCurrentLoc == true
        {
            customMapView.isMyLocationEnabled = true
            
            customMapView.settings.myLocationButton = false
        }
        
        if showCurrentLocBTN == true
        {
            customMapView.settings.myLocationButton = true
        }
        customMapView.delegate = self
        
        self.view = customMapView
        
        customizeButton(false)
        
        if sourceMarker != nil
        {
            placePinAtCoordinate(sourceMarker, mapView: customMapView)
        }
        if destinationMarker != nil
        {
            placePinAtCoordinate(destinationMarker, mapView: customMapView)
        }
    }
    
    //MARK: Manage marker Flicker
    func checkIfMutlipleCoordinates(latitude : Float , longitude : Float) -> CLLocationCoordinate2D
    {
        
        var lat = latitude
        var lng = longitude
        
            // Core Logic giving minor variation to similar lat long
            let variation = (randomFloat(min: 0.90, max: 1.30) - 0.95) / 2800
            lat = lat + variation
            lng = lng + variation

        let finalPos = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        return  finalPos
    }
    
    func randomFloat(min: Float, max:Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    /**
     It will be called if are instantiating the map with current loc enum type.
     */
    func currentLocationWithMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude: self.currentLoc.latitude,
                                              longitude: self.currentLoc.longitude, zoom: 15)
        customMapView =  GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        customMapView.isBuildingsEnabled = true
        customMapView.isIndoorEnabled = true
        customMapView.isTrafficEnabled = true
        customMapView.settings.compassButton = true
        
        if  showCurrentLoc == true
        {
            customMapView.isMyLocationEnabled = true
            customMapView.settings.myLocationButton = false
            customMapView.settings.compassButton = true
        }
        customMapView.delegate = self
        
        self.view = customMapView
        
        customizeButton(false)
        
        // changeCompassBtn()
    }
    
    //MARK:- Draw route
    
    /**
     To draw a route between to cordinates.
     
     - parameter origin:            Source marker cordinate
     - parameter destination:       destination marker cordinate
     - parameter zoomCamera:        True if you want to zoom the map.
     - parameter completionHandler: GMSPolyline - to draw the route.
     */
    func drawRoute(origin: CLLocation, destination: CLLocation, zoomCamera : Bool!, completionHandler: @escaping (_ polyline : AnyObject, _ eta : ETAModel?) -> Void)
    {
        let key : String = Macros.ApiKeys.mapKeyGoogle
        
        let originString: String = "\(origin.coordinate.latitude),\(origin.coordinate.longitude)"
        
        let destinationString: String = "\(destination.coordinate.latitude),\(destination.coordinate.longitude)"
        
        let directionsAPI: String = "https://maps.googleapis.com/maps/api/directions/json?"
        
        let directionsUrlString: String = "\(directionsAPI)&origin=\(originString)&destination=\(destinationString)&key=\(key)"
        
        Alamofire.request(directionsUrlString, method: .get, parameters: ["":""], encoding: URLEncoding.default)
            .downloadProgress { progress in
                //print("Progress: \(progress.fractionCompleted)")
            }
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                debugPrint(response)
                
                guard response.result.error == nil else
                {
                    return
                }
                
                if let JSON = response.result.value
                {
                    self.getRoutesWayPointsBetweenCordinates(origin: origin.coordinate, destination: destination.coordinate, completionHandler:
                        { (routesArray) in
                            
                            if routesArray.count > 0
                            {
                                //                                let routesArray : NSArray = JSON
                                let routesArray : NSArray = (JSON as! NSDictionary).object(forKey: "routes") as! NSArray
                                
                                //JSON.objectForKey("routes") as! NSArray
                                
                                if routesArray.count > 0
                                {
                                    let routeDic : NSDictionary = routesArray[0] as! NSDictionary
                                    
                                    let routeOverviewPolyline = (routeDic ) .object(forKey:"overview_polyline")
                                    
                                    let points : String = (routeOverviewPolyline! as! NSDictionary) .object(forKey:"points") as! String
                                    
                                    //Getting ETA
                                    self.calculateETA(routesN: routeDic , completionHandler: { (eta) in
                                        
                                        //Assigning data to ETA Model
                                        self.etaModelFetched = eta
                                        
                                        // Creating Path between source and destination.
                                        self.path = GMSPath(fromEncodedPath: points)
                                        
                                        if self.polyline != nil
                                        {
                                            self.polyline.map = nil
                                        }
                                        
                                        self.polyline  = GMSPolyline(path: self.path)
                                        
                                        self.polyline.strokeWidth = 4.5
                                        
                                        self.polyline.geodesic = true
                                        
                                        self.animateRoute(self.polyline, origin: origin.coordinate, destination: destination.coordinate, pathColor:Macros.Colors.routePathColorBlue, zoomCamera: zoomCamera)
                                        
                                        completionHandler(self.polyline, eta)
                                    })
                                }
                            }
                    })
                }else
                {
                    let poly : GMSPolyline = GMSPolyline()
                    poly.strokeWidth = 5.5
                    completionHandler(poly, nil)
                }
        }
    }
    
    /**
     To get all the possible way points between two cordinates.
     
     - parameter origin:            source marker cordinate
     - parameter destination:       destination marker cordinate
     - parameter completionHandler: It will return the array of dictionary of the way points between the two coordinates.
     */
    func getRoutesWayPointsBetweenCordinates(origin : CLLocationCoordinate2D, destination : CLLocationCoordinate2D, completionHandler: @escaping (_ routesArray : NSArray) -> Void)
    {
        let key : String = Macros.ApiKeys.mapKeyGoogle
        
        let originString: String = "\(origin.latitude),\(origin.longitude)"
        
        let destinationString: String = "\(destination.latitude),\(destination.longitude)"
        
        let directionsAPI: String = "https://maps.googleapis.com/maps/api/directions/json?"
        
        let directionsUrlString: String = "\(directionsAPI)&origin=\(originString)&destination=\(destinationString)&mode=driving&units=imperial&key=\(key)"
        
        Alamofire.request(directionsUrlString, method: .get, parameters: ["":""], encoding: URLEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                
                if let JSON = response.result.value
                {
                    //                    let routesArray : NSArray = (JSON as AnyObject).object("routes") as! NSArray
                    let routesArray : NSArray = (JSON as! NSDictionary).object(forKey: "routes") as! NSArray
                    
                    if routesArray.count > 0
                    {
                        completionHandler(routesArray)
                        
                    }else
                    {
                        completionHandler(NSArray())
                    }
                }else
                {
                    // Do nothing in this condition
                }
        }
    }
    
    /**
     animateRoute
     
     - parameter polyline:    GMSPolyline
     - parameter origin:      source marker cord
     - parameter destination: destination marker cord
     - parameter pathColor:   Path from waypoints
     - parameter zoomCamera:  True will zoom the map.
     */
    
    func animateRoute(_ polyline : GMSPolyline, origin : CLLocationCoordinate2D, destination : CLLocationCoordinate2D, pathColor : UIColor, zoomCamera : Bool!)
    {
        polyline.strokeColor = pathColor
        
        polyline.map = self.customMapView // Drawing route
        
        let bounds = GMSCoordinateBounds(path: path)
        
        var pad : CGFloat = 20.0
        
        if padding != nil
        {
            pad = padding
        }
        if zoomCamera == true
        {
            zoomCameraWithBounds(bounds, pad: pad)
        }
    }
    
    /**
     It will zoom the camera at specific bounds
     
     - parameter bounds: Bounds around which the camera should zoom
     - parameter pad:    Padding value from the edges of the window.
     */
    func zoomCameraWithBounds(_ bounds : GMSCoordinateBounds, pad : CGFloat)
    {
        let camera = self.customMapView.camera(for: bounds, insets:UIEdgeInsets.zero)
        
        self.customMapView.camera = camera!
        
        let zoomCamera = GMSCameraUpdate.fit(bounds, withPadding: pad)
        
        CATransaction.begin()
        CATransaction.setValue(Int(1.0), forKey: kCATransactionAnimationDuration)
        // YOUR CODE IN HERE
        self.customMapView.animate(with: zoomCamera) // Above lines will update map camera to fit to bounds so that the complete route between source and destination is visible.
        
        CATransaction.commit()
    }
    
    /**
     If you want to place a marker at specific cordinate which will not show a pop up on its tap do use this function
     
     - parameter marker:  Make a custom marker object provide proper values.
     - parameter mapView: Custom map view or self.
     */
    func placePinAtCoordinateWithoutSnippet(_ marker : CustomMarker, mapView : GMSMapView)
    {
        DispatchQueue.main.async
            {
                marker.appearAnimation = .pop
                
                marker.position = marker.coordinate
                
                marker.map = mapView // This will add marker to mapView.
                
                if marker.customImage != nil
                {
                    marker.icon = marker.customImage
                }
        }
    }
    
    /**
     If you want to place a marker at specific cordinate do use this function
     
     - parameter marker:  Make a custom marker object provide proper values.
     - parameter mapView: Custom map view or self.
     */
    
    func placePinAtCoordinate(_ marker : CustomMarker, mapView : GMSMapView)
    {
        DispatchQueue.main.async
            {
                marker.appearAnimation = .pop
                
                marker.position = marker.coordinate
                
                marker.map = mapView // This will add marker to mapView.
                
                if marker.customImage != nil
                {
                    marker.icon = marker.customImage
                }
        }
        
        self.getReverseGeoFromCordinate(marker.coordinate, marker: marker)
        { (addModel) in
            
            DispatchQueue.main.async
                {
                    marker.title = addModel.address // Annotation title and snippet.
                    
                    marker.snippet = addModel.subLocal
            }
            
        } // Reverse geo for Setting annotation title.
    }
    
    func placePinAtCoordinateWithTrackerUserName(_ marker : CustomMarker, mapView : GMSMapView, name : String!)
    {
        //Temp for Simulator
        if UIDevice.isSimulator == true
        {
        }else {
            marker.appearAnimation = .pop
            
            marker.position = marker.coordinate
            
            DispatchQueue.main.async
                {
                    marker.map = mapView // This will add marker to mapView.
            }
            
            if marker.customImage != nil
            {
                DispatchQueue.main.async {
                    marker.icon = marker.customImage
                }
            }
            
            self.getReverseGeoFromCordinate(marker.coordinate, marker: marker)
            { (addModel) in
                
                marker.title = addModel.address // Annotation title and snippet.
                if name != nil
                {
                    marker.snippet = name
                    
                }else
                {
                    marker.snippet = addModel.subLocal
                }
            } // Reverse geo for Setting annotation title.
        }
    }
    
    func placeParkingPinAtCoordinate(_ marker : CustomMarker, mapView : GMSMapView, center : Bool, completionHandler: @escaping (_ status : Bool) -> Void)
        
    {
        DispatchQueue.main.async
            {
                marker.appearAnimation = .pop
                
                marker.position = marker.coordinate
                
                marker.map = mapView // This will add marker to mapView.
                
                if marker.customImage != nil
                {
                    marker.icon = marker.customImage
                }
        }
        
        self.getReverseGeoFromCordinate(marker.coordinate, marker: marker)
        { (addModel) in
            
            DispatchQueue.main.async
                {
                    marker.title = NSLocalizedString("Parked_car", comment: "") // Annotation title and snippet.
                    marker.snippet = addModel.address
                    if center == true
                    {
                        self.customMapView.selectedMarker = marker
                        self.takeCameraToMarker(marker)
                    }
                    completionHandler(true)
            }
        } // Reverse geo for Setting annotation title.
    }
    
    /**
     To get the address from the reverse geo location service
     
     - parameter cordinate:         cordinate (latitude , longitude)
     - parameter marker:            custom marker object
     - parameter completionHandler: will return address model object with sublocality.
     */
    func getReverseGeoFromCordinate(_ cordinate : CLLocationCoordinate2D, marker : GMSMarker!, completionHandler: @escaping (_ addModel : AddressModel) -> Void)
    {
        // Checking if GPS is on or not
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                // if GPS is off
                let geoCoder : GMSGeocoder = GMSGeocoder()
                geoCoder .reverseGeocodeCoordinate(cordinate) { (response, error) in
                    let model = AddressModel()
                    
                    if error == nil && response != nil
                    {
                        let firstAddress : GMSAddress = (response?.firstResult())!
                        //print(firstAddress)
                        
                        var addString : String = ""
                        
                        if let address = firstAddress.lines
                        {
                            for str in address
                            {
                                addString .append("\(str) ")
                            }
                            model.address = addString
                        }else
                        {
                            model.address = NSLocalizedString("Address_N/A", comment: "")
                        }
                        
                        if let subLocal  = firstAddress.subLocality
                        {
                            model.subLocal = subLocal
                        }else
                        {
                            model.subLocal = NSLocalizedString("Sublocal_N/A", comment: "")
                        }
                        
                        completionHandler(model)
                        
                    }else
                    {
                        model.address = "N/A"
                        model.subLocal = "N/A"
                        completionHandler(model)
                    }
                }
                
            case .authorizedAlways, .authorizedWhenInUse:
                // create a region around current location and monitor enter/exit
                // If GPS is on
                
                let geoCoder : GMSGeocoder = GMSGeocoder()
                geoCoder .reverseGeocodeCoordinate(cordinate) { (response, error) in
                    let model = AddressModel()
                    
                    if error == nil && response != nil
                    {
                        let firstAddress : GMSAddress = (response?.firstResult())!
                        //print(firstAddress)
                        
                        if firstAddress.lines != nil
                        {
                            var addString : String = ""
                            for str in firstAddress.lines!
                            {
                                addString .append("\(str) ")
                            }
                            model.address = addString
                            
                        }else {
                            model.address = "N/A"
                        }
                        
                        if firstAddress.subLocality != nil
                        {
                            model.subLocal = firstAddress.subLocality!
                        }else {
                            model.subLocal = "N/A"
                        }
                        
                        completionHandler(model)
                        
                    }else
                    {
                        model.address = "N/A"
                        model.subLocal = "N/A"
                        completionHandler(model)
                    }
                }
            }
        } else {
            //print("Location services are not enabled")
            // if GPS is off
            let geoCoder : GMSGeocoder = GMSGeocoder()
            geoCoder .reverseGeocodeCoordinate(cordinate) { (response, error) in
                let model = AddressModel()
                
                if error == nil && response != nil
                {
                    let firstAddress : GMSAddress = (response?.firstResult())!
                    //print(firstAddress)
                    
                    if firstAddress.lines != nil
                    {
                        var addString : String = ""
                        for str in firstAddress.lines!
                        {
                            addString .append("\(str) ")
                        }
                        model.address = addString
                        
                    }else {
                        model.address = "N/A"
                    }
                    
                    if firstAddress.subLocality != nil
                    {
                        model.subLocal = firstAddress.subLocality!
                    }else {
                        model.subLocal = "N/A"
                    }
                    
                    completionHandler(model)
                    
                }else
                {
                    model.address = "N/A"
                    model.subLocal = "N/A"
                    completionHandler(model)
                }
            }
        }
    }
    
    /**
     To get center cordinates
     
     - returns: CLLocationCoordinate2D -  Center cordinates of the visible map.
     */
    func getCenterCordinates() -> CLLocationCoordinate2D
    {
        let  point : CGPoint = customMapView.center;
        
        let  coor : CLLocationCoordinate2D = customMapView.projection .coordinate(for: point)
        
        return coor
    }
    
    //MARK:- ETA
    //MARK:- Get ETA Betweeen two points
    /**
     To calculate the ETA betweem two cordinates
     
     - parameter origin: Source marker cordinate
     - parameter destination: destination marker cordinate
     - parameter completionHandler: ETA Model class *With proper estimates for duration and distance.*
     */
    func getETABetweenPoints(origin : CLLocationCoordinate2D, destination : CLLocationCoordinate2D,completionHandler: @escaping (_ eta : ETAModel) -> Void)
    {
        getRoutesWayPointsBetweenCordinates(origin: origin, destination: destination)
        { (routesArray) in
            
            if routesArray.count > 0
            {
                let routesN = routesArray[0] as! NSDictionary
                
                let legs = routesN["legs"] as! NSArray
                
                var newTotalDistanceInMeters : UInt = 0
                
                var newTotalDurationInSeconds : UInt = 0
                
                for leg in legs
                {
                    if let dic = leg as? NSDictionary
                    {
                        //                        newTotalDistanceInMeters += (dic["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
                        
                        let distance : NSDictionary = dic .value(forKey: "distance") as! NSDictionary
                        
                        let valueDistance : UInt = distance.value(forKey: "value") as! UInt
                        
                        let duration : NSDictionary = dic .value(forKey: "duration") as! NSDictionary
                        
                        let valueDuration : UInt = duration.value(forKey: "value") as! UInt
                        
                        newTotalDistanceInMeters += valueDistance
                        
                        newTotalDurationInSeconds += valueDuration
                    }
                }
                
                let distanceInKilometers: Double = round(Double(newTotalDistanceInMeters / 1000))
                
                let distanceInMiles = Double(newTotalDistanceInMeters) * 0.000621371
                
                let mins  = round(Double(newTotalDurationInSeconds / 60) * 100) / 100
                
                let hours = round((mins / 60) * 100) / 100
                
                let model = ETAModel()//ETA Model for passing in completion handler
                
                model.distanceInMeters = "\(newTotalDistanceInMeters)"
                
                model.distanceInKms = "\(distanceInKilometers)"
                
                model.distanceInMiles = "\(round(distanceInMiles * 100) / 100)"
                
                model.durationInSec = "\(newTotalDurationInSeconds)"
                
                model.durationInMins = "\(mins)"
                
                model.durationInHrs = "\(hours)"
                
                completionHandler(model)
            }
            else
            {
                let model = ETAModel()//ETA Model for passing in completion handler
                
                model.distanceInMeters = "0"
                
                model.distanceInKms = "0"
                
                model.distanceInMiles = "\(0)"
                
                model.durationInSec = "\(0)"
                
                model.durationInMins = "\(0)"
                
                model.durationInHrs = "\(0)"
                
                completionHandler(ETAModel())
            }
        }
    }
    
    func getETABetweenPointsConsideringTraffic(origin : CLLocationCoordinate2D, destination : CLLocationCoordinate2D,completionHandler: (_ eta : ETAModel) -> Void)
    {
        //        let key : String = Macros.ApiKeys.mapKeyGoogle
        //
        //        let originString: String = "\(origin.latitude),\(origin.longitude)"
        //
        //        let destinationString: String = "\(destination.latitude),\(destination.longitude)"
        //
        //        let directionsAPI: String = "https://maps.googleapis.com/maps/api/distancematrix/json?"
        
        //        let directionsUrlString: String = "\(directionsAPI)units=imperial&origins=\(originString)&destinations=\(destinationString)&mode=driving&departure_time=now&traffic_model=optimistic&key=\(key)"
    }
    
    /**
     To calculate the ETA
     
     - parameter routesN:           Arra of waypoints
     - parameter completionHandler: ETA Model class *With proper estimates for duration and distance.*
     */
    func calculateETA(routesN : NSDictionary, completionHandler: (_ eta :ETAModel) -> Void)
    {
        let legs = routesN["legs"] as! NSArray
        
        totalDistanceInMeters = 0
        
        totalDurationInSeconds = 0
        
        var newTotalDistanceInMeters : UInt = 0
        
        var newTotalDurationInSeconds : UInt = 0
        
        var rawDistance = String()
        var rawDuration = String()
        
        for leg in legs
        {
            if let dic = leg as? NSDictionary
            {
                //newTotalDistanceInMeters += (dic["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
                
                let distance : NSDictionary = dic .value(forKey: "distance") as! NSDictionary
                
                if let distText = distance.value(forKey: "text") as? String
                {
                    rawDistance = "\(NSLocalizedString("Distance", comment: "")) \(distText)"
                }
                
                if let valueDistance  = distance.value(forKey: "value") as? UInt
                {
                    let distMiles = Double(valueDistance) * 0.000621371
                    rawDistance = "\(NSLocalizedString("Distance", comment: "")) \(String(format: "%.2f",distMiles)) Mile"
                }
                let valueDistance : UInt  = distance.value(forKey: "value") as! UInt
                
                let duration : NSDictionary = dic .value(forKey: "duration") as! NSDictionary
                
                if let durationText = duration.value(forKey: "text") as? String
                {
                    rawDuration = "\(NSLocalizedString("Duration", comment: "")) \(durationText)"
                }
                
                let valueDuration : UInt = duration.value(forKey: "value") as! UInt
                
                newTotalDistanceInMeters += valueDistance
                
                newTotalDurationInSeconds += valueDuration
            }
        }
        
        totalDistanceInMeters = newTotalDistanceInMeters
        totalDurationInSeconds = newTotalDurationInSeconds
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        
        totalDistance = "\(NSLocalizedString("Total Distance", comment: "")) \(distanceInKilometers) Km"
        
        let mins = totalDurationInSeconds / 60
        
        let hours = mins / 60
        
        let days = hours / 24
        
        let remainingHours = hours % 24
        
        let remainingMins = mins % 60
        
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "\(NSLocalizedString("Duration", comment: "")) \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
        
        let model = ETAModel()//ETA Model for passing in completion handler
        model.distanceInMeters = "\(totalDistanceInMeters)"
        
        model.distanceInKms     = "\(round(Double(distanceInKilometers) * 100) / 100)"
        
        model.durationInSec     = "\(round(Double(totalDurationInSeconds) * 100) / 100)"
        
        model.durationInMins    = "\(round(Double(totalDurationInSeconds / 60) * 100) / 100)"
        
        model.durationInHrs     = "\(round(Double((totalDurationInSeconds / 60) / 60) * 100) / 100)"
        
        model.rawDuration = rawDuration
        model.rawDistance = rawDistance
        
        completionHandler(model)
    }
    
    //MARK:- Distance accurate
    func distanceAccurate(_ source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D,completionHandler: (_ distance : Double) -> Void)
    {
        let _ = GMSMapPointDistance(getMapPointFromCLLocationCordinate(source), getMapPointFromCLLocationCordinate(destination))
        
        let distance2 = GMSGeometryDistance(source, destination)
        
        completionHandler(distance2 * 100 * 1000)
    }
    
    func getMapPointFromCLLocationCordinate(_ cordinate : CLLocationCoordinate2D) -> GMSMapPoint
    {
        return GMSMapPoint(x: cordinate.latitude, y: cordinate.longitude)
    }
    
    /**
     zoom the camera where marker is going to place
     
     - parameter marker: Marker as input placed at a particular point on the map's surface
     */
    func takeCameraToMarker(_ marker : GMSMarker)
    {
        CATransaction.begin()
        CATransaction.setValue(Int(1.5), forKey: kCATransactionAnimationDuration)
        // YOUR CODE IN HERE
        customMapView .animate(with: GMSCameraUpdate .setTarget(marker.position, zoom:14))
        customMapView.animate(toViewingAngle: 50.0)
        customMapView.animate(toBearing: 50.0)
        
        CATransaction.commit()
    }
    
    func takeCameraToCoordinate(coordinate : CLLocationCoordinate2D, withZoom : CGFloat)
    {
        // YOUR CODE IN HERE
        customMapView .animate(with: GMSCameraUpdate .setTarget(coordinate, zoom:Float(withZoom)))
    }
    
    //MARK:- GMSCircle
    /**
     Darw the region of associated organization on google map.
     */
    func drawAssociatedRegion(_ oragizationDetail: OrganizationDetails, _ shouldZoom: Bool = false) -> OrganisationGeofenceModel
    {
        
        let lat = Double((oragizationDetail.locationLat! as NSString).doubleValue)
        let long = Double((oragizationDetail.locationLong! as NSString).doubleValue)
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let identifier = "\(oragizationDetail.organizationName!)"
        let regionRadius = Double(oragizationDetail.radius)

        let addString = oragizationDetail.address
        var finalAddress = "\(NSLocalizedString("Branch", comment: "")) \(oragizationDetail.branchName!)" + "\n"
        var counterForTwo = 0
        if(oragizationDetail.address != nil)
        {
            for componentsWord in (addString?.components(separatedBy: " "))!
            {
                if componentsWord.characters.count < 15 && finalAddress.characters.count < 35
                {
                    finalAddress.append(componentsWord + " ")

                }else if componentsWord.characters.count < 15 && counterForTwo < 3
                {
                    counterForTwo = counterForTwo + 1
                    if counterForTwo == 3
                    {
                        counterForTwo = 0
                        finalAddress.append(componentsWord + "\n")
                    }else
                    {
                        finalAddress.append(componentsWord + " ")
                    }
                }else
                {
                    counterForTwo = 0
                    finalAddress.append(componentsWord + "\n")
                }
            }
        }
        if let pnCode = oragizationDetail.pinCode
        {
            finalAddress.append("\(pnCode) ")
        }
        
        //For draw region circle.
        let circle = GMSCircle()
        circle.radius = regionRadius! // Meters
        circle.position = coordinate // Your CLLocationCoordinate2D position
        circle.strokeWidth = 3
        circle.strokeColor = Macros.Colors.orgStrokeColor
        circle.fillColor =  Macros.Colors.orgFillColor
        
        circle.map = customMapView // Add it to the map
        

        //For create marker.
        let duplicateCord = checkIfMutlipleCoordinates(latitude: Float(coordinate.latitude), longitude: Float(coordinate.longitude))

//        let mPoint = customMapView.projection .point(for: coordinate)
//        let mNewPoint = CGPoint(x: mPoint.x, y: mPoint.y + 60)
//        let coordNew = customMapView.projection .coordinate(for: mNewPoint)
        
        let organizationMarker : CustomMarker = CustomMarker()
        organizationMarker.markerID = 5
        organizationMarker.position = coordinate
        organizationMarker.coordinate = coordinate
        organizationMarker.snippet = finalAddress
        organizationMarker.title = identifier

        
        
        // Temp
        // Proper Organisation Marker
//        let embeddedView2 = MarkerTracker(frame: CGRect(x: 0, y: 0, width: 55, height: 65))
//        embeddedView2.downArrowBaseImgView.image = embeddedView2.downArrowBaseImgView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//        embeddedView2.userImage.image = #imageLiteral(resourceName: "association_org")
//        embeddedView2.downArrowBaseImgView.tintColor = Macros.Colors.yellowColor
//        embeddedView2.userImage.layer.cornerRadius = CGFloat((65 * 0.62) / 2.0)
//        embeddedView2.userImage.layer.masksToBounds = true
//        embeddedView2.userImage.layer.borderColor = Macros.Colors.yellowColor.cgColor
//        embeddedView2.userImage.layer.borderWidth = 1.0
//        
//        let pulseEffect2 = LFTPulseAnimation(repeatCount: .infinity, radius: 65, position: embeddedView2.center, ringColor: Macros.Colors.yellowColor)
//        embeddedView2.view.layer.insertSublayer(pulseEffect2, below: embeddedView2.userImage.layer)

        
        
        // Proper Organisation Marker
        let embeddedView = MarkerOrg(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        embeddedView.userImage.image = #imageLiteral(resourceName: "orgMarker")
        embeddedView.userImage.layer.masksToBounds = true

        /*let pulseEffect = LFTPulseAnimation(repeatCount: .infinity, radius: 50, position: embeddedView.center, ringColor: Macros.Colors.yellowColor)
        embeddedView.baseViewPulse.layer.insertSublayer(pulseEffect, below: embeddedView.userImage.layer)
        embeddedView.baseViewPulse.layer.masksToBounds = false*/

        /*Adding Pulsating Effect*/
        /*Pulsating Effect*/
        organizationMarker.map = customMapView
        organizationMarker.iconView = embeddedView

        
        // Fake marker
        /*Adding Pulsating Effect*/
        let mrkrSearchView = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 140))
        var centerLoc  = mrkrSearchView.center
        centerLoc.y = centerLoc.y + 40
        let pulseEffect = LFTPulseAnimation(repeatCount: .infinity, radius: 65, position: mrkrSearchView.center, ringColor: Macros.Colors.yellowColor)
        mrkrSearchView.layer.insertSublayer(pulseEffect, above: organizationMarker.iconView?.layer)

        
        let fakeMarker : CustomMarker = CustomMarker()
        fakeMarker.position = duplicateCord
        fakeMarker.markerID = 6
        fakeMarker.coordinate =  duplicateCord
        fakeMarker.iconView = mrkrSearchView
        fakeMarker.map = customMapView
        fakeMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)

        
        let modelObj = OrganisationGeofenceModel()
        modelObj.circleParam = circle
        modelObj.orgMarker = organizationMarker
        modelObj.pulsatingView = pulseEffect
        modelObj.fakeMarker = fakeMarker
        modelObj.pulsatingViewBase = mrkrSearchView
        
        //For Zoom on created region.
        if shouldZoom == true
        {
            CATransaction.begin()
            CATransaction.setValue(Int(1.0), forKey: kCATransactionAnimationDuration)
            customMapView.animate(with: GMSCameraUpdate.setTarget((circle.position), zoom: 12.0))
            CATransaction.commit()
        }

        
        // Subscribe to Branch ID.
        if Macros.Constants.organizationDetailObj != nil, let bID =  oragizationDetail.branchId, clientPubNub != nil, !clientPubNub.channels().contains("BranchId-\(bID)")
        {
            clientPubNub.subscribeToChannels(["BranchId-\(bID)"], withPresence: true)
        }
        
        return modelObj
    }
    
    func removeGeofenceFromMap(modelObj : OrganisationGeofenceModel)
    {
        modelObj.pulsatingView.removeAllAnimations()
        modelObj.pulsatingView.removeFromSuperlayer()
        modelObj.circleParam.map = nil
        modelObj.orgMarker.map = nil
        modelObj.fakeMarker.map = nil
        
        // Unsubscribe from Branch ID Channel
        if clientPubNub != nil
        {
            for channelName in clientPubNub.channels()
            {
                // alternative: not case sensitive
                if channelName.lowercased().range(of: "branchid-") != nil
                {
                    clientPubNub.unsubscribeFromChannels([channelName], withPresence: true)
                }
            }
        }
    }

    
    //MARK:- Google map delegates
    
    /**
     This function will provide information that where the marker tap
     
     - parameter position: GMSMapView as map's surface & GMSMarker placed at a particular point on the map's surface
     */
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        delegate?.mapViewMarkerTapped!(mapView, marker: marker)
        return false
    }
    
    /**
     * Called when the marker's info window is closed.
     */
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker)
    {
        
        delegate?.mapViewMarkerInfoSnippetDidClose!()
    }
    
    /**
     Called when the marker's info window is open.
     */
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?
    {

        delegate?.mapViewMarkerInfoSnippetDidOpen!()
        return nil
    }
    
    /**
     * Called when the marker's info window is tapped.
     */
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)
    {
        var message = ""
        
        if ((marker as! CustomMarker).markerID != nil && (marker as! CustomMarker).markerID == 2)
        {
            message =  marker.snippet!
        }else
        {
            message =  marker.title!
        }
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool
    {
        if  UserDefault.sharedInstance.getUserLastCurrentLocationLat() == nil
        {
            return false
        }
        
        let latRetrv : Double = Double(UserDefault.sharedInstance.getUserLastCurrentLocationLat())!
        
        let longRetrv : Double = Double(UserDefault.sharedInstance.getUserLastCurrentLocationLong())!
        
        CATransaction.begin()
        CATransaction.setValue(Int(1.5), forKey: kCATransactionAnimationDuration)
        // YOUR CODE IN HERE
        customMapView .animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(latRetrv, longRetrv), zoom: 18.0))
        
        CATransaction.commit()
        
        if CLLocationManager.locationServicesEnabled()
        {
            switch CLLocationManager.authorizationStatus()
            {
            case .notDetermined:
                
                break
            case .authorizedWhenInUse:
                
                break
            case .authorizedAlways:
                
                break
            case .restricted:
                // restricted by e.g. parental controls. User can't enable Location Services
                Singleton.sharedInstance.showLocationAlert(self, title: nil, message: nil)
                break
            case .denied:
                // user denied your app access to Location Services, but can grant access from Settings.app
                Singleton.sharedInstance.showLocationAlert(self, title: nil, message: nil)
                break
            }
        }else {
            Singleton.sharedInstance.showLocationAlert(self, title: nil, message: nil)
        }
        
        if  UserDefault.sharedInstance.getUserLastCurrentLocationLat() == nil
        {
            return false
        }
        
        let lat : Double = Double(UserDefault.sharedInstance.getUserLastCurrentLocationLat())!
        
        let long : Double = Double(UserDefault.sharedInstance.getUserLastCurrentLocationLong())!
        
        customMapView .animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(lat, long), zoom: 13.0))
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        delegate?.mapViewCordinateTap!(mapView, cordinate: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D)
    {
        delegate?.mapViewCordinateLongPress!(mapView, cordinate: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
    {
        if gesture == true
        {
            delegate?.mapViewDidDrageed!(mapView, marker: nil)
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        delegate?.idleMapViewAt!(mapView, idleAt: position)
    }
}

//MARK:- Enum
/**
 Map types , mainly during the initialisation of the class.
 
 - pinDrop:    When we just want to drop a source pin.
 - routeDraw:  When we want to draw route after plotting the pin
 - currentLoc: When we have to load the map without any pin or route.
 */

enum MAPTYPE
{
    case pinDrop
    
    case routeDraw
    
    case currentLoc
}

//MARK:- ETA Model
/// Model class of Estimated duration & distance between the two cordinates

class ETAModel: NSObject
{
    override init()
    {
        
    }
    var durationInSec       = String()
    
    var durationInMins      = String()
    
    var durationInHrs       = String()
    
    var distanceInKms       = String()
    
    var distanceInMeters    = String()
    
    var distanceInMiles     = String()
    
    var rawDistance         = String()
    
    var rawDuration         = String()
}

//MARK:- Address  Model ReverseGeo
/// Model class to store the address and sub locality which we get from the reverse geo location.

class AddressModel: NSObject
{
    override init()
    {
        
    }
    var address   = String()
    
    var subLocal  = String()
}


//MARK:- CustomMarker GMSMarker
/// Subclass of GMSMarker to assign customize image and cordinate.

class CustomMarker: GMSMarker
{
    override init()
    {
        
    }
    var coordinate  : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var customImage : UIImage!
    
    var markerID : Int!
    
}

//MARK:- UIColor Extensions
extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        assert(red >= 0 && red <= 255, "Invalid red component")
        
        assert(green >= 0 && green <= 255, "Invalid green component")
        
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int)
    {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

//Initialise google map
//func addMapToView()
//{
//    if objGMVC == nil
//    {
//        objGMVC = GoogleMapViewController()
//        objGMVC.showCurrentLoc = true
//        objGMVC.mapType = .currentLoc
//        objGMVC.currentLoc = CLLocationCoordinate2DMake(Macros.Constants.userCurrentLat, Macros.Constants.userCurrentLong)
//        objGMVC.view.frame = mapBaseTracking.bounds
//        objGMVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        objGMVC.customMapView.padding = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
//        self.addChildViewController(objGMVC)
//        self.mapBaseTracking.addSubview(self.objGMVC.view)
//        objGMVC.delegate = self
//    }
//}

//Add Marker
//func createMarkerAtLoc(_ loc : CLLocationCoordinate2D, model : FamilyListModel)
//{
//    checkAndDeleteExistingMarkerForModel(model: model)
//    // Annotation Placer
//    let marker = CustomMarker()
//
//    let embeddedView = MarkerTracker(frame: CGRect(x: 0, y: 0, width: 55, height: 65))
//    embeddedView.downArrowBaseImgView.image = embeddedView.downArrowBaseImgView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//    embeddedView.userImage.imageFromUrl(model.imgURL, placeHolderImage: UIImage(named: "defaultUser"), shouldResize: true, showActivity: true)
//    embeddedView.downArrowBaseImgView.tintColor = Macros.Colors.yellowColor
//    embeddedView.userImage.layer.cornerRadius = CGFloat((65 * 0.62) / 2.0)
//    embeddedView.userImage.layer.masksToBounds = true
//    embeddedView.userImage.layer.borderColor = Macros.Colors.yellowColor.cgColor
//    embeddedView.userImage.layer.borderWidth = 1.0
//
//    if model.isPeerTrackable == false
//    {
//        let locCord =  CLLocationCoordinate2DMake(Double(model.lastLocationLat)! , Double(model.lastLocationLong)!)
//
//        marker.coordinate = locCord
//        marker.position = locCord
//
//    }else
//    {
//        marker.coordinate = loc
//        marker.position = loc
//    }
//    model.marker = marker
//    marker.iconView = embeddedView // Adding Xib View to base view.
//
//    self.objGMVC.placePinAtCoordinateWithTrackerUserName(marker, mapView: self.objGMVC.customMapView, name: model.name)
//}

//NAVIGATE on Google map with location name
//if Singleton.sharedInstance.schemeAvailable("comgooglemaps://")
//{
//    if marker_Lat != nil && marker_Long != nil
//    {
//        UIApplication.shared.openURL(URL(string:
//            "comgooglemaps://?saddr=\(Macros.Constants.userCurrentLat!),\(Macros.Constants.userCurrentLong!)&daddr=\(marker_Lat!),\(marker_Long!)&directionsmode=driving")!)
//    }
//}

