import glob
import os
import re
import argparse

parser = argparse.ArgumentParser(description="Convert the old naming convention of tsi/lena files into the new one.")
parser.add_argument('-f', '--folder', type=str, required=True,
                    help="path to the input folder tsi/lena (containing C25_NA_M14_20170719_56040.{wav|rttm} files).")
args = parser.parse_args()

path_tsi_lena=os.path.join("/vagrant", args.folder)
rttm_files = glob.iglob(os.path.join(path_tsi_lena, '*.rttm'))

for rttm in rttm_files:
    dirname = os.path.dirname(rttm)
    basename = os.path.splitext(os.path.basename(rttm))[0]
    basename_splitted = basename.split('_')

    old_name = os.path.splitext(basename)[0]
    if basename[0] == 'C' and len(basename_splitted) == 5:
        new_name = '_'.join([basename_splitted[0],
                             basename_splitted[3],
                             basename_splitted[4]])

        # Modify rttm name
        new_path_rttm = os.path.join(dirname, new_name+'.rttm')
        os.rename(rttm ,new_path_rttm)

        # Modify wav name
        old_path_wav = os.path.join(dirname, old_name+'.wav')
        new_path_wav = os.path.join(dirname, new_name+'.wav')
        os.rename(old_path_wav, new_path_wav)

        # Do the change within the rttm (column 2 containing the filename)
        new_name = os.path.splitext(new_name)[0]
        f = open(new_path_rttm, 'r+b')
        f_content = f.read()
        f_content = re.sub(old_name, new_name, f_content)
        f.seek(0)
        f.truncate()
        f.write(f_content)
        f.close()

