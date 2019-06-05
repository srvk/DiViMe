#!/usr/bin/env python

"""
This script converts an eaf file into a txt file 
containing the following information :

    onset offset transcription receiver speaker_tier

It can be run either on a single eaf file,
or on a whole folder containing eaf files.

Example of use :
    python tools/eaf2txt.py -i data/0396.eaf    # One one file
    python tools/eaf2txt.py -i data/            # On a whole folder

About the naming convention of the output :
    For each file called input_file.eaf,
    the result will be stored in input_file.txt
"""

import pympi as pmp
import argparse
import os
import glob
import sys
reload(sys)
sys.setdefaultencoding('utf8')

def eaf2txt(path_to_eaf, output_folder, cleanup=False, format='okko'):
    """
    Convert an eaf file to the txt format by extracting the onset, offset, ortho,
    and the speaker tier. Note that the ortho field has been made by a human and needs
    to be cleaned up.

    Parameters
    ----------
    path_to_eaf :   path to the eaf file.

    Write a txt whose name is the same than the eaf's one in output_folder
    """
    basename = os.path.splitext(os.path.basename(path_to_eaf))[0]
    output_path = os.path.join(output_folder, basename + '.txt')
    output_file = open(output_path, 'w')
    EAF = pmp.Elan.Eaf(path_to_eaf)
    tiers = EAF.tiers
    tiers = {key: value for key, value in tiers.items() if key.startswith(('xds@', 'vcm@'))}
    for tier in tiers:
        try:
            annotations = EAF.get_annotation_data_for_tier(tier)
        except KeyError:
            print("Tier %s ignored..." %tier)
        for annotation in annotations:
            parameters = EAF.get_parameters_for_tier(tier)
            if 'PARTICIPANT' in parameters:
                if len(annotation) == 4:
                    onset, offset, receiver, transcript = annotation[0], annotation[1], annotation[2], annotation[3]
                elif len(annotation) == 3:
                    onset, offset, receiver, transcript = annotation[0], annotation[1], '', annotation[2]
                else:
                    raise ValueError("Format unknown : %s\n" % annotation)
                speaker = parameters['PARTICIPANT']

                if cleanup:
                    transcript = clean_up_annotation(transcript)
                if format == 'okko':
                    output_file.write("%d\t%d\t%s\t%s\t%s\n" % (onset, offset, str(receiver), str(transcript), str(speaker)))
                elif 'LINGUISTIC_TYPE_REF' in parameters and parameters['LINGUISTIC_TYPE_REF'] == 'XDS':
                    output_file.write("%s\t%d\t%d\t%s\t%s\t%s\t%s\t%s\n" % (str(speaker), onset, offset, str(receiver), 'NA', 'NA', 'NA', str(transcript)))
                elif 'LINGUISTIC_TYPE_REF' in parameters and parameters['LINGUISTIC_TYPE_REF'] == 'VCM':
                    l=len(str.split(str(transcript)))
                    lex='0' if l == 0 else 'W'
                    mwu='M' if l  > 1 else '1'
                    output_file.write("%s\t%d\t%d\t%s\t%s\t%s\t%s\t%s\n" % (str(speaker), onset, offset, 'NA', str(receiver), lex, mwu, str(transcript)))
                else:
                    pass

    output_file.close()

def main():
    parser = argparse.ArgumentParser(description="convert .eaf into .rttm")
    parser.add_argument('-i', '--input', type=str, required=True,
                        help="path to the input .eaf file or the folder containing eaf files.")
    parser.add_argument('-f', '--format', type=str, required=False, default='okko',
                        help="format flag, 'okko' or 'marisa'.")
    args = parser.parse_args()

    # Removing extra beginning / that might break the code
    if args.input[0] == '/':
        args.input = args.input[1:]
        
    # Initialize the output folder as the same folder than the input
    # if not provided by the user.
    if args.input[-4:] == '.eaf':
        output = os.path.dirname(args.input)
    else:
        output = args.input

    data_dir = '/vagrant'

    args.input = os.path.join(data_dir, args.input)

    output = os.path.join(data_dir, output)
    if not os.path.isdir(output):
        os.mkdir(output)

    if args.input[-4:] == '.eaf':   # A single file has been provided by the user
        eaf2txt(args.input, output, format=args.format)
    else:                           # A whole folder has been provided
        eaf_files = glob.iglob(os.path.join(args.input, '*.eaf'))
        for eaf_path in eaf_files:
            print("Processing %s" % eaf_path)
            eaf2txt(eaf_path, output, format=args.format)

if __name__ == '__main__':
    main()
