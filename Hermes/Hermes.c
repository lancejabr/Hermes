//
//  Hermes.c
//  Hermes Showcase
//
//  Created by Lance Jabr on 11/22/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

#include "Hermes.h"


//int test() {
//    
//    // a Pd patch that procedurally generates one "swoosh" of the helicopter blades is loaded as a voice object
//    char voPath[] = "the path of the Pd patch.pd";
//    HermesVoiceObject *chopperVO = HermesVoiceObjectCreateFromPd(voPath);
//    
//    // a MIDI file that contains one sixteenth note at 200 bpm
//    char vpPath[] = "the path of the MIDI file.mid";
//    HermesVoicePattern *chopperVP = HermesVoicePatternCreateFromMIDI(vpPath);
//    
//    // assign the voice object to the voice pattern
//    HermesVoicePatternAddVoiceObject(chopperVP, chopperVO);
//    
//    // create a block to contain this
//    HermesBlock *chopperBlock = HermesBlockCreate();
//    HermesBlockAddVoicePattern(chopperBlock, chopperVP);
//    
//    // create a sequence and set it to loop
//    HermesSequence *chopperSequence = HermesSequenceCreate();
//    HermesSequenceSetLoop(chopperSequence, 1);
//    
//    // schedule the block on the sequence
//    HermesSequenceScheduleBlockNext(chopperSequence, chopperBlock);
//    
//    // start the sequence and fade it in
//    HermesSequenceSetVolume(chopperSequence, 0, 0);
//    HermesSequenceStart(chopperSequence);
//    HermesSequenceSetVolume(chopperSequence, 1, 500);
//    
//    // adjust the tempo as needed
//    HermesSequenceSetTempo(chopperSequence, 1 + 0.2);
//    
//    
//    // create a block for the intro, and a block for the loop
//    HermesBlock *introBlock = HermesBlockCreate();
//    HermesBlock *loopBlock = HermesBlockCreate();
//    
//    // load each MIDI file as a voice pattern and assign them to the correct blocks
//    // the strings in the method calls should be changed to the actual paths for the MIDI assets
//    HermesVoicePattern *melodyIntroVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    HermesVoicePattern *counterIntroVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    HermesVoicePattern *bassIntroVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    
//    HermesBlockAddVoicePattern(introBlock, melodyIntroVP);
//    HermesBlockAddVoicePattern(introBlock, counterIntroVP);
//    HermesBlockAddVoicePattern(introBlock, bassIntroVP);
//    
//    // now do the same for the loop block
//    HermesVoicePattern *melodyLoopVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    HermesVoicePattern *counterLoopVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    HermesVoicePattern *bassFranticLoopVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    HermesVoicePattern *bassCalmLoopVP = HermesVoicePatternCreateFromMIDI("the/path/to/the/MIDI/file.mid");
//    
//    HermesBlockAddVoicePattern(loopBlock, melodyLoopVP);
//    HermesBlockAddVoicePattern(loopBlock, counterLoopVP);
//    HermesBlockAddVoicePattern(loopBlock, bassFranticLoopVP);
//    HermesBlockAddVoicePattern(loopBlock, bassCalmLoopVP);
//    
//    
//    // to play the arrangements we will need voice objects
//    // the arrangements for this piece involve three monophonic synthesizers, as well as a harp sampler and a bell sampler
//    // note that we are opening three copies of the same patch for the synths
//    HermesVoiceObject *melodyVO = HermesVoiceObjectCreateFromPd("the/path/to/the/synth/patch.pd");
//    HermesVoiceObject *counterVO = HermesVoiceObjectCreateFromPd("the/path/to/the/synth/patch.pd");
//    HermesVoiceObject *bassVO = HermesVoiceObjectCreateFromPd("the/path/to/the/synth/patch.pd");
//    
//    HermesVoiceObject *bellsVO = HermesVoiceObjectCreateFromPd("the/path/to/the/bells/patch.pd");
//    HermesVoiceObject *harpVO = HermesVoiceObjectCreateFromPd("the/path/to/the/harp/patch.pd");
//    
//    
//    // distribute the voice objects to their voice patterns
//    // the same voice object can be assigned to two different voice patterns
//    
//    // the intro is always played by the synths:
//    HermesVoicePatternAddVoiceObject(melodyIntroVP, melodyVO);
//    HermesVoicePatternAddVoiceObject(counterIntroVP, counterVO);
//    HermesVoicePatternAddVoiceObject(bassIntroVP, bassVO);
//    
//    // the loop is more complicated
//    // the melody may be played by the synth during the battle or by bells when the game is paused, so we add both voice objects to the voice pattern
//    HermesVoicePatternAddVoiceObject(melodyLoopVP, melodyVO);
//    HermesVoicePatternAddVoiceObject(melodyLoopVP, bellsVO);
//    
//    // the counterpoint in the loop is always synth, but is only played when the game is not paused
//    HermesVoicePatternAddVoiceObject(counterLoopVP, counterVO);
//    
//    // and we have two bass parts during the loop
//    // the frantic one is on during the battle and is played by a synth
//    HermesVoicePatternAddVoiceObject(bassFranticLoopVP, bassVO);
//    //and the calm one is played only when paused by the harp
//    HermesVoicePatternAddVoiceObject(bassCalmLoopVP, harpVO);
//    
//    
//    // when we start the loop section of the music, we want the bells off and the calm bass part off because those are only for when the game is paused
//    // we can set the volume on either the voice object (for bells) or the voice pattern (for the calm bass)
//    // setting the volume to zero turns the volume down but also prevents messages from being sent to that voice pattern or object
//    HermesVoiceObjectSetVolume(bellsVO, 0, 0);
//    HermesVoicePatternSetVolume(bassCalmLoopVP, 0, 0);
//    
//    
//    // when the user enters a battle, we are ready to start the music
//    // we create a sequence:
//    HermesSequence *battleSequence = HermesSequenceCreate();
//    // turn looping on (sequences loop their current block while no other block is scheduled next)
//    HermesSequenceSetLoop(battleSequence, 1);
//    // scheduling the intro block next makes it the current block, since there is no current block at the moment
//    HermesSequenceScheduleBlockNext(battleSequence, introBlock);
//    // Hermes starts playing the intro
//    HermesSequenceStart(battleSequence);
//    // and we schedule the loop block to be next
//    // if we scheduled no block next, the sequence would loop the intro. now the sequence will play the intro, move to this loop block and then keep looping that block until it receives further instruction.
//    HermesSequenceScheduleBlockNext(battleSequence, loopBlock);
//    
//    return 1;
//    
//}
//
//
//void battlePaused() {
//    // when the battle is paused, we need to make some adjustments to the arrangement
//    
//    // turn off the counterpoint voice pattern (this time with a short fade)
//    HermesVoicePatternSetVolume(counterLoopVP, 0, 300);
//    
//    // switch the melody from a synth to the bells
//    HermesVoiceObjectSetVolume(melodyVO, 0, 300);
//    HermesVoiceObjectSetVolume(bellsVO, 1, 300);
//    
//    // and switch from the frantic bass part to the calm one
//    HermesVoicePatternSetVolume(bassFranticLoopVP, 0, 300);
//    HermesVoicePatternSetVolume(bassCalmLoopVP, 1, 300);
//    
//    // lastly, we want the music to be played slower, to emphasize the calm
//    // the original MIDI file was at 160 BPM, so we can change the tempo to 96 BPM with a factor of .6
//    HermesSequenceSetTempo(battleSequence, 0.6);
//}
//
//void battleUnpaused() {
//    // when the battle is restarted, the arrangement changes back
//    
//    // turn on the counterpoint voice pattern
//    HermesVoicePatternSetVolume(counterLoopVP, 1, 300);
//    
//    // switch the melody back to the synth
//    HermesVoiceObjectSetVolume(melodyVO, 1, 300);
//    HermesVoiceObjectSetVolume(bellsVO, 0, 300);
//    
//    // and switch back to the frantic bass part
//    HermesVoicePatternSetVolume(bassFranticLoopVP, 1, 300);
//    HermesVoicePatternSetVolume(bassCalmLoopVP, 0, 300);
//    
//    // finally, restore the quicker tempo
//    HermesSequenceSetTempo(battleSequence, 1);
//}
//


