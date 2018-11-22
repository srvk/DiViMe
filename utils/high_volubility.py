#!/usr/bin/env python
#
# author = The ACLEW Team
#
"""
This script extract short snippets of sound (approx. 10s long),
and runs them through a SAD or diarization tool to detect chunks of audio with :

1) a lot of speech.
--> python tools/high_volubility.py file_path.wav --sad noisemes_sad

2) a lot of child speech
--> python tools/high_volubility.py file_path.wav --diar yunitate --mode CHI

3) a lot of parent-child conversations
--> python tools/high_volubility.py file_path.wav --diar yunitate --mode PCCONV

4) a lot of adults conversations with a child minimally aware
--> python tools/high_volubility.py file_path.wav --diar yunitate --mode ACCA
"""

import os
import sys
import re
import wave
import math
import numpy
import argparse
import subprocess

from operator import itemgetter


def get_audio_length(wav):
    """ Return duration of Wave file.

    Input: 
        wav: path to the wav file.

    Output:
        dur: float, duration, in seconds, of wav file.
    """

    audio = wave.open(wav, 'r')
    frames = audio.getnframes()
    rate = audio.getframerate()
    duration = frames / float(rate)
    audio.close()

    return duration


def select_onsets(duration, step):
    """ Return list of onsets on which this script will extract the chunks of
    10s

    Input:
        duration: float, duration of the daylong recording

    Ouput:
        onsets: list[floats], list the onsets on which this script will extract
                the chunks of 10s to be run through the SAD tools
    """
    return numpy.arange(0.0, duration, step)


def extract_chunks(wav, onset_list, chunk_size, temp):
    """ Given a list of onset and a length in seconds, extract a snippet of
    audio at each onset of this length. The extraction will be done using 
    SoX, called by subprocess.

    Input:
        wav: path to the wav file.
        onset_list: list[float], list of the onsets in the 'wav' file at which
                    we'll extract the segments
        chunk_size: float, length in seconds of the chunks of audio this script
                    will extract.

    Output:
        'temp': the output of this function is the set of small wav file of 
                'chunk_size' seconds in the temp folder.
                The name of the wav files will be: 
                    id_onset_length.wav
                where id is the name of the original wav file, onset is the
                onset at which the chunk occurs in the original wav file, and
                length is the length of the chunk.
    """

    # for each onset, call SoX using subprocess to extract a chunk.
    for on in onset_list:

        # get "id" basename of wav file
        basename = os.path.splitext(os.path.basename(wav))[0]

        # create name of output
        off = on + chunk_size
        str_on = (6 - len(str(on))) * '0' + str(on)
        str_off = (6 - len(str(off))) * '0' + str(off)

        chunk_name = '_'.join([basename, str_on, str_off])

        # call subprocess
        cmd = ['sox', wav,
                os.path.join(temp, '{}.wav'.format(chunk_name)),
               'trim', str(on), str(chunk_size)]
        subprocess.call(cmd)


def run_Model(temp_rel, temp_abs, sad, diar=None):
    """ When all the snippets of sound are extracted, and stored in the temp
        file, run them through a sad or diar tool, and keep
        the 10%% that have the most speech.
        By default, the function is on the SAD mode. That means that it will
        run a SAD model (by default noiseme). However, if the diar parameter is
        provided, this function will be on the diarization mode.

        Input:
            temp_rel: relative path to the temp folder in which the snippets of
                  sounds are stored. Here we need the relative path, not the
                  abs path, since the SAD tool will add the "/vagrant/" part of
                  the path.
            temp_abs: absolute path to the temp folder in which the snippets of
                  sounds are stored.
            sad:  name of the sad tool to be used to analyze the snippets of
                  sound
            diar: name of the diar tool to be used to analyze the snippets of
                  sound. Note that it will use that sad parameter as a choice
                  of SAD provider.

        Output:
            _:    In temp, the SAD analyses will be written in RTTM format.
    """
    if diar is not None: # Diarization mode
        if diar == 'yunitate':
            cmd = ['tools/{}.sh'.format(diar), '{}'.format(temp_rel)]
        elif diar == 'diartk':
            cmd = ['tools/{}.sh'.format(diar), '{}'.format(temp_rel), '{}'.format(sad)]
        else:
            cmd = ['exit 1']
    else: # SAD mode
        cmd = ['tools/{}.sh'.format(sad), '{}'.format(temp_rel)]

    subprocess.call(cmd)

    # After the model has finished running, remove the wav files
    for fin in os.listdir(temp_abs):
        if fin.endswith('.wav'):
            os.remove(os.path.join(temp_abs, fin))


def extract_base_name(filename, diar):
    """
    Giving a filename generated by a model and composed of :
    model_name + wav_filename + tbeg + tdur
    Extracts the base name composed of the three last elements.

    Input:
        filename:   a filename generated by a model
        diar:       a diarization model (if provided)

    Output:
        base :      wavfilename_tbeg_tdur
    """
    if diar == 'yunitate':
        base = filename.split('_')[1:]
    else:
        base = filename.split('_')[2:]

    base = os.path.splitext('_'.join(base))[0]
    return base


def detect_parent_child_conv(previous_activity, curr_activity, last_silence_dur):
    """
    Attempts to try if a turn-taking happened between a child and his/her parents

    Input:
        previous_activity:      the last activity amongst ['CHI', 'MAL', 'FEM']
        curr_activity:          the current activity amongst ['CHI', 'MAL', 'FEM']
        last_silence_dur:       the duration of the last silence

    Output:
        A boolean indicating if a turn-taking happened between a child and his/her parents
            True : a turn-taking happened
            False : nothing happened
    """
    if last_silence_dur <= 2.0:
        if (previous_activity == 'MAL' and curr_activity == 'CHI') or \
                (previous_activity == 'FEM' and curr_activity == 'CHI') or \
                (previous_activity == 'CHI' and curr_activity == 'MAL') or \
                (previous_activity == 'CHI' and curr_activity == 'FEM'):

            return True
    return False

def detect_adults_conv(previous_activity, curr_activity, last_silence_dur):
    """
    Attempts to try if a turn-taking happened between two adults

    Input:
        previous_activity:      the last activity amongst ['CHI', 'MAL', 'FEM']
        curr_activity:          the current activity amongst ['CHI', 'MAL', 'FEM']
        last_silence_dur:       the duration of the last silence

    Output:
        A boolean indicating if a turn-taking happened between a child and his/her parents
            True : a turn-taking happened
            False : nothing happened
    """
    if last_silence_dur <= 2.0:
        if (previous_activity == 'MAL' and curr_activity == 'FEM') or \
                (previous_activity == 'FEM' and curr_activity == 'MAL') or \
                (previous_activity == 'FEM' and curr_activity == 'FEM') or \
                (previous_activity == 'MAL' and curr_activity == 'MAL'):

            return True
    return False

def read_analyses(temp_abs, sad, perc, diar=None, mode='CHI', child_aware=False):
    """ When the model has finished producing its outputs, read all the
        transcriptions and sort the files by the quantity of their speech
        content or the quantity of their speech belonging to the noiseme_class.

        Input:
            temp:           path to the temp folder in which the snippets of sound are
                            stored. Here we need the relative path, not the absolute
                            path, since the SAD tool will add the "/vagrant/" part of
                            the path.
            sad:            name of the sad tool to be used to analyze the snippets of
                            sound.
            perc:           the percentage of speech to keep.
            diar:           the diarization model (if provided).
            mode:           the type of speech that needs to be kept (has to be amongst ['CHI']).
            child_aware :   (only used if mode == ACCA) Indicates, if we should filter the snippets
                            that don't present any child activity.

        Output: 
            sorted_files: list(str), list of the files, sorted by the quantity
                           of the speech content (as returned by the SAD tool)
                           or the quantity of the speech content classified as
                           belonging to the noiseme class (as returned by the
                           diarization tool).
                           only 10 %% of all files, that contain the most speech
    """

    # get list of model outputs
    all_files = os.listdir(temp_abs)
    diar_mode = diar is not None
    if diar_mode:
        model = diar
    else:
        model = sad

    # we consider only the annotations that have been generated by the model
    annotations = [file for file in all_files if file.startswith(model[:-1])]

    # read all annotations and store duple in list (filename, speech_dur)
    files_n_dur = []
    for file in annotations:

        # we extract the base name composed of wav_file_name + t_deg + t_dur
        base = extract_base_name(file, diar)

        with open(os.path.join(temp_abs, file), 'r') as fin:
            speech_activity = fin.readlines()

            # total duration of the speech of interest
            tot_dur = 0.0
            # duration of the last silence
            silence_dur = 0.0
            # type of the last activity
            previous_activity = None
            onset_prev = 0.0
            dur_prev = 0.0
            # variable to detect if the child is aware in ACCA mode.
            chi_points = 0.0

            for line in speech_activity:
                anno_fields = line.split(' ')
                dur = float(anno_fields[4])
                onset = float(anno_fields[3])
                curr_activity = anno_fields[7]


                if onset_prev+dur_prev == onset:
                    silence_dur = 0.0
                else:
                    silence_dur = onset-onset_prev-dur_prev


                if not diar_mode:                                               # SAD mode
                    tot_dur += dur
                elif diar_mode and mode == 'CHI' and curr_activity == 'CHI':   # Child detection mode
                    tot_dur += 1
                elif diar_mode and mode == 'PCCONV':                           # Parent-child detection mode
                    if detect_parent_child_conv(previous_activity, curr_activity, silence_dur):
                        # Here we consider more an objective function (number of turn-taking) that
                        # we want to maximize. That comes from the fact that adults speak during a
                        # longer time while children speak only for few seconds. And we don't want
                        # to put too much weight on the adults speech.
                        tot_dur += 1
                elif diar_mode and mode == 'ACCA':                          # Adults conversation child aware detection
                    if detect_adults_conv(previous_activity, curr_activity, silence_dur):
                        tot_dur += 1
                    elif curr_activity == 'CHI':
                        chi_points += 1

                previous_activity = curr_activity
                onset_prev = onset
                dur_prev = dur

            files_n_dur.append((base, tot_dur, chi_points))

        # remove annotation when finished reading
        os.remove(os.path.join(temp_abs, file))

    if child_aware and diar_mode == 'ACCA':
        files_n_dur = [file for file in files_n_dur if file[2] > 3]

    if len(files_n_dur) == 0:
        raise ValueError("No moments for the {} mode has been found.\n Try to decrease the step parameter or " + \
                         "to increase the size of the chunks.")

    files_n_dur = sorted(files_n_dur, key=itemgetter(1), reverse=True)

    # return top 10%% of snippets
    percent = max(1, int(math.ceil(perc * len(files_n_dur))))

    sorted_files = files_n_dur[:percent]

    return sorted_files

def new_onsets_two_minutes(sorted_files):
    """
        Given a selection of file with lots of speech,
        extract new 2minutes long chunks of audio in the original wav,
        centered around the short 10s snippets that were analysed.

        Input:
            sorted_files: list of the snippets that were selected
                          because they had lot of speech
            temp_abs:     absolute path to the temp folder that contains the
                          snippets
            wav:          path to the daylong recording
        Ouput:
            _:            in the temp folder, new two minutes long chunks of
                          audio will be stored.
    """

    # loop over selected files and retrieve their onsets from their name
    new_onset_list = []
    for snippet, speech_dur, chi_points in sorted_files:
        onset = os.path.splitext(snippet)[0].split('_')[-2]
        offset = os.path.splitext(snippet)[0].split('_')[-1]

        length = float(offset) - float(onset)

        # new segment is centered around snippet, so get middle of snippet
        new_onset = length / 2 + float(onset)

        new_onset_list.append(new_onset)

    return new_onset_list

def new_onsets_five_minutes(sorted_files):
    """
        Given a selection of file with lots of speech,
        extract new 5minutes long chunks of audio in the original wav,
        by adding 2 minutes before and 1 minute after the 2minute chunks.

        Input:
            sorted_files: list of the snippets that were selected
                          because they had lot of speech
            temp_abs:     absolute path to the temp folder that contains the
                          snippets
            wav:          path to the daylong recording
        Ouput:
            _:            in the temp folder, new two minutes long chunks of
                          audio will be stored.
    """
    # loop over selected files and retrieve their onsets from their name
    new_onset_list = []
    for snippet, speech_dur, chi_points in sorted_files:
        onset = os.path.splitext(snippet)[0].split('_')[-2]
        offset = os.path.splitext(snippet)[0].split('_')[-1]

        # new segment starts 2 minute before the 2 minute chunk
        new_onset = float(onset) - 120.0

        new_onset_list.append(new_onset)

    return new_onset_list


def main():
    """
        Get duration of wav file
        Given duration of wav file, extract list of onsets
        Given list of onsets in wav file, extract chunks of wav

        Input:
            daylong:      path to the daylong recording
            --step:       (optional) step in seconds between each chunk.
                          By default 600 seconds.
            --chunk_size: (optional) size of the chunks to extract.
            --temp:       (optional) path to a temporary folder to store the
                          extracted chunks.
            --sad:        (optional) name of the SAD tool to call to analyse
                          the chunks. By default noiseme
            --diar:        (optional) name of the diarization tool to call to analyse
                          the chunks. No default option

    """
    parser = argparse.ArgumentParser()

    parser.add_argument('daylong', metavar='AUDIO_FILE',
            help='''Give RELATIVE path to the daylong recording'''
                 '''in wav format.''')
    parser.add_argument('--step', default=600.0, type=float,
            help='''(Optional) Step, in seconds, between each chunk of '''
                 '''audio that will be extracted to be analysed by the SAD '''
                 '''tool. By default, step=600 seconds (10 minutes)''')
    parser.add_argument('--chunk_sizes', nargs=3,
                        default=[10.0, 120.0, 300.0], type=float,
            help='''(Optional) Size of the chunks to extract and analyze. '''
                 '''By default it's 10.0 120.0 300.0: \n'''
                 '''10s chunks are extracted, analyzed by the '''
                 '''SAD tool, the 10%% chunks that contain the most speech '''
                 '''are kept, than 120s chunks centered on the 10s chunks, '''
                 '''these are again analysed by the SAD tool, the 10%% that '''
                 ''' contain the most speech are kept, and 300.0s chunks '''
                 ''' are finally extracted around these kept chunks.''')
    parser.add_argument('--percentage', default=10, type=float,
            help='''(Optional) Percentage of snippets to keep at each stage. '''
                 '''By default, we keep 10%% of snippets each time.\n'''
                 '''For a 15h long recording, we have 90x10s snippets, '''
                 '''we keep the 10%% with the most speech content, that '''
                 '''lead to 9x120s snippets, we again keep the 10%% with the '''
                 '''most speech content, so in the end we have 1x300 seconds '''
                 '''segment.''')
    parser.add_argument('--temp', default='tmp',
            help='''(Optional) Path to a temp folder in which the small wav '''
                 '''segments will be stored. If it doesn't exist, it will be '''
                 '''created.''')
    parser.add_argument('--sad', default='noisemes_sad',
                        help='''(Optional) name of the sad tool that will be used to '''
                             '''analyze the snippets of sound''')
    parser.add_argument('--diar',
            help='''(Optional) name of the diar tool that will be used to '''
                 '''analyze the snippets of sound. If this argument is provided by
                 the user, this script will be on the diarization mode. Otherwise, it will
                 be on the SAD mode.''')
    parser.add_argument('--mode', default='CHI', choices=['CHI', 'PCCONV', 'ACCA'],
                        help='''(Optional) the noiseme class(es) of interest. '''
                             '''Used only when the diar argument is provided.''')

    args = parser.parse_args()

    if args.diar == 'yunitate' and (args.mode == 'PCCONV' or args.mode == 'ACCA' or args.mode == 'CHI'):
        if args.chunk_sizes[0] == 10.0:
            print("Resetting chunk size at 20.0 seconds (more suitable for CHI/PCCONV/ACCA mode).")
            args.chunk_sizes[0] = 20.0
        if args.step == 600.0:
            print("Resetting step at 300.0 seconds (more suitable for CHI/PCCONV/ACCA mode).")
            args.step = 300.0

    # Define Data dir
    data_dir = "/vagrant"

    # check if temp dir exist and create it if not
    temp_abs = os.path.join(data_dir, args.temp)
    temp_rel = args.temp # to launch SAD tool we need the relative path to temp

    if not os.path.isdir(temp_abs):
        os.makedirs(temp_abs)

    # Define absolute path to wav file
    wav_abs = os.path.join(data_dir, args.daylong)

    # get percentage
    perc = args.percentage / 100.0

    # get path to current (tools/) dir - useful to call the SAD tool
    dir_path = os.path.dirname(os.path.realpath(__file__))

    # get duration
    duration = get_audio_length(wav_abs)

    # get list of onsets
    onset_list = select_onsets(duration, args.step)

    # call subprocess to extract the chunks
    extract_chunks(wav_abs, onset_list, args.chunk_sizes[0], temp_abs)

    # analyze using SAD tool
    run_Model(temp_rel, temp_abs, args.sad, args.diar)

    # sort by speech duration
    sorted_files = read_analyses(temp_abs, args.sad, perc, args.diar, args.mode)

    # get new onsets for two minutes chunks
    new_onset_list = new_onsets_two_minutes(sorted_files)

    # extract two minutes chunks
    extract_chunks(wav_abs, new_onset_list, args.chunk_sizes[1], temp_abs)

    # analyze using SAD tool
    run_Model(temp_rel, temp_abs, args.sad, args.diar)

    # sort by speech duration again
    child_aware = False
    if args.mode == 'ACCA':
        child_aware = True

    sorted_files = read_analyses(temp_abs, args.sad, perc, args.diar, args.mode, child_aware)

    # get new onsets for five minutes chunks
    new_onset_list = new_onsets_five_minutes(sorted_files)

    # extract final five minutes long chunks
    output_dir = os.path.dirname(wav_abs)
    extract_chunks(wav_abs, new_onset_list, args.chunk_sizes[2], output_dir)


if __name__ == '__main__':
    main()
