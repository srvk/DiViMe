#!/usr/bin/env python
"""
written in python3.5

script for translating .eaf annotation files into .rttm format

WARNING: this version results in a loss of information since .rttm
only keeps speaker ID regardless of the nature of the speech (whereas
.eaf contains additional information such as speech nature e.g. MWU, VCM ...)

This information might be recovered in an advanced version of this script

"""


import pympi as pmp
import argparse
import os


def eaf2rttm(path_to_eaf, path_to_write_rttm):
    """
    function to write a new .rttm file which is a transcription of the .eaf
    given as input

    """
    
    sampling_freq = 1000
    
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
    
    with open(os.path.join(path_to_write_rttm, name + ".rttm"), "w") as rttm:
    
        for participant in participants:
            if participant not in EAF.tiers.keys():
                continue

            for _, val in EAF.tiers[participant][0].items():
                
                start = val[0]
                end = val[1]

                t0 = float(EAF.timeslots[start]) / sampling_freq
                length = float(EAF.timeslots[end]) / sampling_freq - t0

                rttm.write(u"SPEAKER {} {} {} {} {} {} {} {}\n".format
                           (name, 1, "%.2f" % t0, "%.2f" % length, "<NA>", "<NA>", participant, 1 ))


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description="convert .eaf into .rttm")
	parser.add_argument('-i', '--input', type=str, required=True,
                            help="path to the input .eaf file.")
	parser.add_argument('-o', '--output', type=str, required=True,
                            help="path to the folder in which to write the output."
                            "The output .rttm file will have the same name as the "
                            "input file - except for the extension")
	args = parser.parse_args()

eaf2rttm(args.input, args.output)
