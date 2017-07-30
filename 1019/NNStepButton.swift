//
//  NNStepButton.swift
//  1019
//
//  Created by mbp on 2016/10/20.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

class NNStepButton: UIButton {

    var mode: String = UxNoteMode.none.rawValue
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStatusByMode(mode: String) {

        // set color by mode

        switch mode {
        case UxNoteMode.none.rawValue:
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor.clear

        case UxNoteMode.nomal.rawValue:
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor.white.withAlphaComponent(0.4)

        case UxNoteMode.hard.rawValue:
            self.setTitleColor(UIColor.black, for: .normal)
            self.backgroundColor = UIColor.white.withAlphaComponent(0.85)

        default:
            break
        }
    }
}
