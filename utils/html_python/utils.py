from scipy.io import wavfile
import collections
import numpy as np
import os


# Utility functions
def write_value(fn, value, number_of_digits=4):
    if isinstance(value, str):
        fn.write('<td> %s </td>\n' % value)
    elif isinstance(value, float) or isinstance(value, np.float64) or isinstance(value, np.float32):
        fn.write('<td> %.*f</td>\n' % (number_of_digits, value))
    elif isinstance(value, int):
        fn.write('<td> %d </td>\n' % value)


def signaltonoise(a, axis=0, ddof=0):
    """
    The signal-to-noise ratio of the input data.
    Returns the signal-to-noise ratio of `a`, here defined as the mean
    divided by the standard deviation.
    Parameters
    ----------
    a : array_like
        An array_like object containing the sample data.
    axis : int or None, optional
        If axis is equal to None, the array is first ravel'd. If axis is an
        integer, this is the axis over which to operate. Default is 0.
    ddof : int, optional
        Degrees of freedom correction for standard deviation. Default is 0.
    Returns
    -------
    s2n : ndarray
        The mean to standard deviation ratio(s) along `axis`, or 0 where the
        standard deviation is 0.
    """
    a = np.asanyarray(a)
    m = a.mean(axis)
    sd = a.std(axis=axis, ddof=ddof)
    return np.where(sd == 0, 0, m / sd)

def analyze_wav(filepath):
    """
    Analyzes a wav file and returns some audio statistics.
    Parameters
    ----------
    filepath

    Returns
    -------
        statistics :
    """
    basename = os.path.splitext(os.path.basename(filepath))[0]

    if os.path.splitext(filepath)[1] == '.wav' and os.path.isfile(filepath):
        fs, data = wavfile.read(filepath)
        data_type = type(data[0])
        if data_type == np.int16:
            wav_format = '16-bit PCM'
            MAX_WAV_AMP = 32767.0
        elif data_type == np.int32:
            wav_format = '32-bit PCM'
            MAX_WAV_AMP = 2147483647.0
        elif data_type == np.uint8:
            wav_format = '8-bit PCM'
            MAX_WAV_AMP = 255.0
        elif data_type == np.float32:
            wav_format = '32-bit floating-point'
            MAX_WAV_AMP = 1.0

        # Normalization between -1 and 1
        data = data/MAX_WAV_AMP

        # Compute metrics
        duration = len(data)*1.0/fs
        mean_amplitude = np.mean(data)
        max_amplitude = np.max(data)
        snr = float(signaltonoise(data))
        statistics = collections.OrderedDict([("filename", basename),
                                              ("wav format", wav_format),
                                              ("duration (s)", duration),
                                              ("mean amplitude", mean_amplitude),
                                              ("max amplitude", max_amplitude),
                                              ("signal to noise ratio", snr)])
        return statistics


def _detect_overlap(t_beg, dur, t_beg_prev, dur_prev):

    if t_beg_prev + dur_prev > t_beg:
        if t_beg_prev+dur_prev > t_beg+dur:
            return dur
        else:
            return t_beg_prev + dur_prev - t_beg
    return 0.0


def analyze_rttm(filepath, dur_wav):
    basename = os.path.splitext(os.path.basename(filepath))[0]
    dict = collections.OrderedDict([("filename", basename),
                                    ("% total speech", 0.0),
                                    ("% overlap", 0.0),
                                    ("number of participants", 0)])

    if os.path.splitext(filepath)[1] == '.rttm' and os.path.isfile(filepath):
        fn = open(filepath)
        t_beg_prev, dur_prev, participant_prev = 0.0, 0.0, None
        for line in fn:
            fields = line.split()
            type, t_beg, dur, participant = fields[0], float(fields[3]), float(fields[4]), fields[7]

            # Add information about the participant
            prop_key = "% of "+participant
            if prop_key in dict:
                dict[prop_key] += dur
            else:
                dict[prop_key] = dur

            # Add information about the overall speech
            if type == 'SPEAKER':
                dict["% total speech"] += dur

            # Compute overlap
            dict["% overlap"] += _detect_overlap(t_beg, dur, t_beg_prev,dur_prev)

            # Update previous
            t_beg_prev, dur_prev, participant_prev = t_beg, dur, participant

        # Normalization step
        # Normalize participants speech duration by total speech
        if dict["% total speech"]:
            for k, v in dict.items():
                if k.startswith("% of "):
                    dict["number of participants"] += 1
                    dict[k] /= dict["% total speech"]
            # Normalize % overlap by total speech
            dict["% overlap"] /= dict["% total speech"]

        # Normalize total speech by wav duration
        dict["% total speech"] /= dur_wav

        fn.close()
        return dict

def get_averages(df_path):
    column_sums = None
    basename = os.path.splitext(os.path.basename(df_path))[0]
    with open(df_path) as file:
        header=file.readline()
        header=header.replace('\n','').split('\t')
        if header[0] == 'filename':
            header=header[1:]

        lines = file.readlines()
        rows_of_numbers = [map(float, line.replace('%','').replace('\n','').replace('NA','0.0').split('\t')[1:]) for line in lines]
        sums = map(sum, zip(*rows_of_numbers))
        averages = [sum_item / len(lines) for sum_item in sums]

        # Add model name
        header.insert(0, 'filename')
        averages.insert(0, basename)
        averages = collections.OrderedDict(zip(header, averages))
        return averages

