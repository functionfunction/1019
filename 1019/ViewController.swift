//
//  ViewController.swift
//  1019
//
//  Created by mbp on 2016/10/18.
//  Copyright © 2016年 mbp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NNSequencerDelegate, NNSequenceViewDelegate, NNMixerViewDelegate {

    // main view
    
    var sampler: NNSampler!
    var sequencer: NNSequencer!
    var sequeceView: NNSequenceView!
    var bpmTextField: UITextField!
    var mixerView: NNMixerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // background
        self.view.backgroundColor = UIColor.black
        let imageView = UIImageView(frame:
            CGRect(
                origin: CGPoint.zero,
                size: CGSize(width: self.view.frame.width, height: 300)
            )
        )
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.darkGray
        imageView.image = UIImage(named: "bg.png")
        imageView.clipsToBounds = true
        imageView.alpha = 0.5
        self.view.addSubview(imageView)
        


        // initial data
        let initData = [
            "2010000120210201",
            "0000000000002000",
            "0000200000002000",
            "2010001020011010",
        ]
        sequence.initSeqData = initData
        sequence.updateDataFromStringArray()
        sequence.mixerData = [1, 1, 1, 0.6]


        // display step resolution
        sequence.dispStepResolution = self.view.frame.size.width / CGFloat(sequence.numberOfSteps)


        // sampler
        var res: OSStatus = 0
        sampler = NNSampler()
        let presetURL: URL! = Bundle.main.url(forResource: "TR-909_Drums", withExtension: "SF2")!
        res = sampler.loadFromDLSOrSoundFont(bankURL: presetURL!, presetNumber: 0)
        if res != 0 {
            print("load error")
            return
        }


        // sequeceView
        var rect = self.view.bounds
        rect.origin.y = 20 // status bar height
        sequeceView = NNSequenceView.init(frame: rect)
        sequeceView.delegate = self
        sequeceView.autoresizingMask = .flexibleWidth
        self.view.addSubview(sequeceView)
        sequeceView.updateStatusByTap() // start step
        

        // sequencer
        sequencer = NNSequencer()
        sequencer.delegate = self
        //sequencer.play()
        
        
        // button

        let playButton = UIButton(frame: CGRect(x: 50, y: 320, width: 50, height: 50))
        playButton.setTitle("Play", for: .normal)
        playButton.tag = 0
        playButton.backgroundColor = UIColor.red
        playButton.layer.cornerRadius = 25
        playButton.clipsToBounds = true
        playButton.addTarget(self, action: #selector(actionButton), for: .touchUpInside)
        self.view.addSubview(playButton)

        let stopButton = UIButton(frame: CGRect(x: 110, y: 320, width: 50, height: 50))
        stopButton.setTitle("Stop", for: .normal)
        stopButton.tag = 1
        stopButton.backgroundColor = UIColor.darkGray
        stopButton.layer.cornerRadius = 25
        stopButton.clipsToBounds = true
        stopButton.addTarget(self, action: #selector(actionButton), for: .touchUpInside)
        self.view.addSubview(stopButton)


        // bpm
        bpmTextField = UITextField(frame: CGRect(x: 200, y: 320, width: 50, height: 50))
        bpmTextField.text = sequence.bpm.description
        bpmTextField.backgroundColor = UIColor.white
        self.view.addSubview(bpmTextField)
        
        
        // mixerview
        mixerView = NNMixerView(frame: CGRect(x: 0 , y: 400, width: self.view.bounds.size.width, height: 200))
        mixerView.delegate = self
        self.view.addSubview(mixerView)
    }

    func sequencer(sequencer: NNSequencer, step: Int) {

        // sequencerが内部ステップを進めたら実行される
        
        for i in 0..<sequence.numberOfTracks {
            let state: String = sequencer.stateStepAtTrack(track: i, step: step)
            if state == UxNoteMode.nomal.rawValue || state == UxNoteMode.hard.rawValue {
                var noteNumber: UInt32
                switch i { // track
                case 0:
                    noteNumber = UxDrumNoteNumber.kick.rawValue
                case 1:
                    noteNumber = UxDrumNoteNumber.clap.rawValue
                case 2:
                    noteNumber = UxDrumNoteNumber.snare.rawValue
                case 3:
                    noteNumber = UxDrumNoteNumber.hatClose.rawValue
                default:
                    noteNumber = 0
                }
                let mixer = sequence.mixerData[i]
                sampler.triggerNote(noteNumber: noteNumber, state: state, mixer: mixer)
            }
        }
    }
    
    func sequenceView(sequenceView: NNSequenceView, track: Int, step: Int){
    
        // button taped

        let state: String = self.sequencer.stateStepAtTrack(track: track, step: step)

        var nextState: String = UxNoteMode.none.rawValue
         switch state {
            case UxNoteMode.none.rawValue:  nextState = UxNoteMode.nomal.rawValue
            case UxNoteMode.nomal.rawValue: nextState = UxNoteMode.hard.rawValue
            case UxNoteMode.hard.rawValue:  nextState = UxNoteMode.none.rawValue
         default:
            break
        }
        
        // set status
        sequencer.setStateStepAtTrack(state: nextState, track: track, step: step) // data
        sequenceView.updateStatusByTap() // to display
    }

    func sequencer(step: Int) {
        
        // sequencerが内部ステップを進めたら実行される
        sequeceView.updateCurrentPosition(step: step)
    }

    func actionButton(sender: UIButton) {

        self.view.endEditing(true)
        // TODO キーボード表示中にスライダーいじってもキーボード閉じないかも どこにも閉じる処理書いていない

        if sequencer.isPlaying == true {
            // Stopボタン Play中だけ実行可
            if sender.tag != 0 {
                sequencer.stop()
            }
        }
        else {
            // Playボタン Play中は実行不可
            if sender.tag == 0 {
                sequencer.setBPM(bpm: Int(self.bpmTextField.text!)!)
                sequencer.play()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mixerView(mixerView: NNMixerView, track: Int, value: Float) {

        // save mixer data
        sequence.mixerData[track] = value
    }

    func updatePosition(step: Int) {
        
        // position Button tap
        sequencer.currentStep = step
        if sequencer.isPlaying == false {
            sequeceView.updateCurrentPosition(step: step)
            return
        }
        //sequencer.stop()
        //sequencer.play()
    }
}

