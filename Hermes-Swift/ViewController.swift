//
//  ViewController.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 10/1/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//    let MAJOR_SCALE = "major_scale_ID"
//    let MAJOR_SCALE_2 = "major_scale_2_ID"
//    
//    let MAJOR_SCALE_MIDI = "major_scale_midi_ID"
//    let BAS_MIDI = "bass_midi_ID"
//    
    var currSequence : Sequence?
//
//    var invention12Seq, invention13Seq: Sequence?
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("heyo")
//
        let resourcePath = NSBundle.mainBundle().resourcePath!
//
        let gameTitle = Sequence()
//
        let drumtrack = VoicePattern(midiFile: resourcePath+"/game-drums.mid")
        drumtrack.setPitched(false)
        
        let basstrack = VoicePattern(midiFile: resourcePath+"/game-bass.mid")
        basstrack.setPitched(true)

        let pianotrack = VoicePattern(midiFile: resourcePath+"/game-piano.mid")
        
        let padtrack = VoicePattern(midiFile: resourcePath+"/game-pad.mid")
        
        let gameBlock = Block()

        gameBlock.addVoicePattern(drumtrack)
        gameBlock.addVoicePattern(basstrack)
        gameBlock.addVoicePattern(pianotrack)
        gameBlock.addVoicePattern(padtrack)

        let drums = VoiceObject(patchNamed: "drumkit.pd", atPath: resourcePath)
        drums.setVolume(1.2, msec: 0)
        
        let bass = VoiceObject(patchNamed: "bass.pd", atPath: resourcePath)
        bass.setVolume(0.3, msec: 0)

        
        let padL = VoiceObject(patchNamed: "soft-pad.pd", atPath: resourcePath)
        let padR = VoiceObject(patchNamed: "soft-pad.pd", atPath: resourcePath)
        padL.setVolume(0.3, msec: 0)
        padL.setPanning(0.1, msec: 0)
        padR.setPanning(0.9, msec: 0)
        padR.setVolume(0.3, msec: 0)
        
        drumtrack.addVoiceObject(drums)
        
        gameTitle.playBlockNext(gameBlock)

        

//        gameTitle.tracks["drums"]?.addVoiceObject(drums, withIdentifier: "drums")
//        gameTitle.tracks["bass"]?.addVoiceObject(bass, withIdentifier: "bass")
//        gameTitle.tracks["pad"]?.addVoiceObject(padL, withIdentifier: "padL")
//        gameTitle.tracks["pad"]?.addVoiceObject(padR, withIdentifier: "padR")
//        
//        
//        gameTitle.setLoop(false)
//
//        
//        
//        let piano1 = VoiceObject(patchNamed: "piano.pd", atPath: resourcePath)
//        piano1.instrumentPatch.sendFloat(Float(piano1.instrumentPatch.dollarZero), toReceiver: "set-piano-throw")
//        piano1.setPanning(0.35, msec: 0)
//        piano1.setVolume(1.3, msec: 0)
//
//        let piano2 = VoiceObject(patchNamed: "piano.pd", atPath: resourcePath)
//        piano2.instrumentPatch.sendFloat(Float(piano2.instrumentPatch.dollarZero), toReceiver: "set-piano-throw")
//        piano2.setPanning(0.57, msec: 0) 
//
//        
//        gameTitle.tracks["piano"]?.addVoiceObject(piano1, withIdentifier: "piano")

//        invention12Seq = Sequence()
//        invention12Seq?.addVoicePattern(VoicePattern(midiFile: resourcePath+"/Invention12-RH.mid"), withIdentifier: "RH")
//        invention12Seq?.addVoicePattern(VoicePattern(midiFile: resourcePath+"/Invention12-LH.mid"), withIdentifier: "LH")
        
//        invention12Seq?.tracks["RH"]?.addVoiceObject(piano1, withIdentifier: "piano")
//        invention12Seq?.tracks["LH"]?.addVoiceObject(piano2, withIdentifier: "piano")
        
//        let buzz1 = VoiceObject(patchNamed: "buzz.pd", atPath: resourcePath)
//        let buzz2 = VoiceObject(patchNamed: "buzz.pd", atPath: resourcePath)
//        drumSeq.tracks["drumloop"]?.addVoiceObject(buzz1, withIdentifier: "buzz")
        
//        invention12Seq?.tracks["RH"]?.addVoiceObject(buzz1, withIdentifier: "buzz 1")
//        invention12Seq?.tracks["LH"]?.addVoiceObject(buzz2, withIdentifier: "buzz 2")
        
//        invention13Seq = Sequence()
//        invention13Seq?.addVoicePattern(VoicePattern(midiFile: resourcePath+"/Invention13-RH.mid"), withIdentifier: "RH")
//        invention13Seq?.addVoicePattern(VoicePattern(midiFile: resourcePath+"/Invention13-LH.mid"), withIdentifier: "LH")
        
//        let buzz3 = VoiceObject(patchNamed: "buzz.pd", atPath: resourcePath)
//        let buzz4 = VoiceObject(patchNamed: "buzz.pd", atPath: resourcePath)
        
//        invention13Seq?.tracks["RH"]?.addVoiceObject(buzz3, withIdentifier: "buzz 1")
//        invention13Seq?.tracks["LH"]?.addVoiceObject(buzz4, withIdentifier: "buzz 2")
        
        
        currSequence = gameTitle
//
//        currSequence?.readyForPlaying()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func play(sender: AnyObject) {
        currSequence?.start()
    }
    
    
    @IBAction func pause(sender: AnyObject) {
        currSequence?.pause()
    }
    @IBAction func unpause(sender: AnyObject) {
        currSequence?.unpause()
    }
    
    @IBAction func stop(sender: AnyObject) {
        currSequence?.stop()
    }
    @IBAction func tempoBar(sender: UISlider!) {
        let v = sender.value
        currSequence?.setTempo(v<=1 ? v*0.8+0.2 : (v-1)*3+1)
//        currSequence?.setPitchOffset(v * 4 - 2)
    }
    
    @IBAction func twelve(sender: AnyObject) {
//        currSequence = invention12Seq
    }
    
    @IBAction func thirteen(sender: AnyObject) {
//        currSequence = invention13Seq
    }
}


