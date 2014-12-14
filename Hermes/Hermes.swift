//
//  HermesModel.swift
//  Hermes-Swift
//
//  Created by Lance Jabr on 10/24/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

import Foundation

let patchDirectoryPath = NSBundle.mainBundle().resourcePath!

class Event {
    var absoluteMSec : Float = 0.0
    
    var trackSymbol : String = ""
}

class Note : Event {
    var pitchMIDI : Float = 0.0
    var velocityMIDI : Float = 0.0
}

class TimeSig : Event {
    var mSecPerBeat : Float = 0.0
}


class VoiceObject {
    let linkPatch : PdFile
    
    let instrumentPatch : PdFile
    
    init(patchNamed name: String, atPath path: String) {
        
        linkPatch = PdFile.openFileNamed("instrument-link.pd", path: patchDirectoryPath) as PdFile
        
        // make the instrument
        if let newInstrument = PdFile.openFileNamed(name, path: path) as? PdFile {
            instrumentPatch = newInstrument
        } else {
            // or default to a backup
            instrumentPatch = PdFile.openFileNamed("buzz.pd", path: patchDirectoryPath) as PdFile
        }
        
        // tell the instrument patch to throw to the corrent instrument link
        instrumentPatch.sendMessage("set", withArguments: [String(linkPatch.dollarZero) + "-sigin"], toReceiver: "set-throw")
    }
    
    func setVolume(level: Float, msec: Float = 300) {
        linkPatch.sendList([level, msec], toReceiver: "volume")
    }
    
    func setPanning(level: Float, msec: Float = 300) {
        linkPatch.sendList([level, msec], toReceiver: "pan")
    }
}


class VoicePattern {
    let vpPatch = PdFile.openFileNamed("voice-pattern.pd", path: patchDirectoryPath) as PdFile
    
    var events = [Event]()
    
    var voiceObjects = [VoiceObject]()
    func addVoiceObject(voiceObj: VoiceObject) {
        // add it to the storage
        voiceObjects.append(voiceObj)
        
        // tell the pattern to send to this object
        vpPatch.sendSymbol(String(voiceObj.instrumentPatch.dollarZero), toReceiver: "add-instrument")
        
        // send the instrument link output to this pattern
        voiceObj.linkPatch.sendSymbol(String(vpPatch.dollarZero), toReceiver: "set-throw")
    }
    
    init(midiFile path: String) {
        // read the midi file
        let midiFile = readMidiFile(path).move()
        
        // get timing information
        let ticksPerQduarter = Float(midiFile.hdTicksPerQuarter)
        var msecPerQuarter : Float = 0
        
        // get the master track
        let masterTrack = midiFile.masterTrack.move()
        
        // keep track of the current msec mark
        var currMSec = 0
        
        for i in 0..<Int(masterTrack.eventCount) {
            // get the event and its data
            let midiEvent = masterTrack.events[i].move()
            let eventData = UnsafeMutablePointer<CInt>(midiEvent.data)
            
            // if the event is a tempo setting, change the msec per quarter
            if midiEvent.type == 4 {
                msecPerQuarter = Float(eventData[0])/1000
            }
            
            // if the event is a note, add the note to the track
            if midiEvent.type == 0 {
                let newNote = Note()
                newNote.absoluteMSec = Float(midiEvent.absoluteTicks) / ticksPerQduarter * msecPerQuarter
                newNote.pitchMIDI = Float(eventData[0])
                newNote.velocityMIDI = Float(eventData[1])
                
                newNote.trackSymbol = String(vpPatch.dollarZero) + "-note"
                
                events.append(newNote)
            }
            
            // update the new current time mark
            currMSec = Int(midiEvent.absoluteTicks)
            // free memory
            eventData.destroy()
        }
    }
    
    func setVolume(level: Float, msec: Float = 300) {
        vpPatch.sendList([level, msec], toReceiver: "volume")
    }
    
    func setPitched(pitched: Bool) {
        vpPatch.sendFloat(pitched ? 1 : 0, toReceiver: "pitched")
    }
}

class Block {
    let blockPatch = PdFile.openFileNamed("block.pd", path: patchDirectoryPath) as PdFile
    
    var vPatterns = [VoicePattern]()
    func addVoicePattern(vp: VoicePattern) {
        // add the voice pattern
        vPatterns.append(vp)
        
        // tell the voice pattern to send to this block
        vp.vpPatch.sendFloat(Float(blockPatch.dollarZero), toReceiver: "set-throw")
        
        // register the voice pattern with this block so that note off events work properly
        blockPatch.sendSymbol(String(vp.vpPatch.dollarZero), toReceiver: "add-voice-pattern")
        
        // mark that we are not ready anymore
        readyToPlay = false
    }
    
    var readyToPlay = false
    func readyForPlaying() {
        if readyToPlay {return}
        
        var allNotes = [Event]()
        func insertNewEvents(newEvents: [Event], inout intoArray array: [Event]) {
            // the current insertion point
            var currIdx = 0
            
            // check where each event goes
            for event in newEvents {
                // otherwise find where this event should go
                while currIdx < array.count && event.absoluteMSec >= array[currIdx].absoluteMSec { currIdx++ }
                
                // check if we are inserting past the end...
                if currIdx == array.count {
                    array.append(event)
                    currIdx++
                    continue
                }
                
                // ...or insert it there (increment again)
                array.insert(event, atIndex: currIdx++)
            }
        }

        // assemble the events together
        for vp in vPatterns {
            insertNewEvents(vp.events, intoArray: &allNotes)
        }
        
        // send the events to the qlist
        var currMSec : Float = 0
        for event in allNotes {
            if let note = event as? Note {
                let deltaMSec = note.absoluteMSec - currMSec
                
                //... except for the last one, which is a loop message
                if event === allNotes.last {
                    blockPatch.sendMessage("add", withArguments: [deltaMSec, String(blockPatch.dollarZero)+"-done", "bang"], toReceiver: "qCommand")
                } else {
                    blockPatch.sendMessage("add", withArguments: [deltaMSec, note.trackSymbol, note.pitchMIDI, note.velocityMIDI], toReceiver: "qCommand")
                }
                
                currMSec = event.absoluteMSec
            }
        }
        
        // now we are ready
        readyToPlay = true
    }
}

class Sequence {
    let seqPatch = PdFile.openFileNamed("sequence.pd", path: patchDirectoryPath) as PdFile
    
    func start() {        
        stop()
        seqPatch.sendBang(toReceiver: "start")
    }
    
    func pause() {
        seqPatch.sendBang(toReceiver: "pause")
    }
    
    func unpause() {
        seqPatch.sendBang(toReceiver: "unpause")
    }
    
    func stop() {
        seqPatch.sendBang(toReceiver: "stop")
    }
    
    func fadeOutAndStop(msec: Float = 300) {
        seqPatch.sendFloat(msec, toReceiver: "fadeout")
    }
    
    func setVolume(level: Float, msec: Float = 300) {
        seqPatch.sendList([level, msec], toReceiver: "volume")
    }
    
    func setTempo(tempo: Float, msec: Float = 300) {
        seqPatch.sendList([tempo, msec], toReceiver: "tempo")
    }
    
    func setPitchOffset(halftones: Float) {
//        for track in tracks.values {
//            track.trackPatch.sendFloat(halftones, toReceiver: "pitch-offset")
//        }
    }
    
    func setContinue(cntue: Bool) {
        seqPatch.sendFloat(cntue ? 1 : 0, toReceiver: "continue")
    }
    
    
    var blocks = [Block]()
    func playBlockNext(nextBlock: Block) {
        // retain the block sothe patch stays open
        blocks.append(nextBlock)
        nextBlock.readyForPlaying()
        seqPatch.sendFloat(Float(nextBlock.blockPatch.dollarZero), toReceiver:"next-block")
        nextBlock.blockPatch.sendSymbol(String(seqPatch.dollarZero), toReceiver: "set-seq")
    }
}

class HermesPlayer {
    
    let masterPatch = PdFile.openFileNamed("master.pd", path: patchDirectoryPath) as PdFile
    
    var sequences = [String : Sequence]()
    
    // libpd for iOS objects
    
    let audioController = PdAudioController()
    let dispatcher = PdDispatcher()
    
    init() {
        let pdStatus = audioController.configureAmbientWithSampleRate(44100, numberChannels: 2, mixingEnabled: true)
        if Int(pdStatus.value) != PdAudioStatusSwift.OK.rawValue {
            println("Audio Controller configuration failed")
        }
        
        audioController.active = true
        
        PdBase.setDelegate(dispatcher)
    }
}