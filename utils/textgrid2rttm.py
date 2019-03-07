#!/usr/bin/env python
#
# author = julien karadayi
#
# This script converts transcription in Text Grid / Praat format
# to RTTM format. This is useful for evaluating performances of
# Speech detection algorithms with the *dscore* package,
# in the DiarizationVM virtual machine.
# All non-empty labels are written in the output; empty labels
# are not written in output (which means it is described as "non speech")

import os
import argparse
import tgt # tgt is better than praatio for our application
           # because it allows to manipulate the timestamps,
           # which is something we cannot do with praatio.
import glob
import sys

def textgrid2rttm(textgrid):
    '''
        Take in input the path to a text grid,
        and output a dictionary of lists *{spkr: [ (onset, duration) ]}*
        that can easily be written in rttm format.
    '''
    # init output
    rttm_out = dict()

    tg = tgt.io.read_textgrid(textgrid)
    # loop over all speakers in this text grid
    for spkr in tg.get_tier_names():
        spkr_timestamps = []
        # loop over all annotations for this speaker
        for _interval in tg.get_tiers_by_name(spkr):
            for interval in _interval:
                bg, ed, label = interval.start_time,\
                              interval.end_time,\
                              interval.text
                spkr_timestamps.append((bg, ed-bg))

        # add list of onsets, durations for each speakers
        rttm_out[spkr] = spkr_timestamps
    return rttm_out


def write_rttm(rttm_out, basename_whole):
    '''
        take a dictionary {spkr:[ (onset, duration) ]} as input
        and write on rttm output by speaker
    '''
    # write one rttm file for the whole wav, indicating
    # only regions of speech, and not the speaker
    with open(basename_whole, 'w') as fout:
        for spkr in rttm_out:
            for bg, dur in rttm_out[spkr]:
                fout.write(u'SPEAKER {} 1 {} {} '
                           '<NA> <NA> {} <NA>\n'.format(
                             basename_whole.split('/')[-1].replace('.rttm',''), bg, dur, spkr))


if __name__ == '__main__':
    command_example = "python textgrid2rttm.py /folder/"
    parser = argparse.ArgumentParser(epilog=command_example)
    parser.add_argument('input', help=''' Input file, or folder containing .TextGrid files''')

    args = parser.parse_args()

    if os.path.isfile(args.input):
        print("File found. Converting it.")
        rttm = textgrid2rttm(args.input)
        write_rttm(rttm, args.input.replace(".TextGrid", ".rttm"))
    elif os.path.isdir(args.input):
        print("Folder found. Scanning .TextGrid files.")
        for txtgr in glob.glob(os.path.join(args.input, "*.TextGrid")):
            print("Converting %s" % os.path.basename(txtgr))
            rttm = textgrid2rttm(txtgr)
            write_rttm(rttm, txtgr.replace(".TextGrid", ".rttm"))
    else:
        print("Nothing found.")
        sys.exit(1)
    print("Done.")