from pyannote.core import Segment, Timeline, Annotation
from pyannote.metrics.errors.identification import IdentificationErrorAnalysis
import pyannote.metrics.diarization as diarization
import pyannote.metrics.identification as identification
import pyannote.metrics.detection as detection
import pyannote.core.notebook as notebook
import matplotlib.pyplot as plt
import os, glob, errno
import argparse
import numpy as np
import warnings
import re
warnings.filterwarnings("ignore", category=UserWarning, module='pyannote')
# Here, we want to filter the following warning :
# UserWarning: 'uem' was approximated by the union of 'reference' and 'hypothesis' extents.
# "'uem' was approximated by the union of 'reference'"

def get_best_start(beginnings, durations, tot_duration):
    STEP_SIZE = 10
    beginnings = np.array(beginnings)
    lst = list(range(0, int(tot_duration), STEP_SIZE))
    best_sum_speech = 0.0
    best_start = 0
    for i in range(0, len(lst)):
        if i+7 > len(lst):
            break
        beg, end = lst[i], lst[i+6]
        condition = (beginnings > beg) & (beginnings < end)
        sum_speech = np.sum(np.extract(condition, durations))
        if sum_speech > best_sum_speech:
            best_start = beg
            best_sum_speech = sum_speech
    return best_start

def find_1mn_highest_volubility(annotation):
    support = list(annotation.get_timeline().support().__iter__())
    if len(support) > 0:
        tot_duration = support[-1].end
        if tot_duration <= 60.0:
            return 0.0, 60.0
        else:
            durations = [seg.duration for seg in support]
            beginnings = [seg.start for seg in support]
            best_start = get_best_start(beginnings, durations, tot_duration)
            return best_start, best_start + 60

def rttm_to_annotation(input_rttm, collapse_to_speech=False):
    """
        Given a path to a rttm file, create the corresponding Annotation objects
        containing the triplets (t_beg, t_end, activity)

    Parameters
    ----------
    input_rttm
        A path to a rttm file that must exist.

    Returns
    -------
        An Annotation object.
    """
    anno = Annotation(uri=input_rttm)
    if os.path.isfile(input_rttm):
        with open(input_rttm) as fn:
            for line in fn:
                row = re.sub(' +', ' ', line).replace('\t', ' ').replace('  ', ' ').split(' ')
                t_beg, t_dur, spkr = float(row[3]), float(row[4]), row[7]
                if row[7] == "":
                    raise ValueError("Speaker role is empty in %s" % os.path.basename(input_rttm))
                anno[Segment(t_beg, t_beg + t_dur)] = spkr
        return anno
    else:
        raise ValueError("%s not found. Please create it (even though it's empty) or remove the wav from the folder you want to evaluate." % os.path.basename(input_rttm))


def run_metrics(references_f, hypothesis_f, metrics, visualization=False):
    if len(references_f) != len(hypothesis_f):
        raise ValueError("The number of reference files and hypothesis files must match ! (%d != %d)"
                         % (len(references_f), len(hypothesis_f)))
    if visualization:
        visualization_dir = os.path.join(os.path.dirname(hypothesis_f[0]), "visualization")
        if not os.path.exists(visualization_dir):
            os.makedirs(visualization_dir)
    for ref_f, hyp_f in zip(references_f, hypothesis_f):
        ref, hyp = rttm_to_annotation(ref_f), rttm_to_annotation(hyp_f)
        basename = os.path.basename(ref_f)
        # Set the uri as the basename for both reference and hypothesis
        ref.uri, hyp.uri = basename, basename
        # Let's accumulate the score for each metrics
        for m in metrics.values():
            res = m(ref, hyp)

        # Let's generate a visualization of the results
        if visualization:
            moment = find_1mn_highest_volubility(ref)
            if moment is not None:
                # Set figure size, and crop the annotation
                # for the highest volubile moment
                start, end = moment[0], moment[1]
                notebook.width = end / 4
                plt.rcParams['figure.figsize'] = (notebook.width, 10)
                notebook.crop = Segment(start, end)

                # Plot reference
                plt.subplot(211)
                notebook.plot_annotation(ref, legend=True, time=False)
                plt.gca().set_title('reference '+ os.path.basename(ref_f).replace('.rttm', ''), fontdict={'fontsize':18})

                # Plot hypothesis
                plt.subplot(212)
                notebook.plot_annotation(hyp, legend=True, time=True)
                plt.gca().set_title('hypothesis '+os.path.basename(hyp_f).replace('.rttm', ''), fontdict={'fontsize':18})

                plt.savefig(os.path.join(visualization_dir, os.path.basename(hyp_f).replace('.rttm', '.png')))
                plt.close()
    return metrics


def get_couple_files(ref_path, hyp_path=None, prefix=None):
    # If hyp_path is None, then the hyp files are stored where the ref files are
    if prefix is not None:
        prefix = prefix + "_"

    ref_path = os.path.join("/vagrant", ref_path)

    if hyp_path is None:
        hyp_files = list(glob.iglob(os.path.join(ref_path, prefix+'*.rttm')))
        ref_files = [os.path.join(os.path.dirname(f), os.path.basename(f).replace(prefix, '')) for f in hyp_files]
    else:
        hyp_path = os.path.join("/vagrant", hyp_path)
        # Hyp files are stored in a different place, we check if a folder has been provided or if it just a single file
        if os.path.isdir(hyp_path):
            hyp_files = list(glob.iglob(os.path.join(hyp_path, prefix+'*.rttm')))
            ref_files = [os.path.join(ref_path, os.path.basename(f).replace(prefix, '')) for f in hyp_files]
        elif os.path.isfile(hyp_path):
            hyp_files = [hyp_path]
        else:
            raise ValueError("%s doesn't exist" % hyp_path)

    if len(ref_files) == 0 or len(hyp_files) == 0:
        raise FileNotFoundError("No reference, or no hypothesis found were found.")
    return sorted(ref_files), sorted(hyp_files)


def main():
    parser = argparse.ArgumentParser(description="Scripts that computes metrics between reference and hypothesis files."
                                                 "Inputs can be both path to folders or single file.")
    parser.add_argument('-ref', '--reference', type=str, required=True,
                        help="Path of the reference.")
    parser.add_argument('-hyp', '--hypothesis', type=str, required=False, default=None,
                        help="Path of the hypothesis"
                             "If None, consider that the hypothesis is stored where the reference is.")
    parser.add_argument('-p', '--prefix', required=True, choices=["lena", "noisemesSad", "opensmileSad",
                                                                    "tocomboSad", "yunitator_old", "yunitator_english",
                                                                    "yunitator_universal", "diartk_noisemesSad",
                                                                    "diartk_tocomboSad","diartk_opensmileSad",
                                                                    "diartk_goldSad", "yuniseg_noisemesSad",
                                                                    "yuniseg_opensmileSad", "yuniseg_tocomboSad",
                                                                    "yuniseg_goldSad"],
                        help="Prefix that filenames of the hypothesis must match.")
    parser.add_argument('-t', '--task', type=str, required=True, choices=["detection", "diarization", "identification"])
    parser.add_argument('-m', '--metrics', required=True, nargs='+', type=str, choices=["diaer", "coverage",
                                                                                        "completeness", "homogeneity",
                                                                                        "purity", "accuracy",
                                                                                        "precision", "recall", "deter",
                                                                                        "ider","idea"],
                        help="Metrics that need to be run.")
    parser.add_argument('--visualization', action='store_true')
    parser.add_argument('--identification', action='store_true')
    args = parser.parse_args()

    if args.identification:
        args.task = "identification"

    # Let's create the metrics
    metrics = {}
    for m in args.metrics:
        if m == "accuracy":                                                     # All the 3 tasks can be evaluated as a detection task
            metrics[m] = detection.DetectionAccuracy(parallel=True)
        elif m == "precision":
            metrics[m] = detection.DetectionPrecision(parallel=True)
        elif m == "recall":
            metrics[m] = detection.DetectionRecall(parallel=True)
        elif m == "deter":
            metrics[m] = detection.DetectionErrorRate(parallel=True)
        elif args.task == "diarization" or args.task == "identification":        # The diarization and the identification task can be both evaluated as a diarization task
            if m == "diaer":
                metrics[m] = diarization.DiarizationErrorRate(parallel=True)
            elif m == "coverage":
                metrics[m] = diarization.DiarizationCoverage(parallel=True)
            elif m == "completeness":
                metrics[m] = diarization.DiarizationCompleteness(parallel=True)
            elif m == "homogeneity":
                metrics[m] = diarization.DiarizationHomogeneity(parallel=True)
            elif m == "purity":
                metrics[m] = diarization.DiarizationPurity(parallel=True)
            elif args.task == "identification":                                 # Only the identification task can be evaluated as an identification task
                if m == "ider":
                    metrics[m] = identification.IdentificationErrorRate(parallel=True)
                elif m == "precision":
                    metrics[m] = identification.IdentificationPrecision(parallel=True)
                elif m == "recall":
                    metrics[m] = identification.IdentificationRecall(parallel=True)
            else:
                print("Filtering out %s, which is not available for the %s task." % (m, args.task))
        else:
            print("Filtering out %s, which is not available for the %s task." % (m, args.task))

    # Get files and run the metrics
    references_f, hypothesis_f = get_couple_files(args.reference, args.hypothesis, args.prefix)

    print("Pairs that have been found : ")
    for ref, hyp in zip(references_f, hypothesis_f):
        print("%s / %s "% (os.path.basename(ref), os.path.basename(hyp)))

    metrics = run_metrics(references_f, hypothesis_f, metrics, args.visualization)

    # Display a report for each metrics
    for name, m in metrics.items():
        print("\n%s report" % name)
        rep = m.report(display=True)
        colnames = list(rep.columns.get_level_values(0))
        percent_or_count = rep.columns.get_level_values(1)
        for i in range(0,len(percent_or_count)):
            if percent_or_count[i] == '%':
                colnames[i] = colnames[i] +' %'
        rep.columns = colnames
        rep.to_csv(os.path.join("/vagrant", args.reference, name+'_'+args.prefix+"_report.csv"))


if __name__ == '__main__':
    main()

