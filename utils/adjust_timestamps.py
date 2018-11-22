#!/usr/bin/env python
#
#
import pympi as pmp
import shutil
import os
import argparse
import subprocess
from collections import defaultdict
from operator import itemgetter


def eaf2rttm(path_to_eaf):
    """
    function to write a new .rttm file which is a transcription of the .eaf
    given as input

    """

    # in EAF, timestamps are in milliseconds, convert them to seconds
    # TODO read scale from header of EAF
    sampling_freq = 1000.0

    print('\n')
    # read eaf file
    EAF = pmp.Elan.Eaf(path_to_eaf)

    participants = []

    # gather all the talker's names
    for k in EAF.tiers.keys():

        if 'PARTICIPANT' in EAF.tiers[k][2].keys():

            if EAF.tiers[k][2]['PARTICIPANT'] not in participants:

                participants.append(EAF.tiers[k][2]['PARTICIPANT'])

    print('participants: {}'.format(participants))

    base = os.path.basename(path_to_eaf)
    name = os.path.splitext(base)[0]

    print('parsing file: {}'.format(name))

    # get the begining, ending and transcription for each annotation of
    # each tier
    rttm = []
    for participant in participants:
        if participant not in EAF.tiers:
            continue
        for _, val in EAF.tiers[participant][0].items():
            # Get timestamps
            start = val[0]
            end = val[1]

            t0 = EAF.timeslots[start] / sampling_freq
            length = EAF.timeslots[end] / sampling_freq - t0

            # get transcription
            transcript = val[2]

            rttm.append((name, t0, length, transcript, participant))

    return rttm

def eaf2rttm_CAS(path_to_eaf):
    """
    function to write a new .rttm file which is a transcription of the .eaf
    given as input

    """

    sampling_freq = 1000.0

    print('\n')
    EAF = pmp.Elan.Eaf(path_to_eaf)

    participants = []

    for k in EAF.tiers.keys():

        if 'PARTICIPANT' in EAF.tiers[k][2].keys():

            if EAF.tiers[k][2]['PARTICIPANT'] not in participants:

                participants.append(EAF.tiers[k][2]['PARTICIPANT'])

    print('participants: {}'.format(participants))

    base = os.path.basename(path_to_eaf)
    name = os.path.splitext(base)[0]

    print('parsing file: {}'.format(name))

    # get the begining, ending and transcription for each annotation of
    # each tier
    rttm = []
    for participant in participants:

        for _, val in EAF.tiers[participant][0].items():
            # Get timestamps
            start = val[0]
            end = val[1]

            t0 = EAF.timeslots[start] / sampling_freq
            length = EAF.timeslots[end] / sampling_freq - t0

            # get transcription
            transcript = val[2]

            rttm.append((name, t0, length, transcript, participant))
    return rttm

def write_rttm(output, rttm_path, annotations):
    """ write annotations to rttm_path"""

    with open(os.path.join(output, rttm_path), 'w') as fout:
        rttm_name = rttm_path.split('.')[0]
        print len(annotations)
        for name, t0, length, transcript, participant in annotations:
            fout.write(u"SPEAKER\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n".format
                       (rttm_name, 1, "%.3f" %t0, "%.3f" %length, transcript,
                        "<NA>", participant, 1 ))

def get_all_on_offs(eaf):
    """ 
        Return all the annotated intervals from the current file
    """
    EAF = pmp.Elan.Eaf(eaf)

    all_intervals = EAF.tiers['on_off'][0]

    # get the segments delimited for "on_off" tier,
    # as those give the timestamps between which are the annotations
    on_offs = []
    for key in all_intervals:
        interv = all_intervals[key]
        beg_end = interv[2]
        beg, end = [float(time) for time in beg_end.split('_')]
        # store in seconds, not milliseconds
        on_offs.append((beg/1000.0, end/1000.0))

    return on_offs

def get_all_on_offs_CAS(eaf):
    """
        Return all the annotated intervals from the current file
    """
    EAF = pmp.Elan.Eaf(eaf)

    all_intervals = EAF.tiers['code'][0]

    on_offs = []
    for key in all_intervals:
        interv = all_intervals[key]
        beg_end = interv[2]
        _beg = interv[0]
        _end = interv[1]
        beg = EAF.timeslots[_beg]
        end = EAF.timeslots[_end]

        # store in seconds, not milliseconds
        on_offs.append((beg/1000.0, end/1000.0))

    return on_offs

def cut_audio(on_offs, input_audio, dest):
    """
        Extract from the daylong recordings the small parts that have
        been annotated
    """

    # for each annotated segment, call sox to extract the part from the
    # wav file
    # Also, write each onset/offset with 6 digits
    for on, off in on_offs:
        audio_base = os.path.splitext(input_audio)[0]
        wav_name = os.path.basename(audio_base)
        dir_name = os.path.split(os.path.dirname(audio_base))[-1]

        # add the necessary number of 0's to the onsets/offsets
        # to have 6 digits
        str_on = str(int(on))
        str_off = str(int(off))

        str_on = (6 - len(str_on)) * '0' + str_on
        str_off = (6 - len(str_off)) * '0' + str_off
        output_audio = '_'.join([dir_name, wav_name,
                                 str_on, str_off]) + '.wav'
        cmd = ['sox', input_audio, os.path.join(dest,  output_audio),
               'trim', str(on), str(off - on)]
        print " ".join(cmd)
        subprocess.call(cmd)

def extract_from_rttm(on_offs, rttm):
    """
        For each minute of annotation, extract the annotation of that minute
        from the transcription and write a distinct .rttm file with all the
        timestamps with reference to the begining of that segment.
    """
    sorted_rttm = sorted(rttm, key=itemgetter(1))

    # create dict { (annotated segments) -> [annotation] }
    extract_rttm = defaultdict(list)
    for on, off in on_offs:
        for name, t0, length, transcript, participant in sorted_rttm:
            end = t0 + length
            if (on <= t0 < off) or (on <= end < off):
                # if the current annotation is (at least partially)
                # contained in the current segment, append it.
                # Adjust the segment to strictly fit in on-off
                t0 = max(t0, on)
                end = min(end, off)
                length = end - t0
                extract_rttm[(on, off)].append((name, t0 - on,
                                                length,
                                                transcript, participant))
            elif (on > t0) and (end >= off):
                # if the current annotation completely contains the annotated
                # segment, add it also. This shouldn't happen, so print a 
                # warning also.
                print('Warning: speaker speaks longer than annotated segment.\n'
                      'Please check annotation from speaker {},'
                      'between {} {}, segment {} {}.\n'.format(name, t0,
                                                               end, on, off))
                extract_rttm[(on, off)].append((name, 0, off - on,
                                                transcript, participant))
            elif (end < on):
                # wait until reach segment
                continue
            elif (t0 >= off):
                # no point in continuing further since the rttm is sorted.
                break

    return extract_rttm

def main():
    """
        Take as input one eaf and wav file, and extract the segments from the
        wav that have been annotated.
    """
    parser = argparse.ArgumentParser(description="extract annotated segments")
    parser.add_argument('eaf', type=str,
                        help='''Path to the transcription of the wave file, '''
                        ''' in eaf format.''')
    parser.add_argument('wav', type=str,
                        help='''Path to the wave file to treat''')
    parser.add_argument('output', type=str)
    parser.add_argument('-c', '--CAS', action='store_true',
                        help='''By default the script detects the segments'''
                        ''' using the "on_off" tier. For the CAS corpus,'''
                        ''' we should use the "code" tier.\n'''
                        ''' Enable this option when treating the CAS corpus''')
    args = parser.parse_args()

    output = args.output
    print output
    #if not os.path.isdir( os.path.join(output, 'treated')):
    #    os.makedirs(os.path.join(output, 'treated'))
    #if not os.path.isdir( os.path.join(output, 'treated', 'talker_role')):
    #    os.makedirs(os.path.join(output, 'treated', 'talker_role'))

    if args.CAS:
        # read transcriptions
        complete_rttm = eaf2rttm_CAS(args.eaf)

        # extract annotated segments
        on_offs = get_all_on_offs_CAS(args.eaf)
    else:
        # read transcriptions
        complete_rttm = eaf2rttm(args.eaf)

        # extract annotated segments
        on_offs = get_all_on_offs(args.eaf)

    # cut audio files according to on_off/code tier in eaf annotations
    cut_audio(on_offs, args.wav, output)

    # store in dict the annotations to write in rttm format
    extract_rttm = extract_from_rttm(on_offs, complete_rttm)

    # write one rttm file per on_off/tier segment
    for key in extract_rttm:
        base = os.path.basename(args.eaf)

        # get the name of the corpus by taking the name of the folder and removing "raw"
        dir_name = os.path.split( os.path.dirname(args.eaf) )[-1].split('_')[-1]

        name = os.path.splitext(base)[0]
        # check is initials of annotator are in eaf name
        if '-' in name:
            name = name.split('-')[0]

        # add 0's to have exactly 6 digits (i.e. 1 second is 000001 s)
        str_on = str(int(key[0]))
        str_off = str(int(key[1]))

        str_on = (6 - len(str_on)) * '0' + str_on
        str_off = (6 - len(str_off)) * '0' + str_off

        rttm_path = '_'.join([dir_name, name,
                              str_on, str_off]) + '.rttm'
        write_rttm(output, rttm_path, extract_rttm[key])


if __name__ == '__main__':
    main()
