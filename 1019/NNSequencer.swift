//
//  NNSequencer.swift
//  1019
//
//  Created by mbp on 2016/10/19.
//  Copyright © 2016年 mbp. All rights reserved.
//

import Foundation

@objc protocol NNSequencerDelegate {
    func sequencer(sequencer: NNSequencer, step: Int)
    func sequencer(step: Int)
}

class NNSequencer : NSObject {
    
    // タイマーによるシーケンス制御とデータ参照更新
    
    var delegate: NNSequencerDelegate!
    var currentStep: Int = 0
    internal var timer: Timer = Timer.init()
    internal var isPlaying: Bool { return timer.isValid }

    func setBPM(bpm: Int) {
        sequence.bpm = bpm
    }
    
    func stateStepAtTrack(track: Int, step: Int) -> String {

        // データを参照
        let state = sequence.seqData[track][step]
        return state
    }
    func setStateStepAtTrack(state: String, track: Int, step: Int) {

        // データに値セット
        sequence.seqData[track][step] = state
    }

    func play() {

        // calc BPM 分解能16ビートの場合
        let sixteenthNoteDuration: Double = 60 / Double(sequence.bpm) * 0.25 // BPMの1/4が16ビート

        // timer start
        
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: Double(sixteenthNoteDuration), target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        self.timerFired(timer: timer)
    }

    func stop() {
        self.timer.invalidate()
    }

    func timerFired(timer: Timer) {
        
        // 進める前の処理 移譲
        self.delegate.sequencer(sequencer: self, step: currentStep) // 発音
        self.delegate.sequencer(step: currentStep) // 画面

        // 内部ステップを進める
        currentStep += 1
        if (currentStep == sequence.numberOfSteps) {
            currentStep = 0
        }
    }
}
