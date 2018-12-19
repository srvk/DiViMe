import sys
import argparse
import glob
import os
import re
from collections import OrderedDict


def detect_ad_chi_tt(previous_activity, curr_activity, last_silence_dur, chi, mal, fem):
    if last_silence_dur <= 2.0:
        if (previous_activity in mal and curr_activity in chi) or \
                (previous_activity in fem and curr_activity in chi) or \
                (previous_activity in chi and curr_activity in mal) or \
                (previous_activity in chi and curr_activity in fem):
            return 1
    return 0


def compute_statistics(rttm_path, chi, mal, fem, trash):
    chi_dur=0.0
    chi_utt=0
    ad_dur=0.0
    ad_utt=0
    ad_chi_tt=0

    silence_dur = 0
    prev_activity = None
    onset_prev = 0
    dur_prev = 0

    with open(rttm_path,'r') as rttm:
        for line in rttm:
            line = line.replace('\t', ' ')
            line = re.sub('\s+', ' ', line).strip()
            anno_fields = line.split(' ')
            curr_activity = anno_fields[7]
            if curr_activity != 'SIL' and curr_activity != 'S':  # We're managing things as if 'SIL' lines weren't exist
                onset = float(anno_fields[3])
                dur = float(anno_fields[4])

                if curr_activity in chi:
                    chi_dur += dur
                    chi_utt += 1
                elif curr_activity in mal or curr_activity in fem:
                    ad_dur += dur
                    ad_utt +=1
                elif curr_activity not in trash:
                    print("Activity %s not recognized" % (curr_activity))
                    print("In file %s" % (os.path.basename(rttm_path)))
                    sys.exit(1)

                if onset_prev + dur_prev == onset:
                    silence_dur = 0.0
                else:
                    silence_dur = onset - onset_prev - dur_prev

                ad_chi_tt += detect_ad_chi_tt(prev_activity, curr_activity, silence_dur, chi, mal, fem)

                # We're managing things as if SIL lines weren't exist

                prev_activity=curr_activity
                onset_prev=onset
                dur_prev=dur

    filename = os.path.basename(rttm_path).split('.')[0]
    res = [filename, chi_dur, chi_utt, ad_dur, ad_utt, ad_chi_tt]
    return res

def write_stats(list_stats, folder):
    filename=os.path.join(folder,"stats.txt")

    with open(filename,'w') as fn:
        fn.write("filename\tchi_dur\tchi_utt\tad_dur\tad_utt\tad_chi_tt\n")
        for stats in list_stats:
            fn.write('\t'.join(map(str,stats))+'\n')

def main():
    parser = argparse.ArgumentParser(description="convert .txt into .rttm")
    parser.add_argument('-f', '--folder', type=str, required=True,
                        help="path to the folder where to find the rttm to analyze."
                             "Note that all of the rttm are scanned.")
    parser.add_argument('--chi', nargs='+', type=str, required=True,
                        help="labels that need to be considered as being child vocalization.")
    parser.add_argument('--mal', nargs='+', type=str, required=True,
                        help="labels that need to be considered as being male adult speech.")
    parser.add_argument('--fem', nargs='+', type=str, required=True,
                        help="labels that need to be considered as being female adult speech.")
    parser.add_argument('--trash', nargs='+', type=str, required=False, default=None,
                        help="labels that need to not be considered.")
    args = parser.parse_args()

    # Below the values that need to be consider when evaluating tsi/lena folder
    # prob C22_20170717_5640
    ## Gold files
    # chi=['CHI*','C1', 'C2']
    # mal=['MA1','MA2']
    # fem=['MOT*','FA1','FA2']

    ## Yunitator
    # chi = ['CHI']
    # mal = ['MAL']
    # fem = ['FEM']

    ## Lena N tag
    # chi = ['CXN', 'CHN']
    # mal = ['MAN']
    # fem = ['FAN']

    ## Lena MFC
    # chi = ['C']
    # mal = ['M']
    # fem = ['F']

    ## Lena N and F separated (should be the equivalent of MFC
    # chi = ['CHN', 'CXN', 'CHF', 'CXF']
    # mal = ['MAN', 'MAF']
    # fem = ['FAN', 'FAF']
    args.folder=os.path.join('/vagrant', args.folder)
    rttm_files = [fn for fn in glob.iglob(os.path.join(args.folder, '*.rttm'))
                  if 'cutted' not in fn]
    list_stats=[]
    for rttm_path in rttm_files:
        list_stats.append(compute_statistics(rttm_path, args.chi, args.mal, args.fem, args.trash))

    write_stats(list_stats, args.folder)
if __name__ == '__main__':
    main()