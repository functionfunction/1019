//
//  NNDataModel.swift
//  1019
//
//  Created by mbp on 2016/10/25.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

enum UxNoteMode: String {
    case none  = "0"
    case nomal = "1"
    case hard  = "2"
}

enum UxNoteVelocity: UInt32 {
    case none  = 0
    case nomal = 80
    case hard  = 127
}

enum UxDrumNoteNumber: UInt32 {
    case kick = 36
    case clap = 39
    case snare = 38
    case hatClose = 42
}

enum UxButton: CGFloat {
    case height = 40
    case heightSpace = 10
}

class Sequence {
    
    var numberOfTracks = 4
    var numberOfSteps = 16
    var bpm: Int = 85
    
    // set on viewDidLoad
    var dispStepResolution: CGFloat = 0
    var mixerData: [Float] = []
    var seqData: [[String]] = []    // UxNoteMode
    var initSeqData: [String] = []

    init() {

        // initial sequence Data
        seqData = Array(
            repeating: Array(repeating: "0", count: numberOfSteps),
            count: numberOfTracks
        )
        
        // initial mixer data
        mixerData = [1, 1, 1, 1]
    }

    func updateDataFromStringArray() {
        
        // 初期データセット
        for trackIndex in 0..<numberOfTracks {
            for stepIndex in 0..<numberOfSteps {
                let startIndex = initSeqData[trackIndex].startIndex
                let start = initSeqData[trackIndex].index(startIndex, offsetBy: stepIndex)
                let end = initSeqData[trackIndex].index(startIndex, offsetBy: stepIndex + 1)
                let currentStep = initSeqData[trackIndex].substring(with: start..<end)
                seqData[trackIndex][stepIndex] = currentStep
            }
        }
    }
}

