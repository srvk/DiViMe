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
import argparse
import errno

def read_rttm(input_path):
    """Read a RTTM file indicating gold diarization"""
    if os.path.isfile(input_path):
        with open(input_path, 'r') as fin:
            # RTTM format is
            # SPEAKER fname 1 onset duration <NA> <NA> spkr <NA>
            rttm = fin.readlines()
            #sad = IntervalTree()
            all_intervals = []
            fname = ""
            for line in rttm:
                row = line.strip('\n').split()
                fname, onset, dur = row[1], row[3], row[4]
                if float(dur) == 0:
                    # Remove empty intervals
                    continue
                elif float(dur) < 0:
                    print("{} shows an interval with negative duration."
                          " Please inspect file, this shouldn't happen".format(
                            line))
                    continue

                # add interval to list
                all_intervals.append((float(onset), float(onset) + float(dur)))

        # sort intervals by their onset
        all_intervals.sort()

        # look at each interval, add them in growing order of onset,
        # trim the beginning if it overlaps with previous interval,
        # and completely delete if it is contained by the previous interval.
        sad = []
        prev_on = 0
        prev_off = 0
        for onset, offset in all_intervals:
            if len(sad) == 0:
                # don't check anything for first interval
                sad.append((onset, offset))
                prev_on = onset
                prev_off = offset
                continue

            if onset < prev_off:
                if offset <= prev_off:
                    # interval is completely contained in the previous one
                    continue
                onset = prev_off

            sad.append((onset, offset))
            prev_on = onset
            prev_off = offset

        return sad, fname
    else:
        raise IOError(errno.ENOENT, os.strerror(errno.ENOENT), input_path)

def write_scp(out_intervals, fname, output):
    """Write output in SCP format"""
    if len(out_intervals) != 0:
        with open(output, 'w') as fout:
            fout.write(u'') # write empty string in case out_intervals is empty
            for onset, offset in out_intervals:
                fout.write(u'{fname}_{on}_{off}={fname}.fea[{on},{off}]\n'.format(
                             fname=fname,
                             on=int(onset*100),
                             off=int(offset*100)))

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
