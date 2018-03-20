#!/usr/bin/env python
#
# author: The ACLEW Team
#
# This script takes as input gold rttm file
# that transcribes a diarization, and converts it
# to a gold scp file indicating Speech Activity.
# It is necessary, to avoid overlaps between speech intervals
# and to sort the intervals by onsets.

import os
import sys
import argparse
from intervaltree import IntervalTree, Interval
from operator import itemgetter

def read_rttm(input_path):
    """Read a RTTM file indicating gold diarization"""
    with open(input_path, 'r') as fin:
        # RTTM format is
        # SPEAKER fname 1 onset duration <NA> <NA> spkr <NA>
        rttm = fin.readlines()
        sad = IntervalTree()
        fname = ""
        for line in rttm:
            _, fname, _, onset, dur, _, _, _, _ = line.strip('\n').split()
            if float(dur) == 0:
                # Remove empty intervals
                continue
            elif float(dur) < 0:
                print("{} shows an interval with negative duration."
                      " Please inspect file, this shouldn't happen".format(
                        line))
                continue

            interval = Interval(float(onset), float(onset) + float(dur))

            # Search for intervals already added that overlap with current
            # interval. If we find some, then we truncate the current
            # interval to remove all overalps
            ov = sad.search(interval)
            interval, other_intervals = remove_overlap(ov, interval)
            if interval[0] == interval[1]:
                # continue if interval was removed
                continue

            sad.add(interval)

            # if other_intervals is not empty, add these intervals to tree
            for new_interv in other_intervals:
                sad.add(new_interv)
     
    return sad, fname

def remove_overlap(ov, interval):
    """Take as input an interval, and the set of the intervals it overlaps """
    """with, and output the interval trimmed (possibly to 0) so that there """
    """are no overlaps in the output"""
    onset, offset = interval[0], interval[1]
    other_intervals = []

    for covered_int in ov:
        if (onset >= covered_int[0]) and (offset <= covered_int[1]):
            # if interval is already covered, return empty interval
            onset = 0
            offset = 0
        elif (onset < covered_int[0]) and (offset >= covered_int[0])\
             and (offset <= covered_int[1]):
            # change onset/offset to avoid overlap
            onset = onset
            offset = covered_int[0]
        elif (onset <= covered_int[1]) and (offset > covered_int[1])\
             and (onset >= covered_int[0]):
            onset = covered_int[1]
            offset = offset
        elif(onset <= covered_int[0]) and (offset >= covered_int[1]):
            # case where the new interval contains a previously add one
            # in this case return second interval
            new_onset = covered_int[1]
            new_offset = offset
            onset = onset
            offset = covered_int[0]
            
            temp_interval = Interval(new_onset, new_offset)
            # call remove_overlap again with the newly created interval
            # in case it also has overlap in ov
            new_interval, _other_intervals = remove_overlap(ov,
                                                            temp_interval)

            other_intervals.append(new_interval)
            other_intervals += _other_intervals


        #else:
        #    # Do nothing, all problems are probably allready resolved !
        #    # print('{} {} {}'.format(interval, ov, other_intervals))
            
    return Interval(onset, offset), other_intervals

def write_scp(tree, fname, output):
    """Write output in SCP format"""
    # First order the intervals
    out_intervals = []
    for interval in tree:
        out_intervals.append((interval[0], interval[1]))
    out_intervals = sorted(out_intervals, key=itemgetter(0))

    with open(output, 'w') as fout:
        fout.write(u'') # write empty string in case out_intervals is empty
        for onset, offset in out_intervals:
            fout.write(u'{fname}_{on}_{off}={fname}.fea[{on},{off}]\n'.format(
                         fname=fname,
                         on=int(onset)*100,
                         off=int(offset)*100))
        
def main():
    """Take diarization in RTTM format as input, and write """
    """SAD in scp format, with ordered intervals, as output."""
    parser = argparse.ArgumentParser(
        description='Take diarization in RTTM format as input, and write '
                    'SAD in scp format, with ordered intervals, as output.',
        add_help=True,
        usage='%(prog)s [RTTM] [SCP]')
    parser.add_argument(
        'rttm', type=str, metavar='PATH',
        help='Path to the RTTM input')
    parser.add_argument(
        'scp', type=str, metavar='PATH',
        help='Path to the SCP output')

    args = parser.parse_args()

    sad_tree, fname = read_rttm(args.rttm)
    write_scp(sad_tree, fname, args.scp)

if __name__ == "__main__":
    main()
