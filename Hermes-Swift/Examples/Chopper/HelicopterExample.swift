//
//  HelicopterExample.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 11/12/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import UIKit

class ChopperViewController : UIViewController, UIGestureRecognizerDelegate {
    
    let heliSequence = Sequence()
    let chopperBlock = Block()
    
    @IBOutlet var chopper : UIImageView!
    
    override func viewDidLoad() {
        
        // make a gesture recognizer to move the chopper
        let panRec = UIPanGestureRecognizer(target: self, action: "panRecognized:")
        chopper.addGestureRecognizer(panRec)
        
        //a blank block
//        let chopperBlock = Block()
        
        // a pattern that only has one sixteenth note at 120 bpm
        let chopperPattern = VoicePattern(midiFile: resourcePath + "/chopper.mid")

        
        // a helicopter synth
        let chopperObject = VoiceObject(patchNamed: "chopper.pd", atPath: resourcePath)
        
        



        // add the object to the pattern
        chopperPattern.addVoiceObject(chopperObject)

        // add the pattern to a block
        chopperBlock.addVoicePattern(chopperPattern)
        
        // schedule the block and tell the sequence to loop it
        heliSequence.playBlockNext(chopperBlock)
        heliSequence.setContinue(true)
        
        // ready for playing and set a good tempo
        heliSequence.setTempo(2)
    }
    
    override func viewDidAppear(animated: Bool) {
        // start the effect and fade in
        heliSequence.setVolume(0, msec: 0)
        heliSequence.start()
        heliSequence.setVolume(1, msec: 500)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // fade out and stop
        heliSequence.fadeOutAndStop(msec: 500)
    }
    
    func panRecognized(recognizer : UIPanGestureRecognizer) {
        // move the helicopter with user's finger
        chopper.center = recognizer.locationInView(view)
        
        // get the velocity of the drag and find the speed of the blades
        let yVal = recognizer.velocityInView(view).y / view.frame.size.height * -0.6 + 2
        
        // change the speed of the blades
        heliSequence.setTempo(Float(yVal))
    }
    
}
