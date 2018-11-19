#!/usr/bin/bash
#

import os
import sys
import ipdb

tocombo = sys.argv[1]
output = sys.argv[2]

# read VAD input
with open(tocombo, 'r') as fin:

    trs = fin.readlines()
    shortened_trs = []

    # there's one line per 0.1 second, so aggregate to get the whole segment 
    # with constant state of speech/nonspeech
    for i, line in enumerate(trs):
        on, off, state = line.strip('\n').split('	')
        if i == 0:
            first_on = on
            prev_off = off
            prev_state = state
        elif i > 0 and i < len(trs) - 1:
            if not state == prev_state:
                shortened_trs.append((first_on, prev_off, prev_state))
                first_on = on
                prev_off = off
                prev_state = state
            elif state == prev_state:
                prev_off = off
                prev_state = state
        elif i == len(trs) - 1:
            if not state == prev_state:
                shortened_trs.append((first_on, prev_off, prev_state))
                shortened_trs.append((on, off, state))
            elif state == prev_state:
                shortened_trs.append((first_on, off, state))

shortened_trs = [(float(on), float(off), int(state)) for on, off, state in shortened_trs]

# write rttm output
fname = os.path.basename(tocombo).split('.')[0]
with open(output, 'w') as fout:
    for on, off, state in shortened_trs:
        if state == 1:
            vad = "speech"
        else:
            continue
        fout.write(u"SPEAKER {} {} {} {} {} {} {} {}\n".format
                   (fname, 1, on, off - on, "<NA>", "<NA>", vad, 1 ))
