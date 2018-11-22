#!/usr/bin/env python
#
# author = julien karadayi
#
# This script converts transcription in Text Grid / Praat format
# to RTTM format. This is useful for evaluating performances of
# Speech detection algorithms with the *dscore* package,
# in the DiarizationVM virtual machine.
# The 1 and 0 labels are sent to " speech ", and no label / "x" label
# are not written in output (which means it is described as "non speech")

import os
import argparse
# from praatio import tgio
import tgt # tgt is better thant praatio for our application
           # because it allows to manipulate the timestamps,
           # which is something we cannot do with praatio.



def textgrid2rttm(textgrid):
    '''
        Take in input the path to a text grid,
        and output a dictionary of lists *{spkr: [ (onset, duration) ]}*
        that can easily be written in rttm format.
    '''
    # init output
    rttm_out = dict()

    # open textgrid
    #tg = tgio.openTextgrid(textgrid)
    tg = tgt.read_textgrid(textgrid)

    # loop over all speakers in this text grid
    #for spkr in tg.tierNameList:
    for spkr in tg.get_tier_names():

        spkr_timestamps = []
        # loop over all annotations for this speaker
        #for interval in tg.tierDict[spkr].entryList:
        for _interval in tg.get_tiers_by_name(spkr):
            for interval in _interval:

                bg, ed, label = interval.start_time,\
                              interval.end_time,\
                              interval.text

                #if label == "x":
                #    continue
                #elif label == "1" or label == "2":
                #    spkr_timestamps.append((bg, ed-bg))
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
    with open(basename_whole + '.rttm', 'w') as fout:
        for spkr in rttm_out:
            for bg, dur in rttm_out[spkr]:
                fout.write(u'SPEAKER {} 1 {} {} '
                           '<NA> <NA> {} <NA>\n'.format(
                             basename_whole.split('/')[-1], bg, dur, spkr))


if __name__ == '__main__':
    command_example = "python textgrid2rttm.py /folder/"
    parser = argparse.ArgumentParser(epilog=command_example)
    parser.add_argument('input_file',
                        help=''' Input File ''')
    parser.add_argument('output_file',
                        help='''Name of the output file in which to write''')

    args = parser.parse_args()

    rttm_out = textgrid2rttm(args.input_file)
    write_rttm(rttm_out, args.output_file)
    #if not os.path.isdir(args.output_folder_whole):
    #    os.makedirs(args.output_folder_whole)

    #for fold in os.listdir(args.input_folder):
    #    for fin in os.listdir(os.path.join(args.input_folder, fold)):
    #        if not fin.endswith('m1.TextGrid'):
    #            # read only text grids with full anotation
    #            # in this folder
    #            continue

    #        tg_in = os.path.join(args.input_folder, fold, fin)
    #        basename_whole = os.path.join(args.output_folder_whole,
    #                                      '_'.join(fin.split('_')[0:3]))

    #        # extract begining/durations of speech intervals
    #        rttm_out = textgrid2rttm(tg_in)
    #        # write 1 rttm per spkr transcribed in this text grid
    #        write_rttm(rttm_out, basename_whole)
