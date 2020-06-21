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
        var tutorials_Done = UserDefaults.standard.array(forKey: st.tutorial.s) as? [String] ?? [String]()
        print("tutorials_Done \(tutorials_Done)")
        let tutorials_toDo = Tutorial.allCases.map{$0.str}
        let tutorials_NotDoneYet = Array(Set(tutorials_toDo).subtracting(Set(tutorials_Done)))
        print("tutorials_NotDoneYet \(tutorials_NotDoneYet)")
        if let nextToDo = tutorials_NotDoneYet.first, let tutorial = Tutorial.init(str: nextToDo){
            let view = viewForTutorial(type: tutorial)
            let message = tutorial.message
            let action = actionForTutorial(type: tutorial)
            showMessage(onView: view, message: message,action: {
                // do the action
                action()
                
                // add the tutorial type to the done list
                tutorials_Done.append(tutorial.str)
                UserDefaults.standard.set(tutorials_Done, forKey: st.tutorial.s)
                UserDefaults.standard.synchronize()
                
                // call showTutorial()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.showTutorial()
                }
            })
        }
        
        
    }
    enum Tutorial: CaseIterable {
        case toggleMap, ETA, transportMode, refresh
        
        var order: Int{
            switch self {
            case .toggleMap: return     0
            case .ETA: return           1
            case .transportMode: return 2
            case .refresh: return       3
                
            }
        }
        var str : String{
            switch self {
            case .toggleMap: return     st.tutorial_toggleMap.s
            case .ETA: return           st.tutorial_ETA.s
            case .transportMode: return st.tutorial_transportMode.s
            case .refresh: return       st.tutorial_refresh.s
                
            }
        }
        
        var message : String{
            switch self {
            case .toggleMap: return     "Press here to show the map"
            case .ETA: return           "Press here to calculate ETA to the hospital"
            case .transportMode: return "Press here to change the transport mode"
            case .refresh: return       "Press here to refresh the data"
                
            }
        }
        
        init?(str : String){
            switch str {
            case st.tutorial_refresh.s: self = .refresh
            case st.tutorial_toggleMap.s: self = .toggleMap
            case st.tutorial_ETA.s: self = .ETA
            case st.tutorial_transportMode.s: self = .transportMode
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
            
        }
    }
    
    func actionForTutorial(type: Tutorial) -> ()-> () {
        switch type {
        case .refresh:
            return {
                print("actionForTutorial \(type.str)")
                self.refreshList()
            }
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
        case .transportMode:
            return {
                print("actionForTutorial \(type.str)")
                self.transportModeChanged(self.segmentTransportMode)
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
        
        let point = CGPoint(x: onView.frame.minX, y: onView.bounds.maxY )
        let pointTo = onView.convert(point, to: self.view)
        popOver.show(v, point: pointTo)
    }
}
