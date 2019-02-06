"""
This script converts an txt file into a rttm one.
The txt file must contain : class onset offset.
It can be run either on a single txt file, or on a whole folder containing txt files.

Example of use :
    python tools/txt2rttm.py -i data/my_file.txt    # One one file
    python tools/txt2rttm.py -i data/               # On a whole folder
    python tools/txt2rttm.py -i data/ -l True       # On a whole folder + lena mode activated

If the lena mode is activated, it will look for a file called tsi_key_info.xlsx in the input folder
that contains a column file_lena (storing lena names, ex : e20170722_093015_009456_2040_2100_lena)
and a column key (containg the associated ACLEW name)
About the naming convention of the output :
    For each file called input_file.txt, the result will be stored in input_file.rttm
"""

import pympi as pmp
import argparse
import os
import sys
import glob
from openpyxl import load_workbook

def lena_to_aclew_name(tsi_key_info, basename):
    """
    Convert lena names to ACLEW names.

    Parameters
    ----------
    tsi_key_info :      the path to the tsi_key_infos.xlsx file
    basename :          the basename of the txt file that needs to be converted. This name follows the LENA naming convention.

    Returns
    -------
        The name respecting the ACLEW naming convention
    """
    is_BER_ROW_SOD_WAR = any(substring in basename for substring in ['BER','ROW','SOD','WAR'])
    if not is_BER_ROW_SOD_WAR:
        # Should come from TSI recordings
        onset = basename.split('_')[3]
        basename_beg = '_'.join(basename.split('_')[0:3]) # Get the first 3 elements
        wb = load_workbook(tsi_key_info,data_only=True)
        wb = wb.worksheets[0]
        first_row = wb.rows[0]
        file_lena_num_col = None
        key_num_col = None

        # Get num of the column
        for idx in range(0, len(first_row)):
            cell = first_row[idx]
            if cell.value == "file_lena":
                file_lena_num_col = idx
            if cell.value == "key":
                key_num_col = idx

        # Loop through the cells to look for the basename
        if file_lena_num_col is not None and key_num_col is not None:
            for row in wb.rows[1:]:
                file_lena = row[file_lena_num_col].value
                key_num = row[key_num_col].value
                if file_lena == basename_beg:
                    child, good_date = key_num.split('_')
                    return '_'.join(['lena',child,good_date,onset])
    else:
        return '_'.join(['lena',basename.replace('_lena','')])


def txt2rttm(path_to_txt, output_folder, lena_mode=False):
    """
    Convert an txt file to the rttm format by extracting the
    Parameters
    ----------
    path_to_txt :   path to the txt file.
    output_folder : where to store the output files

    Write a rttm whose name is the same than the txt's one in output_folder
    """
    basename = os.path.splitext(os.path.basename(path_to_txt))[0]
    if lena_mode:
        dirname = os.path.dirname(path_to_txt)
        output_basename = lena_to_aclew_name(os.path.join(dirname, 'tsi_key_info.xlsx'), basename)
        output_path = os.path.join(dirname, output_basename + '.rttm')
        # Change the output_basename because we don't want to write the model prefix lena_
        # in the rttm fil
        output_basename = '_'.join(output_basename.split('_')[1:])
    else:
        output_path = os.path.join(output_folder, basename + '.rttm')
        output_basename = os.path.splitext(os.path.basename(output_path))[0]

    with open(path_to_txt, 'r') as txt:
        with open(output_path, 'w') as rttm:
            for line in txt:
                activity, onset, offset = line.rstrip().split('\t')
                dur = float(offset)-float(onset)

                rttm.write("SPEAKER\t%s\t1\t%s\t%s\t<NA>\t<NA>\t%s\t<NA>\n" % (output_basename, onset, str(dur), activity))


def main():
    parser = argparse.ArgumentParser(description="convert .txt into .rttm")
    parser.add_argument('-i', '--input', type=str, required=True,
                        help="path to the input .txt file or the folder containing txt files.")
    parser.add_argument('-l', '--lena_mode', type=bool, required=False, default=False,
                        help="indicates whether to use this script in the lena mode or not. If the lena mode"
                             "is activated, it will read the table tsi_key_info.xlsx in the input folder and"
                             "will change the naming convention of the output in consequences")
    args = parser.parse_args()


    # Initialize the output folder as the same folder than the input
    # if not provided by the user.
    if args.input[-4:] == '.txt':
        output = os.path.dirname(args.input)
    else:
        output = args.input

    data_dir = '/vagrant'
    args.input = os.path.join(data_dir, args.input)
    output = os.path.join(data_dir, output)

    if not os.path.isdir(output):
        os.mkdir(output)
    if args.input[-4:] == '.txt':   # A single file has been provided by the user
        txt2rttm(args.input, output, args.to_keep, args.lena_mode)
    else:                           # A whole folder has been provided
        txt_files = glob.iglob(os.path.join(args.input, '*.txt'))
        for txt_path in txt_files:
            print("Processing %s" % txt_path)
            txt2rttm(txt_path, output, args.lena_mode)


if __name__ == '__main__':
    main()