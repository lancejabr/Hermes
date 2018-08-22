//
//  MoneySingsViewController.swift
//  Hermes Showcase
//
//  Created by Lance Jabr on 12/8/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import UIKit

class MoneySingsViewController : UIViewController {
    
    let sequence = Sequence()
    let block = Block()


    // make the voice objects
    let padR = VoiceObject(patchNamed: "soft-pad.pd", atPath: resourcePath)
    let padL = VoiceObject(patchNamed: "soft-pad.pd", atPath: resourcePath)
    let bass = VoiceObject(patchNamed: "bass.pd", atPath: resourcePath)
    let piano = VoiceObject(patchNamed: "piano.pd", atPath: resourcePath)
    let drums = VoiceObject(patchNamed: "drumkit.pd", atPath: resourcePath)
    let MFX = VoiceObject(patchNamed: "MFX.pd", atPath: resourcePath)
    
    // make the voice patterns
    let bassPattern = VoicePattern(midiFile: resourcePath+"/bass.mid")
    let padPattern = VoicePattern(midiFile: resourcePath+"/pad.mid")
    let drumsPattern = VoicePattern(midiFile: resourcePath+"/drums.mid")
    let pianoPattern = VoicePattern(midiFile: resourcePath+"/piano.mid")
    let bellPattern = VoicePattern(midiFile: resourcePath+"/bells.mid")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        padR.setPanning(1, msec: 0)
        padL.setPanning(0, msec: 0)
        padR.setVolume(0.2, msec: 0)
        padL.setVolume(0.2, msec: 0)
        
        bass.setVolume(0.2, msec: 0)
        piano.setVolume(0.8, msec: 0)
        
        drums.setVolume(0.8, msec: 0)
        
        MFX.setVolume(0.7, msec: 0)

        
        // connect them
        bassPattern.addVoiceObject(bass)
        padPattern.addVoiceObject(padL)
        padPattern.addVoiceObject(padR)
        drumsPattern.addVoiceObject(drums)
        pianoPattern.addVoiceObject(piano)
        bellPattern.addVoiceObject(MFX)
        
        
        block.addVoicePattern(bassPattern)
        block.addVoicePattern(padPattern)
        block.addVoicePattern(drumsPattern)
        block.addVoicePattern(pianoPattern)
        block.addVoicePattern(bellPattern)
        
        
        sequence.playBlockNext(block)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sequence.setVolume(1, msec: 0)
        
        sequence.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sequence.fadeOutAndStop(msec: 300)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // when there is a touch, play a bell sound
        MFX.instrumentPatch.sendBang(toReceiver: "play-sound")
        
        coinView.center = CGPoint(x: CGFloat(arc4random_uniform(100))/100*view.bounds.size.width, y: CGFloat(arc4random_uniform(100))/100*view.bounds.size.height)
    }
    
    @IBOutlet var coinView : UIImageView!
    
}
