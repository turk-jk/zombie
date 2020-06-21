//
//  Tutorial.swift
//  zombie
//
//  Created by yacob jamal kazal on 22/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
extension hospialListViewController{
    
    func showTutorial() {
        let _tutorials_Done = UserDefaults.standard.array(forKey: st.tutorial.s) as? [String] ?? [String]() 
        var tutorials_Done = _tutorials_Done.map{Tutorial.init(str: $0)!}
        var tutorials_NotDoneYet = Array(Set(Tutorial.allCases).subtracting(Set(tutorials_Done)))
        tutorials_NotDoneYet.sort { (first, sec) -> Bool in
            return first.order < sec.order
        }
        if let nextToDo = tutorials_NotDoneYet.first{
            let view = viewForTutorial(type: nextToDo)
            let message = nextToDo.message
            let action = actionForTutorial(type: nextToDo)
            showMessage(onView: view, message: message,action: {
                // do the action
                action()
                
                // add the tutorial type to the done list
                tutorials_Done.append(nextToDo)
                let str = tutorials_Done.map{$0.str}
                UserDefaults.standard.set(str, forKey: st.tutorial.s)
                UserDefaults.standard.synchronize()
                
                // call showTutorial()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.showTutorial()
                }
            })
        }
        
        
    }
    enum Tutorial: CaseIterable {
        case toggleMap
        case ETA
        case showRoute
        case transportMode
        case refresh
        
        var order: Int{
            switch self {
            case .toggleMap: return     0
            case .ETA: return           1
            case .showRoute: return     2
            case .transportMode: return 3
            case .refresh: return       4
                
            }
        }
        var str : String{
            switch self {
            case .toggleMap: return     st.tutorial_toggleMap.s
            case .ETA: return           st.tutorial_ETA.s
            case .showRoute: return     st.tutorial_showRoute.s
            case .transportMode: return st.tutorial_transportMode.s
            case .refresh: return       st.tutorial_refresh.s
                
            }
        }
        
        var message : String{
            switch self {
            case .toggleMap: return     "Press here to show the map"
            case .ETA: return           "toggle the switch to calculate ETA to the hospital"
            case .showRoute: return     "Press on first Hospital to show the route on map"
            case .transportMode: return "Press here to change the transport mode"
            case .refresh: return       "Press here to refresh the data"
                
            }
        }
        
        init?(str : String){
            switch str {
            case st.tutorial_toggleMap.s: self = .toggleMap
            case st.tutorial_ETA.s: self = .ETA
            case st.tutorial_showRoute.s: self = .showRoute
            case st.tutorial_transportMode.s: self = .transportMode
            case st.tutorial_refresh.s: self = .refresh
            default:
                return nil
            }
        }
    }
    func viewForTutorial(type: Tutorial) -> UIView {
        switch type {
        case .refresh:
            return refreshBarItem.value(forKey: "view") as! UIView
        case .toggleMap:
            return toggleMapBarItem.value(forKey: "view") as! UIView
        case .ETA:
            return switchtransport
        case .transportMode:
            return segmentTransportMode
            
        case .showRoute:
            return self.tableView.visibleCells.first!
        }
    }
    
    func actionForTutorial(type: Tutorial) -> ()-> () {
        switch type {
        case .toggleMap:
            return {
                print("actionForTutorial \(type.str)")
                self.toggleMapPressed()
            }
        case .ETA:
            return {
                print("actionForTutorial \(type.str)")
                self.switchtransport.isOn = !self.switchtransport.isOn
                self.calculateETAChanged(self.switchtransport)
            }
        case .showRoute:
            return {
                print("actionForTutorial \(type.str)")
                let indexPath = IndexPath(item: 0, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                let obj = self.fetchedResultController.object(at: indexPath)

                guard let annotation = self.mapView.annotations.first (where: { (annotation) -> Bool in
                    return obj.hospital.name == annotation.title
                }) else{
                    print("Couldn't find annotation")
                    return
                }
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        case .transportMode:
            return {
                print("actionForTutorial \(type.str)")
                self.selectedSegmentIndex = 1
                self.segmentTransportMode.selectedSegmentIndex = self.selectedSegmentIndex
                self.transportModeChanged(self.segmentTransportMode)
            }
        case .refresh:
            return {
                print("actionForTutorial \(type.str)")
                self.refreshList()
            }
            
        }
    }
    func showMessage(onView: UIView, message: String, action : ( ()->())? = nil) {
        let popOver = Popover(showHandler: {
            
        }) {
            action?()
        }
        
        let v = UILabel()
        v.text = message
        v.sizeToFit()
        v.textColor = .red
        v.textAlignment = .center
        
        var frame = v.frame
        frame.size = CGSize(width: frame.size.width + 10, height: frame.size.height + 10)
        v.frame = frame
        
        let point = CGPoint(x: onView.frame.minX + 10, y: onView.bounds.maxY )
        let pointTo = onView.superview!.convert(point, to: self.view)
        popOver.show(v, point: pointTo)
    }
}
