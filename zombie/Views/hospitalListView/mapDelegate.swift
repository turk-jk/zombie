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
        if tableSelection{
            tableSelection = false
            return
        }
        if let annotation = view.annotation,
            let objects = fetchedResultController.objects(),
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
}

