//
//  mapDelegate.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation

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
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("mapView didSelect")
        guard let annotation = view.annotation else {
            print("no annotation")
            return
        }

        //find route
        if self.calculateTransport, let mode = transportMode.init(number: self.selectedSegmentIndex).transportType{
            print("transportType")
            API.AppleETA(source: mapView.userLocation.coordinate, destination: annotation.coordinate, mode: mode)
                .calculate { (route, error) in
                    if let error = error{
                        print("error: ",error.localizedDescription)
                    }else if let route = route {
                        self.updateMap(with: route)
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
    func updateMap(with mapRoute: MKRoute) {
        let padding: CGFloat = 100
        mapView.removeOverlays(self.mapView.overlays)
        mapView.addOverlay(mapRoute.polyline)
        
//        let rect = mapRoute.polyline.boundingMapRect
//        self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//        mapView.visibleMapRect.union(<#T##rect2: MKMapRect##MKMapRect#>)
//        mapRoute.polyline.boundingMapRect.union(<#T##rect2: MKMapRect##MKMapRect#>)
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3

        return renderer
    }
}

