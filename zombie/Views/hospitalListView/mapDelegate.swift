//
//  mapDelegate.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import MapKit

extension hospialListViewController: MKMapViewDelegate{
    func addAnnotation() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        if let objects = fetchedResultController.objects(){
            
            let annotations = objects.map { (object) -> MKPointAnnotation in
                let loc = CLLocationCoordinate2D(latitude: object.hospital.lat, longitude: object.hospital.lng)
                var subtitle: String? = nil
                if self.calculateTransport{
                    switch self.selectedMode {
                    case .driving:
                        subtitle = "\(object.waitingTime_drivingETA ) mins"
                    case .walking:
                    subtitle = "\(object.waitingTime_walkingETA ) mins"

                    case .bicycling:
                    subtitle = "\(object.waitingTime_bicyclingETA ) mins"

                    case .transit:
                    subtitle = "\(object.waitingTime_transitETA ) mins"
                    }
                }else{
                    subtitle = "\(object.waitingTime ) mins"
                }
                let annotation = MKPointAnnotation(__coordinate: loc, title: object.hospital.name, subtitle: subtitle)
//                annotation.coordinate = loc
                return annotation
            }
            
            mapView.addAnnotations(annotations)
            mapView.showAnnotations(annotations, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        vibeIt(.light)
        self.mapRoute = nil
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        vibeIt(.light)
        print("mapView didSelect")
        guard let annotation = view.annotation else {
            print("no annotation")
            return
        }

        //find route
        let mode = transportMode.init(number: self.selectedSegmentIndex).transportType
        if self.calculateTransport, let mode = mode{
            print("transportType")
            API.AppleETA(source: mapView.userLocation.coordinate, destination: annotation.coordinate, mode: mode)
                .calculate { (route, error) in
                    if let error = error {
                        print("error: ",error.localizedDescription)
                        
                    }else if let route = route {
                        self.mapRoute = route
                    }
            }
        }else{
            
            // Change camera postion if there is no routing or calculateTransport mode is NOT activated
            self.mapView.showAnnotations([annotation], animated: true)
            let region = MKCoordinateRegion( center: annotation.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
        
        if tableSelection{
            tableSelection = false
            return
        }
        if let objects = fetchedResultController.objects(),
            let index = objects.firstIndex(where: {$0.hospital.name == annotation.title}){
            UIView.animate(withDuration: 0.7) {
                self.mapView.centerCoordinate = annotation.coordinate
            }
            
            let indexpath = IndexPath(item: index, section: 0)
            tableView.selectRow(at:indexpath , animated: true, scrollPosition: .middle)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.tableView.deselectRow(at: indexpath, animated: true)
            }
        }
    }
    func updateMap(with mapRoute: MKRoute?, oldMapRoute: MKRoute?) {
        let padding: CGFloat = 100
        
        if let oldMapRoute = oldMapRoute{
            mapView.removeOverlays([oldMapRoute.polyline])
        }
        
        if let mapRoute = mapRoute{
            mapView.addOverlay(mapRoute.polyline)
            mapView.setVisibleMapRect(
                mapRoute.polyline.boundingMapRect.union(
                    mapRoute.polyline.boundingMapRect
                ),
                edgePadding: UIEdgeInsets(
                    top: padding,
                    left: padding,
                    bottom: padding,
                    right: padding
                ),
                animated: true
            )
        }
        
       
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if type(of: overlay) == MKPolygon.self{
            let renderer = MKPolygonRenderer(overlay: overlay)
            
            renderer.fillColor = UIColor.magenta.withAlphaComponent(0.4)
            return renderer
        }else{

            let renderer = MKPolylineRenderer(overlay: overlay)

            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 3

            return renderer
        }
    }
}

extension String{
    var lat: Double{
        let latLng = self.split(separator: ",")
        let lat: Double = Double(latLng[0]) ?? 0
        return lat
    }
    var lng: Double{
        let latLng = self.split(separator: ",")
        let lng: Double = Double(latLng[1]) ?? 0
        return lng
    }
    var location: (Double, Double){
        return (lat, lng)
    }
}
extension Double{
    init(_ str: String) {
        self.init(str)!
    }
}
extension CLLocationCoordinate2D{
    init(_ str: String) {
        let latLng = str.split(separator: ",")
        let lat = CLLocationDegrees( Double(latLng[0]) ?? 0)
        let lng = CLLocationDegrees( Double(latLng[1]) ?? 0)
        self.init(latitude: lat, longitude: lng)
    }
}
