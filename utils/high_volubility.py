#!/usr/bin/env python
#
# author = The ACLEW Team
#
"""
This script extract short snippets of sound (approx. 10s long),
and runs them through a SAD or diarization tool to detect chunks of audio with :

1) a lot of speech.
--> python utils/high_volubility.py file_path.wav --sad noisemesSad

2) a lot of child speech
--> python utils/high_volubility.py file_path.wav --diar yunitator_old --mode CHI --nb_chunks 3

3) a lot of parent-child conversations
--> python utils/high_volubility.py file_path.wav --diar yunitator_english --mode PCCONV

4) a lot of adults conversations with a child minimally aware
--> python utils/high_volubility.py file_path.wav --diar yunitator_universal --mode ACCA
"""

import os
import sys
import re
import wave
import math
import numpy
import shutil
import argparse
import subprocess
import collections
import tempfile
import shutil
from operator import itemgetter

LAUNCHER_FOLDER = "/home/vagrant/launcher"

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

def select_onsets(duration, step, min_chunk_size=-1.0, max_chunk_size=-1.0):
    """ Return list of onsets on which this script will extract the chunks of
    10s

    Input:
        duration: float, duration of the daylong recording

    Output:
        onsets: list[floats], list the onsets on which this script will extract
                the chunks of 10s to be run through the SAD tools
    """
    return list(numpy.arange((max_chunk_size-min_chunk_size)/2, duration, step))


def extract_chunks(wav, onset_list, chunk_size, temp, duration=-1.0):
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

    print("extract_chunks("+wav+", "+str(onset_list)+", "+str(chunk_size)+", "+str(temp)+", "+str(duration)+")")

    # get "id" basename of wav file
    basename = os.path.splitext(os.path.basename(wav))[0]

    # for each onset, call SoX using subprocess to extract a chunk.
    for on in onset_list:
        # create name of output
        off = on + chunk_size
        if on < 0.0:
            on = 0.0
        if duration > 0 and off > duration:
            off = duration
        str_on  = '{:.1f}'.format(on)
        #(6 - len(str(on))) * '0' + str(on)
        str_off = '{:.1f}'.format(off)
        #(6 - len(str(off))) * '0' + str(off)
        # {:08.1f}

        #chunk_duration = float(str_off) - float(str_on)
        #if chunk_duration != chunk_size:
        #    missed_duration = chunk_size - chunk_duration
        #    if float(str_on) == 0.0:
        #        str_off = str(float(str_off)+missed_duration)
        #    else:
        #        str_on = str(float(str_on)-missed_duration)
        chunk_name = '_'.join([basename, str_on, str_off])

        # call subprocess
        cmd = ['sox', wav,
                os.path.join(temp, '{}.wav'.format(chunk_name)),
               'trim', '{:f}'.format(on), '{:f}'.format(off-on)]
        try:
            cpi = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
            if len(cpi):
                print(str(cmd), "->", str(cpi))
        except subprocess.CalledProcessError:
            print("Error caused by: "+str(cmd))
            sys.exit(str(cpi))


def run_Model(temp_rel, temp_abs, sad, diar=None, output_dir=None, del_temp=True):
    """ When all the snippets of sound are extracted, and stored in the temp
        file, run them through a sad or diar tool, and keep
        the 10% that have the most speech.
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

    print("run_Model("+temp_rel+", "+temp_abs+", "+sad+", diar="+str(diar)+", output_dir="+str(output_dir)+", del_temp="+str(del_temp)+")")

    if diar is not None: # Diarization mode
        if diar.startswith('yunitator'):
            mode = diar.split("_")[1]
            available_flavors = ["old", "english", "universal"]
            if mode not in available_flavors:
                sys.exit("Yunitator's flavor not recognized. Should be in %s" % available_flavors)
            cmd = [os.path.join(LAUNCHER_FOLDER, 'yunitate.sh'), '{}'.format(temp_rel), '{}'.format(mode)]
            if not del_temp:
                cmd.append('--keep-temp')
        elif diar == 'diartk':
            cmd = [os.path.join(LAUNCHER_FOLDER, '{}.sh').format(diar), '{}'.format(temp_rel), '{}'.format(sad)]
        else:
            cmd = ['exit 1']
    else: # SAD mode
        cmd = [os.path.join(LAUNCHER_FOLDER, '{}.sh').format(sad), '{}'.format(temp_rel)]

    try:
        cpi = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError:
        print("Error caused by: "+str(cmd))
        sys.exit(str(cpi))

    # after the model has finished running, remove the wav files
    if output_dir is None:
        for fin in os.listdir(temp_abs):
            if fin.endswith('.wav'):
                os.remove(os.path.join(temp_abs, fin))
    else:
        output_files = []
        for fin in os.listdir(temp_abs):
            if not os.path.isfile(os.path.join(output_dir, fin)):
                shutil.move(os.path.join(temp_abs, fin), output_dir)
            if fin[-5:] == ".rttm":
                output_files.append(os.path.join(output_dir, fin))
        return output_files



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
    if diar in ["noisemesSad", "tocomboSad", "opensmileSad"]:
        base = filename.split('_')[1:]
    else: # diartk and yunitator
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

def read_analyses(temp_abs, sad, nb_chunks, diar=None, mode='CHI', child_aware=False, keep_rttm=False):
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
            nb_chunks:      the number of chunks that need to be kept (the ones containing the most speech).
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

                if not diar_mode:
                    # SAD mode
                    tot_dur += dur
                elif diar_mode and mode == 'CHI' and curr_activity == 'CHI':
                    # Child detection mode
                    tot_dur += 1
                elif diar_mode and mode == 'PCCONV':
                    # Parent-child detection mode
                    if detect_parent_child_conv(previous_activity, curr_activity, silence_dur):
                        # Here we consider more an objective function (number of turn-taking) that
                        # we want to maximize. That comes from the fact that adults speak during a
                        # longer time while children speak only for few seconds. And we don't want
                        # to put too much weight on the adults speech.
                        tot_dur += 1
                elif diar_mode and mode == 'ACCA':
                    # Adults conversation child aware detection
                    if detect_adults_conv(previous_activity, curr_activity, silence_dur):
                        tot_dur += 1
                    elif curr_activity == 'CHI':
                        chi_points += 1

                previous_activity = curr_activity
                onset_prev = onset
                dur_prev = dur

            files_n_dur.append((base, tot_dur, chi_points))

        # remove annotation when finished reading
        if keep_rttm:
            os.move(os.path.join(temp_abs, file), )
        else:
            os.remove(os.path.join(temp_abs, file))

    if child_aware and diar_mode == 'ACCA':
        files_n_dur = [file for file in files_n_dur if file[2] > 3]

    if len(files_n_dur) == 0:
        sys.exit("No "+mode+" speech found, try to decrease the step parameter or to increase the size of the chunks.")

    files_n_dur = sorted(files_n_dur, key=itemgetter(1), reverse=True)

    # Extract the nb_chunks snippets that contain the have the highest score
    nb_chunks = min(len(files_n_dur), nb_chunks)

    sorted_files = files_n_dur[:nb_chunks]

    return sorted_files

def new_onsets(sorted_files, duration=0.0, chunk_size=120.0):
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
        onset  = float(os.path.splitext(snippet)[0].split('_')[-2])
        offset = float(os.path.splitext(snippet)[0].split('_')[-1])
        length = offset - onset

        # new segment is centered around snippet, so get middle of snippet
        new_onset = onset + length/2 - chunk_size/2
        if new_onset + chunk_size > 0 and new_onset < duration:
            new_onset_list.append(new_onset)

    return new_onset_list

def write_final_stats(output_rttm):
    stats = collections.OrderedDict([("filename", None),
                         ("CHI_duration", 0.0),
                         ("MAL_duration", 0.0),
                         ("FEM_duration", 0.0),
                         ("ADU_ADU_turntaking", 0),
                         ("ADU_CHI_turntaking", 0)])
    original_name = '_'.join(os.path.basename(output_rttm[0]).split('_')[:-2])
    output_stats = os.path.join(os.path.dirname(output_rttm[0]), "high_volubility_stats_" + original_name + ".txt")
    with open(output_stats, "w") as fout:
        fout.write(",".join(stats.keys()))
        fout.write("\n")

        for file in output_rttm:
            stats["filename"] = os.path.basename(file).replace(".rttm", "")
            with open(file, "r") as rttm:
                # type of the last activity
                previous_activity = None
                onset_prev = 0.0
                dur_prev = 0.0
                for line in rttm:
                    anno_fields = line.split(' ')
                    dur = float(anno_fields[4])
                    onset = float(anno_fields[3])
                    curr_activity = anno_fields[7]

                    if onset_prev + dur_prev == onset:
                        silence_dur = 0.0
                    else:
                        silence_dur = onset - onset_prev - dur_prev

                    stats[curr_activity+"_duration"] += dur

                    if detect_adults_conv(previous_activity, curr_activity, silence_dur):
                        stats["ADU_ADU_turntaking"] += 1
                    if detect_parent_child_conv(previous_activity, curr_activity, silence_dur):
                        stats["ADU_CHI_turntaking"] += 1

                    previous_activity = curr_activity
                    onset_prev = onset
                    dur_prev = dur
            fout.write(",".join(str(x) for x in stats.values()))
            fout.write("\n")

            # Go back to 0
            stats = collections.OrderedDict([("filename", None),
                                             ("CHI_duration", 0.0),
                                             ("MAL_duration", 0.0),
                                             ("FEM_duration", 0.0),
                                             ("ADU_ADU_turntaking", 0),
                                             ("ADU_CHI_turntaking", 0)])
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
            --diar:       (optional) name of the diarization tool to call to analyse
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
    parser.add_argument('--nb_chunks', default=5, type=int,
            help='''(Optional) Number of snippets to keep at the last stage. '''
                 '''By default, we keep the top 5 snippets that have the most speech content.\n''')
    parser.add_argument('--temp', default='(auto)',
            help='''(Optional) Path to a temp folder in which the small wav '''
                 '''segments will be stored. If it doesn't exist, it will be '''
                 '''created.''')
    parser.add_argument('--output', default=None,
            help='''(Optional) Path to the output folder in which the results '''
                 '''will be stored. If it doesn't exist, it will be '''
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

    # Sanity check and auto-generation of temp dir
    if os.path.isabs(args.temp):
        sys.exit("Temp path must be relative, not "+args.temp)
    if os.path.isabs(args.daylong):
        sys.exit("Daylong path must be relative, not "+args.daylong)

    # Define data dir
    data_dir = "/vagrant"

    # to launch SAD tool we need the relative path to temp
    if args.temp == '(auto)':
        temp_abs = tempfile.mkdtemp(dir=data_dir)
        temp_rel = os.path.basename(temp_abs)
        del_temp = True
    else:
        temp_abs = os.path.join(data_dir, args.temp)
        temp_rel = args.temp
        del_temp = False
        os.makedirs(temp_abs)

    # Define absolute path to wav file
    wav_abs = os.path.join(data_dir, args.daylong)

    if args.output is None:
        output_dir = os.path.dirname(wav_abs)
    elif os.path.isabs(args.output):
        sys.exit("Output path must be relative, not "+args.output)
    else:
        output_dir = os.path.join(data_dir, args.output)

    # get number of chunks that need to be kept
    nb_chunks = int(args.nb_chunks)

    # get duration
    duration = get_audio_length(wav_abs)

    # get list of onsets
    onset_list = select_onsets(duration, args.step,
        min_chunk_size=args.chunk_sizes[0], max_chunk_size=args.chunk_sizes[2])

    # call subprocess to extract the chunks
    extract_chunks(wav_abs, onset_list, args.chunk_sizes[0], temp_abs, duration=duration)

    # analyze using SAD tool
    run_Model(temp_rel, temp_abs, args.sad, diar=args.diar, del_temp=del_temp)

    # sort by speech duration
    sorted_files = read_analyses(temp_abs, args.sad, nb_chunks*3, args.diar, args.mode)
    # get new onsets for two minutes chunks
    new_onset_list = new_onsets(sorted_files, duration=duration, chunk_size=args.chunk_sizes[1])
    # extract two minutes chunks
    extract_chunks(wav_abs, new_onset_list, args.chunk_sizes[1], temp_abs, duration=duration)

    # analyze using SAD tool
    run_Model(temp_rel, temp_abs, args.sad, diar=args.diar, del_temp=del_temp)

    # sort by speech duration again
    child_aware = False
    if args.mode == 'ACCA':
        child_aware = True

    sorted_files = read_analyses(temp_abs, args.sad, nb_chunks, args.diar, args.mode, child_aware)
    # get new onsets for five minutes chunks
    new_onset_list = new_onsets(sorted_files, duration=duration, chunk_size=args.chunk_sizes[2])
    # extract final five minutes long chunks
    extract_chunks(wav_abs, new_onset_list, args.chunk_sizes[2], temp_abs, duration=duration)

    ## Run one last time the model to get the transcription
    # analyze using SAD tool
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    output_rttm = run_Model(temp_rel, temp_abs, args.sad, diar=args.diar, output_dir=output_dir, del_temp=del_temp)

    #output_rttm = ["/vagrant/data/daylong/yunitator_english_0396_sub_1085.0_1385.0.rttm"]
    write_final_stats(output_rttm)

    if del_temp:
        shutil.rmtree(temp_abs)


if __name__ == '__main__':
    main()
