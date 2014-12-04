//
//  MIDIImport.c
//  Hermes-Swift
//
//  Created by Lance Jabr on 10/14/14.
//  Copyright (c) 2014 Lance Jabr. All rights reserved.
//

#include "MIDIImport.h"

MidiEvent *MidiEventMake() {
	MidiEvent *midiEvent = (MidiEvent *)calloc(1, sizeof(MidiEvent));

	return midiEvent;
}

void MidiEventFree(MidiEvent *e) {
	free(e->data);
	free(e);
}


MidiTrack *MidiTrackMake() {
	MidiTrack *midiTrack = (MidiTrack *)calloc(1, sizeof(MidiTrack));

	midiTrack->sequenceNumber = -1;

	return midiTrack;
}

void MidiTrackFree(MidiTrack *mt){
	for (int i = 0; i < mt->eventCount; ++i)
	{
		MidiEventFree(mt->events[i]);
	}
	free(mt->events);
	free(mt->trackName);
	free(mt->instName);
	free(mt);
}



MidiFile *MidiFileMake() {
	MidiFile *midiFile = (MidiFile *)calloc(1, sizeof(MidiFile));

	return midiFile;
}

void MidiFileFree(MidiFile *mf) {
	for (int i = 0; i < mf->trackCount; ++i)
	{
		MidiTrackFree(mf->tracks[i]);
	}
	free(mf->tracks);
	free(mf);
}

void MidiFileAddTrack(MidiFile *midiFile, MidiTrack *newTrack) {
	midiFile->tracks = (MidiTrack **)realloc(midiFile->tracks, sizeof(MidiTrack *) * (midiFile->trackCount + 1));
	midiFile->tracks[midiFile->trackCount] = newTrack;
	midiFile->trackCount++;
}




int readVarLengthValue(FILE *midiStream) {
	int currByte;
	int toReturn = 0;

	do {
		// get the next byte
		currByte = fgetc(midiStream);
        
        if (currByte == EOF) {
            return -1;
        }

		// shift to get rid of the first bit and combine it with the running value
		toReturn = (toReturn << 7) | (currByte & 0b01111111);
        
	} while (currByte & 0b10000000); // stop when the first bit of the newest byte was 0

	return toReturn;
}

MidiEvent *readMidiEvent(FILE *midiStream, int *runningStatus){

	// find out when the byte occurs
	int deltaTicks = readVarLengthValue(midiStream);
    
//    printf("delta:%i\n", deltaTicks);

	if(deltaTicks == -1 || feof(midiStream)) { return NULL; }

	// find out its type
	int eventType = fgetc(midiStream);

	if(feof(midiStream)) { return NULL; }

	// make an event struct
	MidiEvent *midiEvent = MidiEventMake();
	midiEvent->deltaTicks = deltaTicks;

	// first check running status
	if (eventType < 0x80) // if we got a data byte, we should use the running status
	{
		// put the byte back
		ungetc(eventType, midiStream);
		// and choose the running status
		eventType = *runningStatus;
	}
	else if (eventType >= 0x80 && eventType <= 0xef) // channel voice/mode events change the running status
	{
		*runningStatus = eventType;
	}
	else if ((eventType >= 0xf0 && eventType <= 0xf7) || eventType == 0xff) // system common messages and meta messages reset the running status
	{
		*runningStatus = 0;
	}
	else {} // realtime messages do not affect the running status (but we should never see these anyway)
	

	// now parse the actual event
	if (eventType >= 0x80 && eventType <= 0x8f) // midi note off event
	{ 
		// just pull out the key and velocity
		midiEvent->type = Note;
		int *noteData = (int *)calloc(2, sizeof(int));
		noteData[0] = fgetc(midiStream);
		fgetc(midiStream);
		noteData[1] = 0;
		midiEvent->data = noteData;
	}
	else if (eventType >= 0x90 && eventType <= 0x9f) // midi note on event
	{ 
		// just pull out the key and velocity
		midiEvent->type = Note;
		int *noteData = (int *)calloc(2, sizeof(int));
		noteData[0] = fgetc(midiStream);
		noteData[1] = fgetc(midiStream);
		midiEvent->data = noteData;
	}
    else if (eventType >= 0xb0 && eventType <= 0xbf) // controller event
    {
        switch (fgetc(midiStream)) {
            case 0x07: // volume
                midiEvent->type = VolumeControl;
                int *volumeData = (int *)calloc(1, sizeof(int));
                volumeData[0] = fgetc(midiStream);
                midiEvent->data = volumeData;
                break;
            case 0x0a: // pan
                midiEvent->type = PanControl;
                int *panData = (int *)calloc(1, sizeof(int));
                panData[0] = fgetc(midiStream);
                midiEvent->data = panData;
                break;
                
            default: // unsupported
                midiEvent->type = Unsupported;
                fgetc(midiStream); // read off data byte
                break;
        }
    }
	else if (eventType >= 0xa0 && eventType <= 0xef) // other channel voice/mode messages are not supported
	{
		midiEvent->type = Unsupported;

		// but we should read the extra bytes off
		fgetc(midiStream);
		if (eventType < 0xc0 || eventType > 0xdf) { fgetc(midiStream); }
	}
	else if (eventType == 0xf0 || eventType == 0xf7) // System-Exclusive events are not supported
	{
		midiEvent->type = Unsupported;

		// but we should read the extra bytes off
		while (fgetc(midiStream) != 0xf7) {}
	}
	else if (eventType == 0xf1) // MIDI Time Code Quarter Frame is not supported
	{
		midiEvent->type = Unsupported;

		// read its data byte off
		fgetc(midiStream);
	}
	else if (eventType == 0xf2) // song position # is not supported
	{
		midiEvent->type = Unsupported;

		// read its 2 data bytes off
		fgetc(midiStream);
		fgetc(midiStream);
	}
	else if (eventType == 0xf3) // Song select is not supported
	{
		midiEvent->type = Unsupported;

		// read its data byte off
		fgetc(midiStream);
	}
	else if (eventType >= 0xf4 && eventType <= 0xf6) // other system common messages are not suported and have no data bytes
	{
		midiEvent->type = Unsupported;
	}
	else if (eventType >= 0xf8 && eventType <= 0xfe) // a real time message is not supported (shouldn't be in a MIDI file...)
	{	
		midiEvent->type = Unsupported;
	}
	else if (eventType == 0xff) // meta message
	{
		int metaType = fgetc(midiStream);
		int metaLength = readVarLengthValue(midiStream);
        if (metaLength == -1) {
            MidiEventFree(midiEvent);
            return NULL;
        }
		int *metaData = (int *)malloc(sizeof(int) * metaLength);
		for (int i = 0; i < metaLength; ++i)
		{
			metaData[i] = fgetc(midiStream);
		}
		switch (metaType) {
			case 0x00: // Sequence Number
				midiEvent->type = SequenceNumber;
				midiEvent->data = metaData;
			break;
			case 0x03: // Track Name
			{
				midiEvent->type = TrackName;
				char *nameData = (char *)calloc(metaLength + 1, sizeof(char));
				for (int i = 0; i < metaLength; ++i)
				{
					nameData[i] = (char)metaData[i];
				}
				nameData[metaLength] = '\0';
				midiEvent->data = nameData;
				free(metaData);
			}
			break;
			case 0x04: // Instrument Name
			{
				midiEvent->type = InstrumentName;
				char *nameData = (char *)calloc(metaLength + 1, sizeof(char));
				for (int i = 0; i < metaLength; ++i)
				{
					nameData[i] = (char)metaData[i];
				}
				nameData[metaLength] = '\0';
				midiEvent->data = nameData;
				free(metaData);
			}
			break;
			case 0x51: // Tempo Setting
				midiEvent->type = TempoSetting;
				int *tempoData = (int *)calloc(1, sizeof(int));
				for (int i = 0; i < metaLength; ++i)
				{
					// assemble the microseconds per quarter from the data
					*tempoData = (*tempoData << 8) | metaData[i];
				}
				midiEvent->data = tempoData;
				free(metaData);
			break;
			case 0x54: // SMTPE offset
				midiEvent->type = SMTPEOffset;
				midiEvent->data = metaData;
			break;
			case 0x58: // Time Signature
				midiEvent->type = TimeSignature;
				midiEvent->data = metaData;
			break;
			case 0x2f: // End of track
				midiEvent->type = EndOfTrack;
			break;
			default: // Other
				midiEvent->type = Unsupported;
		}
	}

	return midiEvent;
}


MidiTrack *readMidiTrack(FILE *midiStream) {
	// look for the start of a track
	if (fgetc(midiStream) != 'M' || fgetc(midiStream) != 'T' || fgetc(midiStream) != 'r' || fgetc(midiStream) != 'k') {
		return NULL;
	}

	// read track chunk size
	fgetc(midiStream); fgetc(midiStream); fgetc(midiStream); fgetc(midiStream);

	// initalize counters for the events
	int eventCount = 0;
	int eventArraySize = 100;

	int currTick = 0;

	MidiEvent **events = (MidiEvent **)malloc(sizeof(MidiEvent *) * eventArraySize);

	// running status
	int runningStatus = 0;

	MidiTrack *midiTrack = MidiTrackMake();
    
    int noteCnt = 0;

	while (1) {
		// read the event
		MidiEvent *newEvent = readMidiEvent(midiStream, &runningStatus);
        
        // stop if we reached end of track
        if (newEvent == NULL || newEvent->type == EndOfTrack) {
            
            break;
        }

		// get the time info
		currTick += newEvent->deltaTicks;

		// if it is unsupported, ignore it
		if (newEvent->type == Unsupported) { 
			MidiEventFree(newEvent);
			continue; 
		}

		// if it is the track name, name the track
		if (newEvent->type == TrackName) {
			midiTrack->trackName = (char *)calloc(strlen((char *)newEvent->data) + 1, sizeof(char));
			strcpy(midiTrack->trackName, newEvent->data);
			MidiEventFree(newEvent);
			continue;
		}

		// if it the instrument name, name the instrument
		if (newEvent->type == InstrumentName) {
			midiTrack->instName = (char *)calloc(strlen((char *)newEvent->data) + 1, sizeof(char));
			strcpy(midiTrack->instName, newEvent->data);
			MidiEventFree(newEvent);
			continue;
		}

		// record the seq number
		if (newEvent->type == SequenceNumber) {
			midiTrack->sequenceNumber = *((int *)newEvent->data);
			MidiEventFree(newEvent);
			continue;
		}

		// record the SMTPE offset
		if (newEvent->type == SMTPEOffset) {
			memcpy(&midiTrack->SMTPEOffset, newEvent->data, 5*sizeof(int));
//            printf("SMPTYE: %i,%i,%i,%i,%i\n", midiTrack->SMTPEOffset[0], midiTrack->SMTPEOffset[1], midiTrack->SMTPEOffset[2], midiTrack->SMTPEOffset[3], midiTrack->SMTPEOffset[4]);
			continue;
		}

//        if (newEvent->type == Note) {
//            printf("Note %i\n", ++noteCnt);
//        } else {
//            printf("Noooooooooooope\n");
//        }
        
		// otherwise add it to the track and set its absolute time
		events[eventCount++] = newEvent;
		newEvent->absoluteTicks = currTick;

		// expand the array if necessary 
		if (eventCount == eventArraySize) {
			eventArraySize = eventArraySize * 2;
			events = realloc(events, sizeof(MidiEvent *) * eventArraySize);
		}
	}

	midiTrack->events = realloc(events, sizeof(MidiEvent *) * eventCount);
	midiTrack->eventCount = eventCount;

	return midiTrack;
}



MidiFile *readMidiFile(const char* path) {
	// open the file
	FILE *midiStream = fopen(path, "r");

    
    if (midiStream == NULL) { printf("File Error\n"); return NULL; }
	
	// read in "MThd"
	if (fgetc(midiStream) != 'M' || fgetc(midiStream) != 'T' || fgetc(midiStream) != 'h' || fgetc(midiStream) != 'd') { return NULL; }
    
	// read the header length (should be 6, basically we can ignore it)
    if (fgetc(midiStream) << 24 | fgetc(midiStream) << 16 | fgetc(midiStream) << 8 | fgetc(midiStream) != 6) {
        printf("Warning: MIDI file header length isnot 6 bytes...\n");
    }

	// create the MidiFile
	MidiFile *midiFile = MidiFileMake();

	// read the file type
	midiFile->type = fgetc(midiStream) << 8 | fgetc(midiStream);

	// read in claimed track count
	midiFile->hdTrackCount = fgetc(midiStream) << 8 | fgetc(midiStream);

	// read in ticks per quarter note
	int tick1 = fgetc(midiStream);
	int tick2 = fgetc(midiStream);

	if (tick1 & 1 << 7) { // if it is SMPTE calculate ticks per second
		midiFile->hdTicksPerSecond = ~(tick1 - 1) * tick2;
	} else { // else record ticks per quarter
		midiFile->hdTicksPerQuarter = tick1 << 8 | tick2;
	}


	// read in all the tracks
	for (MidiTrack *currTrack = readMidiTrack(midiStream); currTrack != NULL; currTrack = readMidiTrack(midiStream))
	{
		MidiFileAddTrack(midiFile, currTrack);
	}
    
    // assemble the tracks into a master
    midiFile->masterTrack = MidiTrackMake();
    
    // the event count for each normal track
    int eventCountForTrack[midiFile->trackCount];
    // the current event candidate for each track
    int currEventIdxForTrack[midiFile->trackCount];
    
    // count the total events
    for (int i = 0; i < midiFile->trackCount; i++) {
        eventCountForTrack[i] = midiFile->tracks[i]->eventCount;
        currEventIdxForTrack[i] = 0;
        midiFile->masterTrack->eventCount += eventCountForTrack[i];
    }
    
//    printf("%i\n", midiFile->masterTrack->eventCount);
    
    // allocate space for the event pointers
    midiFile->masterTrack->events = (MidiEvent **)calloc(midiFile->masterTrack->eventCount, sizeof(MidiEvent *));
    
    int nextTrackI;
    
    // for each event...
    for (int eventI = 0; eventI<midiFile->masterTrack->eventCount; eventI++) {
        // reset the next track index
        nextTrackI = -1;
        
//        printf("here: %i\n", eventI);

        // find which of the tracks has the next event
        for (int candidateTrackI = 0; candidateTrackI < midiFile->trackCount; candidateTrackI++) {
//            printf("candidte: %i\n", candidateTrackI);

            // if there are no more events in this track, skip it
            if (currEventIdxForTrack[candidateTrackI] == eventCountForTrack[candidateTrackI]) {
                continue;
            }
            
            // if there is no current canditate track, use this one
            if (nextTrackI == -1) {
                nextTrackI = candidateTrackI;
                continue;
            }

            // if this event occurs before the current option, use this one instead
            if (midiFile->tracks[candidateTrackI]->events[currEventIdxForTrack[candidateTrackI]]->absoluteTicks < midiFile->tracks[nextTrackI]->events[currEventIdxForTrack[nextTrackI]]->absoluteTicks) {
                nextTrackI = candidateTrackI;
            }
        }
        

        
        // add that event to the master track
        
        midiFile->masterTrack->events[eventI] = midiFile->tracks[nextTrackI]->events[currEventIdxForTrack[nextTrackI]];
        
//        printf("here\n");

        // increment the currEventIdx for that track
        currEventIdxForTrack[nextTrackI]++;
//        printf("%i: %i\n", nextTrackI, currEventIdxForTrack[nextTrackI]);
    }
    
	return midiFile;
}

void MidiTrackPrint(MidiTrack *currTrack) {
    printf("Track Name: %s\n", currTrack->trackName);
    printf("Events: %i\n", currTrack->eventCount);
    printf("Instrument Name: %s\n", currTrack->instName);
    printf("Seq #: %i\n", currTrack->sequenceNumber);
    printf("SMTPEOffset: %i:%i:%i:%i:%i\n", currTrack->SMTPEOffset[0],currTrack->SMTPEOffset[1],currTrack->SMTPEOffset[2],currTrack->SMTPEOffset[3],currTrack->SMTPEOffset[4]);
    
    printf("\n events: \n");
    
    for (int k = 0; k < currTrack->eventCount; ++k)
    {
        MidiEvent *currEvent = currTrack->events[k];
        
        printf("%i - %i (%i) - ", k, currEvent->absoluteTicks, currEvent->deltaTicks);
        
        switch (currEvent->type) {
                            case Note:
                                printf("Note(key: %i, vel: %i)\n", ((int *)currEvent->data)[0], ((int *)currEvent->data)[1]);
                                break;
                            case TimeSignature:
                                printf("Time Signature : %i/%i \n  ticksPerQuarter: %i \n  32s per 24 ticks: %i\n", ((int *)currEvent->data)[0], (int)pow(2, ((int *)currEvent->data)[1]), ((int *)currEvent->data)[2], ((int *)currEvent->data)[3]);
                                break;
                            case TempoSetting:
                                printf("Tempo Set: %i msec per quarter\n", ((int *)currEvent->data)[0] / 1000);
                                break;
                            case EndOfTrack:
                                printf("End of Track\n");
                                break;
            default:
                printf("Event type: %i\n", currEvent->type);
        }
        
    }
}


void MidiFilePrint(MidiFile *midiFile) {
    printf("\nMidi File:\n");
    
    printf("Type: %i\n", midiFile->type);
    
    printf("hdTicksPerQuarter: %f\n", midiFile->hdTicksPerQuarter);
    printf("hdTicksPerSecond: %f\n", midiFile->hdTicksPerSecond);
    
    printf("Header Tracks: %i\n", midiFile->hdTrackCount);
    printf("Tracks: %i\n", midiFile->trackCount);
    
    
    for (int i = 0; i < midiFile->trackCount; ++i)
    {
        printf("\nTrack: %i\n", i);
        MidiTrackPrint(midiFile->tracks[i]);
    }
    
    printf("\nMaster Track:\n");
    MidiTrackPrint(midiFile->masterTrack);
    
}


//int main (int argc, char* argv[]){
//
//    MidiFile *midiFile = readMidiFile(argv[1]);
//
//    MidiFilePrint(midiFile);
//
//	return 0;
//}
