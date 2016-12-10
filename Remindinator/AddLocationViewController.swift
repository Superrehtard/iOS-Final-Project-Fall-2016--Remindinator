//
//  AddLocationViewController.swift
//  Remindinator
//
//  Created by Pruthvi Parne on 12/9/16.
//  Copyright © 2016 Parne,Pruthivi R. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

protocol AddLocationViewControllerDelegate {
    func addLocationViewControllerDidCancel(controller: AddLocationViewController)
    
    func addLocationViewController(controller: AddLocationViewController, didFinishAddingLocation placemark: MKPlacemark)
}

class AddLocationViewController: UIViewController {
    
    var resultSearchController: UISearchController!
    var selectedPin:MKPlacemark!
    var delegate:AddLocationViewControllerDelegate?
    
    var locationManager:CLLocationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = self.mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done",style: .Plain, target: self, action: #selector(cancelAddingLocation))
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    func addLocationToEvent() {
        if self.selectedPin != nil {
            self.delegate?.addLocationViewController(self, didFinishAddingLocation: selectedPin)
        }
    }
    
    func cancelAddingLocation() {
        self.delegate?.addLocationViewControllerDidCancel(self)
    }

}

extension AddLocationViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

extension AddLocationViewController : HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        self.selectedPin = placemark
        
        // clear any existing annotations, so that the map isn't cluttered with other pin's.
        self.mapView.removeAnnotations(mapView.annotations)
        
        // Create a new annotation with placemark details
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension AddLocationViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.magentaColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "AddLocation-30"), forState: .Normal)
        button.addTarget(self, action: #selector(AddLocationViewController.addLocationToEvent), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

