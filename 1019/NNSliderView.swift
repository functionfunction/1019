//
//  NNSlider.swift
//  1019
//
//  Created by mbp on 2016/10/28.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

protocol NNSliderViewDelegate {
    func sliderView(sliderView: NNSliderView) // スライダー値変更時
}

class NNSliderView: UIView {

    // スライダーとラベルのセット
    
    var delegate: NNSliderViewDelegate!
    var label: UILabel!
    var slider: UISlider!
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        
        label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.darkGray
        label.textColor = UIColor.white
        label.textAlignment = .center
        self.addSubview(label)
        
        slider = UISlider(frame: CGRect.zero)
        slider.backgroundColor = UIColor.clear
        slider.thumbTintColor = UIColor.white
        slider.isUserInteractionEnabled = true
        slider.addTarget(self, action: #selector(sliderAction), for: .valueChanged)
        self.addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 初期時 各コントロールのレイアウト
        label.frame = CGRect(x: 5, y: 0, width: 80, height: 25)
        slider.frame = CGRect(x: 0, y: 50, width: 80, height: 100)
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1.5))
    }
    
    func sliderAction(slider: UISlider) {
        
        // スライダーが変更になった場合は処理を移譲
        self.delegate.sliderView(sliderView: self)
    }

    func setMixerValue(value: Float) {

        // mixerから呼ばれる

        // 初期時用 だけど変更時も呼ばれる（よくないかも）
        self.slider.value = value
        // 変更時に値をラベルに反映（パーセント整数表示）
        self.label.text = Int(value * 100).description
    }

}
