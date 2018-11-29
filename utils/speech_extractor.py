import argparse
import os
import sys
import subprocess


def extracts_speech(wav, sad, out):
    """
    Read a .rttm file and extracts segments of the wav files that
    have been annotated as being speech.

    :param wav: Path to the audio file (.wav).
    :param sad: Path to the rttm file (.rttm).
    :param out: Folder where the segments need to be stored.
    """
    if not os.path.isfile(wav):
        print("The audio file %s has not been found." % wav)
        sys.exit(1)

    if not os.path.isfile(sad):
        print("The SAD file %s has not been found." % sad)
        sys.exit(1)

    with open(sad, 'r') as rttm:
        for line in rttm:
            # Replace tabulations by spaces
            fields = line.replace('\t', ' ')
            # Remove several successive spaces
            fields = ' '.join(fields.split())
            fields = fields.split(' ')
            onset, duration, activity = float(fields[3]), float(fields[4]), fields[7]
            offset = onset+duration
            if activity == 'speech':
                basename = os.path.basename(wav).split('.wav')[0]
                output = os.path.join(out, '_'.join([basename, str(onset), str(offset)])+'.wav')
                cmd = ['sox', wav, output,
                       'trim', str(onset), str(duration)]
                print("Cutting %s from %s to %s " % (os.path.basename(wav), str(onset), str(offset)))
                subprocess.call(cmd)

def main():
    parser = argparse.ArgumentParser(description="Extracts segments that have"
                                                 "been annotated as speech by"
                                                 "a SAD tool.")
    parser.add_argument('-i', '--input', type=str, required=True,
                        help="Path to the .wav files (or to the folder containing wav files).")
    parser.add_argument('-s', '--sad', type=str, required=False, default="gold",
                        choices=["ldc_sad", "noisemes", "opensmile", "tocombosad", "gold"],
                        help="Indicates which SAD needs to be used to extract the audio file.")
    parser.add_argument('-o', '--output', type=str, required=False,
                        help="Path to the folder where the extracted segments need to be stored. "
                             "(Relative to the input folder)")
    args = parser.parse_args()

    wav = os.path.join("/vagrant", args.input)
    if args.output is not None:
        out = os.path.join(os.path.dirname(wav), args.output)
    else:
        out = os.path.dirname(wav)

    if not os.path.exists(out):
        os.makedirs(out)

    name_map = {
        'ldc_sad': 'ldcSad_',
        'noisemes': 'noisemes_sad_',
        'opensmile': 'opensmileSad_',
        'tocombosad': 'tocomboSad_',
        'gold': '',
    }

    sad = os.path.join(os.path.dirname(wav), name_map[args.sad] + os.path.basename(wav).replace(".wav", ".rttm"))
    print(sad)
    extracts_speech(wav, sad, out)


if __name__ == '__main__':
    main()