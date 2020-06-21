//
//  vibers.swift
//  zombie
//
//  Created by yacob jamal kazal on 22/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

public enum viberType {
    case soft
    case light
    case medium
    case heavy
    case Changed
    case error
    case success
    case warning
    case none
}
public func vibeIt(_ level : viberType = .medium)  {
    DispatchQueue.main.async {
        vibeItOnMain(level)
    }
}
fileprivate func vibeItOnMain(_ level : viberType)  {
    
    if #available(iOS 10.0, *) {
        
        switch level {
        case .light:
            let g = UIImpactFeedbackGenerator(style: .light)
            g.impactOccurred()
        case .medium:
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.impactOccurred()
        case .heavy:
            let g = UIImpactFeedbackGenerator(style: .heavy)
            g.impactOccurred()
        case .Changed:
            let g = UISelectionFeedbackGenerator()
            g.selectionChanged()
        case .error:
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.error)
        case .success:
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.success)
        case .warning:
            let g = UINotificationFeedbackGenerator()
            g.notificationOccurred(.warning)
        case .none:
            break
        case .soft:
            if #available(iOS 13.0, *) {
                let g = UIImpactFeedbackGenerator(style: .soft)
                g.impactOccurred()
            } else {
                // Fallback on earlier versions
                vibeItOnMain(.light)
            }
        }
    } else {
        // Fallback on earlier versions
        AudioServicesPlaySystemSound(1519)
    }
    
    
}
