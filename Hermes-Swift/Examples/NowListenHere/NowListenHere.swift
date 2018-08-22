//
//  CruiseControl.swift
//  Hermes Showcase
//
//  Created by Lance Jabr on 11/19/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import UIKit

class NowListenHereViewController: UIViewController {
    
    let sequence = Sequence()
    let introBlock = Block()
    let mainBlock = Block()
    
    // make the instruments
    let saw1 = VoiceObject(patchNamed: "saw.pd", atPath: resourcePath)
    let saw2 = VoiceObject(patchNamed: "saw.pd", atPath: resourcePath)
    let saw3 = VoiceObject(patchNamed: "saw.pd", atPath: resourcePath)
    let saw4 = VoiceObject(patchNamed: "saw.pd", atPath: resourcePath)

    
    let piano = VoiceObject(patchNamed: "piano.pd", atPath: resourcePath)
    let harp = VoiceObject(patchNamed: "harp.pd", atPath: resourcePath)
    let glock = VoiceObject(patchNamed: "glock.pd", atPath: resourcePath)
    
    let melodyIntro = VoicePattern(midiFile: resourcePath+"/melody-intro.mid")
    let melodyMain = VoicePattern(midiFile: resourcePath+"/melody-main.mid")
    let countIntro = VoicePattern(midiFile: resourcePath+"/counterpoint-intro.mid")
    let countMain = VoicePattern(midiFile: resourcePath+"/counterpoint-main.mid")
    let bassIntro = VoicePattern(midiFile: resourcePath+"/bass-intro.mid")
    let bassFrantic = VoicePattern(midiFile: resourcePath+"/bass-frantic.mid")
    let bassCalm = VoicePattern(midiFile: resourcePath+"/bass-calm.mid")

    var gamePaused = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        saw1.setPanning(0.6, msec: 0)
        saw2.setPanning(0.4, msec: 0)
        
        saw1.setVolume(0.33, msec: 0)
        saw2.setVolume(0.33, msec: 0)
        saw3.setVolume(0.33, msec: 0)
        
        glock.setVolume(0, msec: 0)
        glock.setPanning(0.6, msec: 0)
        
        // make the patterns
        melodyIntro.addVoiceObject(saw1)
        melodyMain.addVoiceObject(saw1)
        melodyMain.addVoiceObject(glock)
        melodyIntro.addVoiceObject(piano)
        melodyMain.addVoiceObject(piano)
        
        countIntro.addVoiceObject(saw2)
        countMain.addVoiceObject(saw2)
        countIntro.addVoiceObject(piano)
        countMain.addVoiceObject(piano)
        
        bassIntro.addVoiceObject(saw3)
        bassFrantic.addVoiceObject(saw3)
        bassIntro.addVoiceObject(piano)
        bassFrantic.addVoiceObject(piano)
        
        bassCalm.addVoiceObject(harp)
        bassCalm.setVolume(0, msec: 0)
        
        piano.setVolume(0, msec: 0)
        
        // and the loop markers
        let introLoop = VoicePattern(midiFile: resourcePath+"/loop-intro.mid")
        let mainLoop = VoicePattern(midiFile: resourcePath+"/loop-main.mid")
        
        
        // add them to the blocks
        introBlock.addVoicePattern(melodyIntro)
        introBlock.addVoicePattern(countIntro)
        introBlock.addVoicePattern(bassIntro)
        introBlock.addVoicePattern(introLoop)
        
        mainBlock.addVoicePattern(melodyMain)
        mainBlock.addVoicePattern(countMain)
        mainBlock.addVoicePattern(bassFrantic)
        mainBlock.addVoicePattern(bassCalm)
        mainBlock.addVoicePattern(mainLoop)
        
        
        // add them to the sequence
        sequence.playBlockNext(introBlock)
        sequence.playBlockNext(mainBlock)
        
        sequence.setContinue(true)
        
        sequence.start()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sequence.pause()
    }
    
    
    @IBAction func tapRecognized(_ sender: UIButton){
        if gamePaused {
            unpauseGame()
        } else {
            pauseGame()
        }
    }
    
    func pauseGame() {
        saw1.setVolume(0, msec: 150)
        glock.setVolume(1, msec: 150)
        countMain.setVolume(0, msec: 150)
        bassFrantic.setVolume(0, msec: 150)
        bassCalm.setVolume(1, msec: 150)
        
        sequence.setTempo(0.6)
        
        gamePaused = true
    }
    
    func unpauseGame() {
        saw1.setVolume(0.33, msec: 150)
        glock.setVolume(0, msec: 150)
        countMain.setVolume(1, msec: 150)
        bassFrantic.setVolume(1, msec: 150)
        bassCalm.setVolume(0, msec: 150)
        
        sequence.setTempo(1)
        
        gamePaused = false
        
    }
    
    @IBAction func tempo(_ sender: UISlider) {
        sequence.setTempo(sender.value)
        
    }
    
    let fadeTime: Float = 300.0
    
    @IBAction func sawArrangement(_ sender: UIButton) {
        piano.setVolume(0, msec: fadeTime)
        
        saw1.setVolume(0.33, msec: fadeTime)
        saw2.setVolume(0.33, msec: fadeTime)
        saw3.setVolume(0.33, msec: fadeTime)
    }
    
    @IBAction func pianoArrangement(_ sender: UIButton) {
        piano.setVolume(1, msec: fadeTime)
        
        saw1.setVolume(0, msec: fadeTime)
        saw2.setVolume(0, msec: fadeTime)
        saw3.setVolume(0, msec: fadeTime)
    }
    
    
    var stopped = false
    
    @IBAction func play(_ sender: AnyObject) {
        stopped ? sequence.start() : sequence.unpause()
        stopped = false
    }
    
    @IBAction func pause(_ sender: AnyObject) {
        sequence.pause()
        stopped = false
    }
    
    @IBAction func stop(_ sender: AnyObject) {
        sequence.stop()
        stopped = true
    }
}
