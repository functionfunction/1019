//
//  NNStepsView.swift
//  1019
//
//  Created by mbp on 2016/10/20.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

protocol NNStepsViewDelegate {
    func stepsView(stepsView: NNStepsView, step: Int) // ボタン押された時の処理記述用
}

class NNStepsView: UIView {

    // トラック ステップボタンの集合体

    var delegate: NNStepsViewDelegate!
    var buttons: [NNStepButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        // ボタンを配置
        for i in 0..<sequence.numberOfSteps {

            let button = NNStepButton()
            button.setTitle(i.description, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            self.addSubview(button)
            
            buttons.append(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 初期時 各ボタンのレイアウト
        var rect = CGRect.zero
        rect.size.width = self.bounds.size.width / CGFloat(sequence.numberOfSteps)
        rect.size.height = self.bounds.size.height
        
        for button in buttons {
            button.frame = rect
            rect.origin.x += rect.size.width
        }
    }

    func setStatus(track: [String]) {
        
        // データを元にボタンの状態を設定する
        for i in 0..<track.count {
            let button: NNStepButton = buttons[i]
            let state = track[i]
            button.setStatusByMode(mode: state)
        }
    }

    func buttonAction(button: UIButton) {
        
        // ボタン押された場合は処理を移譲
        self.delegate.stepsView(stepsView: self, step: button.tag)
    }
}
