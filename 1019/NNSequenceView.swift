//
//  NNSequenceView.swift
//  1019
//
//  Created by mbp on 2016/10/19.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

@objc protocol NNSequenceViewDelegate {
    @objc optional func updateStatusByTap()
    @objc optional func updatePosition(step: Int)
    @objc optional func sequenceView(sequenceView: NNSequenceView, track: Int, step: Int)
}

class NNSequenceView: UIView, NNStepsViewDelegate {

    // シーケンスビュー トラックの集合体

    var delegate: NNSequenceViewDelegate!
    var tracks: [NNStepsView] = []
    var currentBar: UIView!
    var positionButtons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        let rect: CGRect = CGRect.zero

        // カレントバーを設置
        currentBar = UIView(frame: rect)
        currentBar.backgroundColor = UIColor.red
        self.addSubview(currentBar)
        
        
        // トラックを配置
        for i in 0..<sequence.numberOfTracks {

            let track = NNStepsView(frame: rect)
            track.delegate = self
            track.tag = i
            self.addSubview(track)
            tracks.append(track)
        }
        
        // ポジションボタンを配置
        for i in 0..<sequence.numberOfSteps {
            let positionButton = UIButton(frame: rect)
            positionButton.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
            positionButton.addTarget(self, action: #selector(actionPositionButtonUp), for: .touchUpInside)
            positionButton.addTarget(self, action: #selector(actionPositionButtonDown), for: .touchDown)
            positionButton.tag = i
            self.addSubview(positionButton)
            positionButtons.append(positionButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // カレントの配置
        currentBar.frame.size.height =
            (UxButton.height.rawValue +  UxButton.heightSpace.rawValue) *
            CGFloat(sequence.numberOfTracks)
        currentBar.frame.size.width = sequence.dispStepResolution

        // トラックの配置
        var rect = CGRect.zero
        rect.size.width = self.bounds.size.width
        rect.size.height = UxButton.height.rawValue
        
        for track in tracks {
            track.frame = rect
            rect.origin.y += rect.size.height + UxButton.heightSpace.rawValue
        }
        
        // ポジションボタンの配置
        rect.origin.y += UxButton.heightSpace.rawValue
        let buttonWidthSpace: CGFloat = 2
        rect.size.width = self.bounds.size.width / CGFloat(sequence.numberOfSteps) - buttonWidthSpace
        rect.size.height = UxButton.height.rawValue * 1.5

        for positionButton in positionButtons {
            positionButton.frame = rect
            positionButton.layer.cornerRadius = 5
            positionButton.clipsToBounds = true
            rect.origin.x += rect.size.width + buttonWidthSpace
        }
    }

    func updateStatusByTap() {
        
        // データから各トラックを更新
        for i in 0..<sequence.numberOfTracks {
            let track = tracks[i]
            track.setStatus(track: sequence.seqData[i])
        }
    }

    func updateCurrentPosition(step: Int) {
        
        // カレントバー位置更新
        currentBar.frame.origin.x = CGFloat(step) * sequence.dispStepResolution
    }
    
    func stepsView(stepsView: NNStepsView, step: Int) {
        
        // トラックとステップを指定 処理は移譲
        // つまりbutton押されたらStepViewに移譲されてさらにsequenceViewに移譲される流れ
        self.delegate.sequenceView!(sequenceView: self, track: stepsView.tag, step: step)
    }
    
    func actionPositionButtonDown(sender: UIButton) {
        
        //  ポジションボタン押されたら処理移譲
        self.delegate.updatePosition!(step: sender.tag)
        sender.backgroundColor = UIColor.red
    }
    
    func actionPositionButtonUp(sender: UIButton) {
        
        //  ポジションボタン離したら色戻す
        sender.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
    }
}
