//
//  illnessCell.swift
//  zombie
//
//  Created by yacob jamal kazal on 21/6/20.
//  Copyright © 2020 yacob jamal kazal. All rights reserved.
//

import UIKit
import EasyPeasy
protocol illnessDelgate: class{
    func reportIllness(at index: Int, illnessName: String, levelOfPain: Int)
}
class illnessCell: UITableViewCell {
    
    // MARK: - public
    weak var delegate: illnessDelgate?
    var illnessName = ""{
        didSet{
            illnessNameLabel.text = illnessName
        }
    }
    var showPainLevel = false{
        didSet{
            stack.isHidden = !showPainLevel
            painLevelLabel.isHidden = !showPainLevel
            disclosureIndicator.isHidden = showPainLevel
            if showPainLevel{
                painLevelLabel.text = "Select severity Level:"
            }else{
                painLevelLabel.text = nil
            }
        }
    }
    
    // MARK: -
    private let painButtonWidth: CGFloat = 40
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        addSubview(painLevelView)
        addSubview(mainView)
        mainView.addSubview(disclosureIndicator)
        mainView.addSubview(illnessNameLabel)
        
        painLevelView.addSubview(painLevelLabel)
        painLevelView.addSubview(stack)
        painLevelLabel.isHidden = !showPainLevel
        stack.isHidden = !showPainLevel
        
        
        _ = painButtons.map{$0.addTarget(self, action: #selector(painLevelButtonPressed(_:)), for: .touchUpInside)}
        _ = painButtons.map({
            $0.layer.cornerRadius = painButtonWidth / 2
//            $0.backgroundColor = .white
            $0.imageView?.contentMode = .scaleAspectFit
        })
    }
    
    @objc private func painLevelButtonPressed(_ sender : UIButton) {
        delegate?.reportIllness(at: self.tag, illnessName: illnessName, levelOfPain: sender.tag)
    }
    
    // MARK: - layout
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.easy.layout(
            Top(8)
            ,Left(16)
            ,Right(16)
            ,Height(50)
        )
        painLevelView.easy.layout(
            Right(10).to(mainView, .right)
            ,Left(10).to(mainView, .left)
            ,Top(-5).to(mainView, .bottom)
            ,Height(5).when{!self.showPainLevel}
            ,Height(80).when{self.showPainLevel}
            ,Bottom(8)
        )
        painLevelLabel.easy.layout(
            Top(10)
            ,Right(8)
            ,Left(8)
        )
        stack.easy.layout(
            Top(5).to(painLevelLabel, .bottom)
            ,Height(painButtonWidth)
            ,Right(16)
            ,Left(16)
        )
        disclosureIndicator.easy.layout(
            CenterY()
            ,Right(8)
            ,Height(*0.5).like(mainView, .height)
            ,Width().like(disclosureIndicator, .height)
        )
        illnessNameLabel.easy.layout(
            CenterY()
            ,Right(8).to(disclosureIndicator, .left)
            ,Left(16)
        )
        
    }
    // MARK: - Views
    private lazy var mainView : UIView = {
        let v = UIView()
        v.backgroundColor = .baseBackGround
        v.layer.cornerRadius = 10
        return v
    }()
    private lazy var painLevelView : UIView = {
        let v = UIView()
        v.backgroundColor =  .backGroundColor
        v.layer.cornerRadius = 5
        
        return v
    }()
    private lazy var painLevelLabel : UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13)
        return v
    }()
    
    private lazy var illnessNameLabel : UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        return v
    }()
    
    private lazy var disclosureIndicator : UIImageView = {
        let v = UIImageView()
        v.image = #imageLiteral(resourceName: "icons8-circled_chevron_right-40").withTintColor(.mainColor)
        v.contentMode = .scaleAspectFit
        return v
    }()
    private lazy var painLevel_0_Button : UIButton = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "happy-40").withTintColor(.pain_0), for: .normal)
        v.tag = 0
        return v
    }()
    private lazy var painLevel_1_Button : UIButton = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "boring-40").withTintColor(.pain_1), for: .normal)
        v.tag = 1
        return v
    }()
    private lazy var painLevel_2_Button : UIButton = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "sad-40").withTintColor(.pain_2), for: .normal)
        v.tag = 2
        return v
    }()
    private lazy var painLevel_3_Button : UIButton = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "tired-40").withTintColor(.pain_3), for: .normal)
        v.tag = 3
        return v
    }()
    private lazy var painLevel_4_Button : UIButton = {
        let v = UIButton()
        v.setImage(#imageLiteral(resourceName: "pain-40").withTintColor(.pain_4), for: .normal)
        v.tag = 4
        return v
    }()
    private lazy var painButtons = [painLevel_0_Button,
                            painLevel_1_Button,
                            painLevel_2_Button,
                            painLevel_3_Button,
                            painLevel_4_Button]
    
    private lazy var stack : UIStackView = {
        let v = UIStackView(arrangedSubviews: painButtons)
        v.axis = .horizontal
        v.spacing = 10
        v.distribution = .equalCentering
        v.alignment = .center
        return v
    }()
}
