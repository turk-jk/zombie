//
//  hospitalCell.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import EasyPeasy

class hospitalCell: UITableViewCell {
    var calculateTransport = false{
        didSet{
            transportlabel.isHidden = !calculateTransport
            transportlabel2.isHidden = !calculateTransport
        }
    }
    var selectedMode = transportMode.driving
    
    var object: WaitingItem! {
        didSet{
            let waitingTime = object.waitingTime
            self.hospitalNameLabel.text = object.hospital.name
            self.timeLabel.text = "\(waitingTime) mins"
            
            if calculateTransport{
                self.timeLabel.font = .systemFont(ofSize: 13)
                let (transportAttrStr, transportAttrStr2) = self.transportAttrStr(selectedMode: selectedMode, object: object)
                self.transportlabel.attributedText = transportAttrStr
                
                self.transportlabel2.attributedText = transportAttrStr2
            }else{
                self.timeLabel.font = .boldSystemFont(ofSize: 17)
                transportlabel.text = nil
                transportlabel2.text = nil
            }
        }
    }
    func transportAttrStr(selectedMode: transportMode, object: WaitingItem) -> (NSMutableAttributedString,NSMutableAttributedString) {
        
        let fullString = NSMutableAttributedString()
        
        // create our NSTextAttachment
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = selectedMode.fillImage.withTintColor(.mainColor)
        
        // wrap the attachment in its own attributed string so we can append it
        let image1String = NSAttributedString(attachment: image1Attachment)
        
        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(image1String)
        
        var eta = 0
        var dis = 0
        switch self.selectedMode {
        case .driving:
            eta = object.hospital.drivingETA
            dis = object.drivingDis
        case .walking:
            eta = object.hospital.walkingETA
            dis = object.walkingDis
        case .bicycling:
            eta  = object.hospital.bicyclingETA
            dis = object.bicyclingDis
        case .transit:
            eta = object.hospital.transitETA
            dis = object.transitDis
        }
        
        

        var str = ""
        var str2 = ""
        if eta == 0{
            str = "⚠️ N/A"
            str2 = "Total: -- mins  "
        }else{
            str = "  \(eta) mins \(dis) km"
            str2 = "Total: \(object.waitingTime + eta) mins  "
        }
        
        fullString.append(NSAttributedString(string: str,
            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                         NSAttributedString.Key.baselineOffset: 5]))
        let fullString2 = NSMutableAttributedString()
       fullString2.append(NSAttributedString(string: str2,
                  attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15),
                               NSAttributedString.Key.foregroundColor: UIColor.mainColor]))
        
        return (fullString, fullString2)
        
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addSubview(transportView)
        addSubview(mainView)
        
        mainView.addSubview(hospitalNameLabel)
        mainView.addSubview(waitStrLabel)
        mainView.addSubview(timeLabel)
        
        transportView.addSubview(transportlabel)
        transportView.addSubview(transportlabel2)
        transportlabel.isHidden = !calculateTransport
        transportlabel2.isHidden = !calculateTransport

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.easy.layout(
            Top(8)
            ,Left(16)
            ,Right(16)
            ,Height(50)
        )
        transportView.easy.layout(
            Right(10).to(mainView, .right)
            ,Left(10).to(mainView, .left)
            ,Top(-10).to(mainView, .bottom)
            ,Height(10).when{!self.calculateTransport}
            ,Height(40).when{self.calculateTransport}
            ,Bottom(8)
        )
        transportlabel.easy.layout(
            CenterY(5)
            ,Left(8)
        )
        transportlabel2.easy.layout(
            CenterY(5)
            ,Right(8)
            ,Left(8).to(transportlabel, .right)
        )
        hospitalNameLabel.easy.layout(
            CenterY()
            ,Right(8).to(waitStrLabel, .left)
            ,Left(16)
        )
        waitStrLabel.easy.layout(
            CenterY()
            ,Right(8).to(timeLabel, .left)
            ,Width(50)
        )
        timeLabel.easy.layout(
            CenterY()
            ,Right(8)
            ,Width(50)
        )
    }
    lazy var mainView : UIView = {
        let v = UIView()
        v.backgroundColor = .baseBackGround
        v.layer.cornerRadius = 10
        return v
    }()
    lazy var transportView : UIView = {
        let v = UIView()
        v.backgroundColor = .backGroundColor
        v.layer.cornerRadius = 5
        return v
    }()
    lazy var transportlabel : UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13)
        v.textAlignment = .left
        
        return v
    }()
    
    lazy var transportlabel2 : UILabel = {
        let v = UILabel()
        v.textAlignment = .right
        return v
    }()
    
    lazy var hospitalNameLabel : UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        return v
    }()
    
    lazy var waitStrLabel : UILabel = {
        let v = UILabel()
        v.textColor = .systemGray
        v.numberOfLines = 1
        v.adjustsFontSizeToFitWidth = true
        v.text = "wait time:"
        return v
    }()
    
    lazy var timeLabel : UILabel = {
        let v = UILabel()
        v.textColor = .mainColor
        v.numberOfLines = 1
        v.adjustsFontSizeToFitWidth = true
        v.text = "8 mins"
        return v
    }()
}
