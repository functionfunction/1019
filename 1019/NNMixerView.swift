//
//  NNMixerView.swift
//  1019
//
//  Created by mbp on 2016/10/28.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

protocol NNMixerViewDelegate {
    func mixerView(mixerView: NNMixerView, track: Int, value: Float) // スライダー値変更受付時
}

class NNMixerView: UIView, NNSliderViewDelegate {

    // スライダーの集合体
    
    var delegate: NNMixerViewDelegate!
    var sliders: [NNSliderView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear

        // トラックを配置
        let rect: CGRect = CGRect.zero
        for i in 0..<sequence.numberOfTracks {
            
            let slider = NNSliderView(frame: rect)
            slider.delegate = self
            slider.setMixerValue(value: sequence.mixerData[i])
            slider.tag = i
            self.addSubview(slider)
            
            sliders.append(slider)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // トラックの配置
        var rect = CGRect.zero
        rect.size.width = 90
        rect.size.height = 150
        
        for slider in sliders {
            slider.frame = rect
            rect.origin.x += rect.size.width
        }
    }

    func sliderView(sliderView: NNSliderView) {

        // スライダー値変更を受付たらさらに移譲
        self.delegate.mixerView(mixerView: self, track: sliderView.tag, value: sliderView.slider.value)
        // スライダー値をラベルに反映
        sliderView.setMixerValue(value: sliderView.slider.value)
    }
}
