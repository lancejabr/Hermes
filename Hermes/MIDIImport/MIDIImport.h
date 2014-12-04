//
//  MIDIImport.h
//  Hermes-Swift
//
//  Created by Lance Jabr on 10/14/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

#ifndef __Hermes_Swift__MIDIImport__
#define __Hermes_Swift__MIDIImport__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


typedef enum _MidiEventType {
	Note=0, EndOfTrack=1, SMTPEOffset=2, TimeSignature=3, TempoSetting=4, TrackName=5, InstrumentName=6, SequenceNumber=7, VolumeControl=8, PanControl=9, Unsupported=100
} MidiEventType;



typedef struct  _MidiEvent {
	int absoluteTicks;
	int deltaTicks;

	int type;

	void *data;
    
} MidiEvent;

typedef struct  _MidiTrack{

	int SMTPEOffset[5];

	int sequenceNumber;

	char *trackName;
	char *instName;

	int eventCount;

	MidiEvent **events;

} MidiTrack;



typedef enum _MidiFileType {
	SingleTrack = 0, MultipleTracks = 1, MultipleSongs = 2
} MidiFileType;



typedef struct _MidiFile {
	// file type
	MidiFileType type;

	// timing info, according to the header
	float hdTicksPerQuarter, hdTicksPerSecond;

	// claimed track count from header
	int hdTrackCount;

	// actual encountered track count
	int trackCount;

	// tracks
	MidiTrack **tracks;
    
    // a track containing all the events in all the tracks
    MidiTrack *masterTrack;

} MidiFile;

MidiEvent *MidiEventMake();
void MidiEventFree(MidiEvent *e);

MidiTrack *MidiTrackMake();
void MidiTrackFree(MidiTrack *mt);

MidiFile *MidiFileMake();
void MidiFileFree(MidiFile *mf);

void MidiFilePrint(MidiFile *midiFile);

/*!
    @function readMidiFile
    @abstract Reads the midi file at path and returns the MidiFile from it.
    @param path
        The path of the .mid file to read.
 */
MidiFile *readMidiFile(const char* path);

#endif /* defined(__Hermes_Swift__MIDIImport__) */
