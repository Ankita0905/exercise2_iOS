//
//  ViewController.swift
//  exercise2_iOS
//
//  Created by Ankita Jain on 2020-01-10.
//  Copyright © 2020 Ankita Jain. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    var locationManager = CLLocationManager()
    var desireCoordinate: CLLocationCoordinate2D!
    var locatepins: [CLLocationCoordinate2D] = []
    var pin : Int = 0
    var distance = [Double]()
    var screen = [CGPoint]()
    @IBOutlet weak var mapView: MKMapView!
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set latitude na d longitude
        let latitude:CLLocationDegrees = 43.64
        let longitude:CLLocationDegrees = -79.38
        
        //set delta longitude and latitude
        let latDelta:CLLocationDegrees = 0.05
        let longDelta:CLLocationDegrees = 0.05
        
        //set the span
        let span=MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        //set the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //set the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        //set the region on map
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        adddoubleTap()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let latDelta : CLLocationDegrees = 0.05
        let lonDelta : CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
            }
        

    @IBAction func btnRoute(_ sender: Any) {
        cal(sourcePlaceMark: MKPlacemark(coordinate: locatepins[0]), destinationPlacMark: MKPlacemark(coordinate: locatepins[1]))
        
        
        
        cal(sourcePlaceMark: MKPlacemark(coordinate: locatepins[1]), destinationPlacMark: MKPlacemark(coordinate: locatepins[2]))
        
        
        
        cal(sourcePlaceMark: MKPlacemark(coordinate: locatepins[2]), destinationPlacMark: MKPlacemark(coordinate: locatepins[0]))
        
    }
    
        func cal(sourcePlaceMark: MKPlacemark , destinationPlacMark: MKPlacemark){
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                directionRequest.destination = MKMapItem(placemark: destinationPlacMark)
                directionRequest.transportType = .automobile
                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let directionResponse = response else {
                        if let error = error {
                            print("We have error getting directions, \(error.localizedDescription)")
                        }
                        return
                    }
                    let route = directionResponse.routes[0]
                    let distance = route.distance
                    self.distance.append(distance)
                    print(distance)
                    if self.distance.count == 3{
                        print(self.distance[0])
                        let label1: UILabel = UILabel(frame: CGRect(x: ((self.screen[0].x + self.screen[1].x - 80)/2), y: ((self.screen[0].y + self.screen[1].y)/2), width: 120, height: 30))
                        label1.text = "\(self.distance[0]) m"
                        self.mapView.addSubview(label1)
                        let label2: UILabel = UILabel(frame: CGRect(x: ((self.screen[1].x + self.screen[2].x - 80)/2), y: ((self.screen[1].y + self.screen[2].y)/2), width: 120, height: 30))

                        label2.text = "\(self.distance[1]) m"
                            self.mapView.addSubview(label2)
                            let label3: UILabel = UILabel(frame: CGRect(x: ((self.screen[2].x + self.screen[0].x - 80)/2), y: ((self.screen[2].y + self.screen[0].y)/2), width: 120, height: 30))

                        label3.text = "\(self.distance[2]) m"

                        self.mapView.addSubview(label3)
                    }
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
       
                }
                
            }
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                if overlay is MKPolyline{
                    let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
                    renderer.strokeColor = UIColor.orange
                    renderer.lineWidth = 3
                    return renderer
                    }
               
                else if overlay is MKPolygon {
                    let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                    renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
                    renderer.strokeColor = UIColor.green
                    renderer.lineWidth = 2
                    return renderer
                }
                return MKOverlayRenderer()
            }
           
        }

        extension ViewController : UIGestureRecognizerDelegate, MKMapViewDelegate {
            func adddoubleTap() {
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
                doubleTap.numberOfTapsRequired = 2
                doubleTap.delegate = self
                mapView.addGestureRecognizer(doubleTap)
                    }
         
            @objc func dropPin(sender: UITapGestureRecognizer) {

                pin = pin + 1
                mapView.removeOverlays(mapView.overlays)
                let touchPoint = sender.location(in: mapView)
                screen.append(touchPoint)
                let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                let annotation = Pin(coordinate: coordinate, identifier: "pin")
                mapView.addAnnotation(annotation)
                locatepins.append(coordinate)
                
                if(pin == 3){
                  let routeLine1 = MKPolyline(coordinates: [locatepins[0],locatepins[1]], count: 2)
                    let routeLine2 = MKPolyline(coordinates: [locatepins[1],locatepins[2]], count: 2)
                    let routeLine3 = MKPolyline(coordinates: [locatepins[2],locatepins[0]], count: 2)
                    let show = MKPolygon(coordinates: locatepins, count: 3)
                    self.mapView.addOverlay(routeLine1)
                    self.mapView.addOverlay(routeLine2)
                    self.mapView.addOverlay(routeLine3)
                    self.mapView.addOverlay(show)
                    }
                else{
                    
                
                    
                }
              
             
                desireCoordinate = coordinate
                
            }

            func removePin() {
             for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
                    }
                
            }
            
            func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                if annotation is MKUserLocation {
                    return nil
                    }
                let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                pinAnnotation.animatesDrop = true
                return pinAnnotation
                
            }
          }




