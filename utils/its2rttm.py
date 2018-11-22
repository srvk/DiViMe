#!/usr/bin/env python
#
# author: The ACLEW Team
#
# This script takes as input its file
# and convert it to rttm file.

import os
import re
import argparse


def its_line_2_rttm_line(its_line, rttm_name):
    """
    < Segment spkr = "TVF" average_dB = "-49.61" peak_dB = "-38.96" startTime = "PT31819.24S" endTime = "PT31820.61S" / >
    to
    SPEAKER rttm_name 1 t_beg dur <NA> <NA> class <NA> <NA>
    """
    its_line = its_line[its_line.find("<"):]

    rttm_line = ""
    if its_line[:8] == "<Segment":
        spkr = re.search('spkr="(\w+)"', its_line)
        if spkr :
            spkr = spkr.group(1)

        start_time = re.search('startTime="PT(\d+\.\d+)S"', its_line)
        if start_time:
            start_time = float(start_time.group(1))

        end_time = re.search('endTime="PT(\d+\.\d+)S"', its_line)
        if end_time:
            end_time = float(end_time.group(1))

        duration = end_time-start_time
        rttm_line = "SPEAKER " +\
                    rttm_name + " " +\
                    "1 " +\
                    "%f" % start_time + " " +\
                    "%f " % duration + " " +\
                    "<NA> " +\
                    "<NA> " +\
                    spkr + " " +\
                    "<NA> " +\
                    "<NA>\n"

    return rttm_line


def its_2_rttm(input_path, output_path):
    """Read a RTTM file indicating gold diarization"""
    rttm_name = os.path.splitext(os.path.basename(output_path))[0]

    with open(input_path, 'r') as its:
        with open(output_path, 'w') as rttm:
            for its_line in its:
                rttm_line = its_line_2_rttm_line(its_line, rttm_name)
                rttm.write(rttm_line)

def main():
    """Take transcription file in its format as input, and write """
    """it into rttm format."""
    parser = argparse.ArgumentParser(
        description='Take transcription file in its format as input, and write '
                    'it into rttm format.',
        add_help=True,
        usage='%(prog)s [its] [rttm]')
    parser.add_argument(
        'its', type=str, metavar='PATH',
        help='Path to the its input')
    parser.add_argument(
        'rttm', type=str, metavar='PATH',
        help='Path to the rttm output')

    args = parser.parse_args()

    its_2_rttm(args.its, args.rttm)

if __name__ == "__main__":
    main()