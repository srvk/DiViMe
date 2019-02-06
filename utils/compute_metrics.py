from pyannote.core import Segment, Timeline, Annotation
from pyannote.metrics.diarization import DiarizationErrorRate
import os, glob, errno
import argparse
from own_metrics import StatSpkr

def rttm_to_annotation(input_rttm):
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
    anno = Annotation(uri=input_rttm) # Maybe remove the prefix here ?
    if os.path.isfile(input_rttm):
        with open(input_rttm) as fn:
            for line in fn:
                row = line.split('\t')
                t_beg, t_dur, spkr = float(row[3]), float(row[4]), row[7]
                anno[Segment(t_beg, t_beg+t_dur)] = spkr
    return anno


def run_metrics(references_f, hypothesis_f, metrics):
    if len(references_f) != len(hypothesis_f) :
        raise ValueError("The number of reference files and hypothesis files must match ! (%d != %d)"
                         % (len(references_f), len(hypothesis_f)))

    for ref_f, hyp_f in zip(references_f, hypothesis_f):
        ref, hyp = rttm_to_annotation(ref_f), rttm_to_annotation(hyp_f)
        basename = os.path.basename(ref_f)
        # Set the uri as the basename for both reference and hypothesis
        ref.uri, hyp.uri = basename, basename
        # Let's accumulate the score for each metrics
        for m in metrics.values():
            m(ref, hyp)
    return metrics


def get_couple_files(ref_path, hyp_path=None, prefix=None):
    # If hyp_path is None, then the hyp files are stored where the ref files are
    if prefix is not None:
        prefix = prefix + "_"

    ref_path = os.path.join("/vagrant", ref_path)
    if hyp_path is None:
        hyp_files = list(glob.iglob(os.path.join(ref_path, prefix+'*.rttm')))
        ref_files = [f.replace(prefix, '') for f in hyp_files]
    else:
        # Hyp files are stored in a different place, we check if a folder has been provided or if it just a single file
        if os.path.isdir(hyp_path):
            hyp_files = list(glob.iglob(os.path.join(hyp_path, prefix+'*.rttm')))
            ref_files = [f.replace(prefix, '').replace(hyp_files, ref_path) for f in hyp_files]
        elif os.path.isfile(hyp_path):
            hyp_files = [hyp_path]
        else:
            raise ValueError("%s doesn't exist" % hyp_path)

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
                                                                    "tocomboSad", "yunitate", "diartk_noisemesSad",
                                                                    "diartk_tocomboSad","diartk_opensmileSad",
                                                                    "diartk_goldSad", "yuniseg_noisemesSad",
                                                                    "yuniseg_opensmileSad", "yuniseg_tocomboSad",
                                                                    "yuniseg_goldSad"],
                        help="Prefix that filenames of the hypothesis must match.")
    parser.add_argument('-m', '--metrics', required=True, nargs='+', type=str, choices=["DER", "act", "c", "d"],
                        help="Metrics that need to be run.")
    args = parser.parse_args()

    # Let's create the metrics
    metrics = {}
    for m in args.metrics:
        if m == "DER":
            metrics[m] = DiarizationErrorRate(parallel=True)
        elif m == "act":
            metrics[m] = StatSpkr(parallel=True)

    # Get files and run the metrics
    references_f, hypothesis_f = get_couple_files(args.reference, args.hypothesis, args.prefix)
    metrics = run_metrics(references_f, hypothesis_f, metrics)

    # Display a report for each metrics
    for name, m in metrics.items():
        print("%s report" % name)
        m.report(display=True)


if __name__ == '__main__':
    main()

