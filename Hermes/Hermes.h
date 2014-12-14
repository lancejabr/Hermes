//
//  Hermes.h
//  Hermes Showcase
//
//  Created by Lance Jabr on 11/22/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

#ifndef __Hermes_Showcase__Hermes__
#define __Hermes_Showcase__Hermes__

#include <stdio.h>

// Initializes the audio system. Must be called once before system is started
int HermesInit();


void HermesMasterVolume(float level, float msec);


typedef struct _HermesSequence{} HermesSequence;
typedef struct _HermesBlock{} HermesBlock;
typedef struct _HermesVoicePattern{} HermesVoicePattern;
typedef struct _HermesVoiceObject{} HermesVoiceObject;



HermesSequence *HermesSequenceCreate();
void HermesSequenceDestroy();
void HermesSequenceStart(HermesSequence *seq);
void HermesSequencePause(HermesSequence *seq);
void HermesSequenceUnpause(HermesSequence *seq);
void HermesSequenceStop(HermesSequence *seq);
void HermesSequenceFadeOutAndStop(HermesSequence *seq, float msec);
void HermesSequenceSetVolume(HermesSequence *seq, float level, float msec);
void HermesSequenceSetTempo(HermesSequence *seq, float tempo);
void HermesSequenceSetTransposition(HermesSequence *seq, float semitones);
void HermesSequenceSetLoop(HermesSequence *seq, int loop);
void HermesSequenceScheduleBlockNext(HermesSequence *seq, HermesBlock *block);



HermesBlock *HermesBlockCreate();
void HermesBlockDestroy(HermesBlock *block);
void HermesBlockAddVoicePattern(HermesBlock *block, HermesVoicePattern *vp);
void HermesBlockRemoveVoicePattern(HermesBlock *block, HermesVoicePattern *vp);



HermesVoicePattern *HermesVoicePatternCreateFromMIDI(const char* path);
void HermesVoicePatternDestroy(HermesVoicePattern *vp);
void HermesVoicePatternAddVoiceObject(HermesVoicePattern *vp, HermesVoiceObject *vo);
void HermesVoicePatternRemoveVoiceObject(HermesVoicePattern *vp, HermesVoiceObject *vo);
void HermesVoicePatternRemoveAllVoiceObjects(HermesVoicePattern *vp);
void HermesVoicePatternSetVolume(HermesVoicePattern *vp, float level, float msec);



HermesVoiceObject *HermesVoiceObjectCreateFromPd(const char *path);
void HermesVoiceObjectDestroy(HermesVoiceObject *vo);
void HermesVoiceObjectSetVolume(HermesVoiceObject *vo, float level, float msec);
void HermesVoiceObjectSetPan(HermesVoiceObject *vo, float level, float msec);
int HermesVoiceObjectGetPatch(HermesVoiceObject *vo);




#endif /* defined(__Hermes_Showcase__Hermes__) */
