//
//  NNSampler.swift
//  1019
//
//  Created by mbp on 2016/10/18.
//  Copyright © 2016年 mbp. All rights reserved.
//

import AudioToolbox

class NNSampler: NSObject {

    // soundfont sampler

    var _AUGraph: AUGraph? = nil
    var samplerUnit: AudioUnit? = nil
    /// !ではなく？　　　http://stackoverflow.com/questions/37058503/init-is-deprecated-init-will-be-removed-in-swift-3-use-nil

    override init() {
        super.init()
        self.prepareAUGraph()
    }

    deinit {

        // release
        AUGraphUninitialize(_AUGraph!)
        AUGraphClose(_AUGraph!)
        DisposeAUGraph(_AUGraph!)
    }

    func prepareAUGraph() {
        
        /*  こんな構成?

            _AUGraph
                samplerNode
                    in  remoteOutputNode
                    out samplerUnit
         */

        var err: OSStatus = 0

        var samplerNode = AUNode()
        var remoteOutputNode = AUNode()
        err = NewAUGraph(&_AUGraph)
        err = AUGraphOpen(_AUGraph!)
        
        var cd = AudioComponentDescription()
        cd.componentType = kAudioUnitType_Output
        cd.componentSubType = kAudioUnitSubType_RemoteIO
        cd.componentManufacturer = kAudioUnitManufacturer_Apple
        cd.componentFlags = 0
        cd.componentFlagsMask = 0
        
        err = AUGraphAddNode(_AUGraph!, &cd, &remoteOutputNode)
        if err != 0 {
            print(err)
        }

        cd.componentType = kAudioUnitType_MusicDevice
        cd.componentSubType = kAudioUnitSubType_Sampler

        err = AUGraphAddNode(_AUGraph!, &cd, &samplerNode)
        if err != 0 {
            print(err)
        }

        err = AUGraphConnectNodeInput(_AUGraph!, samplerNode, 0, remoteOutputNode, 0)
        if err != 0 {
            print(err)
        }
        
        err = AUGraphInitialize(_AUGraph!)
        if err != 0 {
            print(err)
        }
    
        err = AUGraphStart(_AUGraph!)
        if err != 0 {
            print(err)
        }

        err = AUGraphNodeInfo(_AUGraph!, samplerNode, nil, &samplerUnit)
        if err != 0 {
            print(err)
        }
    }

    func triggerNote(noteNumber: UInt32, state: String, mixer: Float) {
        
        // 発音イベント ViewControllerから呼ばれる
        // ここは1stepで何発も呼ばれる
        
        // velocity決定して発音
        var velocity: UInt32 = UxNoteVelocity.none.rawValue
        switch state {
        case UxNoteMode.none.rawValue:  velocity = UxNoteVelocity.none.rawValue
        case UxNoteMode.nomal.rawValue: velocity = UxNoteVelocity.nomal.rawValue
        case UxNoteMode.hard.rawValue:  velocity = UxNoteVelocity.hard.rawValue
        default:
            break
        }
        let adjustVelocity: UInt32 = UInt32(Float(velocity) * mixer)
        noteOn(noteNumber: noteNumber, velocity: adjustVelocity)
    }
    
    func noteOn(noteNumber: UInt32, velocity: UInt32) {

        MusicDeviceMIDIEvent(samplerUnit!, 0x90, noteNumber, velocity, 0)
        // MusicDeviceMIDIEvent(samplerUnit!, 0x80, noteNumber, 0, 0) // TODO NoteOffすると音切れる
    }

    func loadFromDLSOrSoundFont(bankURL: URL, presetNumber: Int) -> OSStatus {

        // set soundfont to sampler
        
        var result: OSStatus = 0
        
        let cfbankurl: Unmanaged<CFURL> = Unmanaged.passRetained(bankURL as CFURL)
        var bpdata = AUSamplerBankPresetData(
            bankURL: cfbankurl,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB),
            presetID: UInt8(presetNumber),
            reserved: 0
        )
        
        result = AudioUnitSetProperty(samplerUnit!,
                                      kAUSamplerProperty_LoadPresetFromBank,
                                      kAudioUnitScope_Global,
                                      0,
                                      &bpdata,
                                      UInt32(sizeof(bpdata))
        )
        
        if result != 0 {
            print(result)
        }
        return result
    }

    // make sizeof function
    
    func sizeof <T> (_ : T.Type) -> Int
    {
        return (MemoryLayout<T>.size)
    }
    
    func sizeof <T> (_ : T) -> Int
    {
        return (MemoryLayout<T>.size)
    }
    
    func sizeof <T> (_ value : [T]) -> Int
    {
        return (MemoryLayout<T>.size * value.count)
    }
    
    
}
