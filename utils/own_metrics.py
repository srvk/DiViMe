from pyannote.metrics.base import BaseMetric
import pandas as pd

# This metric is for computing % of CHI speech, % of MAL speech, % of FEM speech.

# Further improvements :
# - Computing % overlap

label_map = {
    'Autre': 'NONE',
    'ADU': 'NONE',
    'Bro': 'CHI',       # Brother
    'BRO': 'CHI',
    'C1': 'CHI',
    'C2': 'CHI',
    'Chi': 'CHI',
    'CHI': 'CHI',
    'CHF': 'CHI',
    'CXF': 'CHI',
    'CHI2': 'CHI',
    'CHNNSP': 'CHI',
    'CHNSP': 'CHI',
    'CXN': 'CHI',
    'CHI*': 'CHI',
    'EE1': 'NONE',      # electronic
    'FA1': 'FEM',    # female adult
    'FA2': 'FEM',
    'FA3': 'FEM',
    'FA4': 'FEM',
    'FA5': 'FEM',
    'FA6': 'FEM',
    'FA7': 'FEM',
    'FA8': 'FEM',
    'FAE': 'NONE',      # female adult electronic
    'FAN': 'FEM',
    'MAN': 'MAL',
    'FAF': 'FEM',
    'FAT': 'MAL',      # father
    'FC1': 'CHI',       # female child
    'FC2': 'CHI',
    'FC3': 'CHI',
    'FC4': 'CHI',
    'FEM': 'FEM',
    'FEM2': 'FEM',
    'Gra': 'NONE',
    'GRF': 'MAL',      # Grand-father
    'GRM': 'FEM',    # Grand-mother
    'IN1': 'NONE',     # Investigator
    'IN2': 'NONE',
    'Inv': 'NONE',
    'INV': 'NONE',
    'lui': 'MAL',
    'LF2P': 'NONE',
    'MA1': 'MAL',
    'MA2': 'MAL',
    'MA3': 'MAL',
    'MA4': 'MAL',
    'MA5': 'MAL',
    'MA6': 'MAL',
    'MAE': 'NONE',      # Male adult electronic
    'MAF': 'MAL',
    'MAL': 'MAL',
    'MC1': 'CHI',       # Male child
    'MC2': 'CHI',
    'MC3': 'CHI',
    'MC4': 'CHI',
    'MC5': 'CHI',
    'MC6': 'CHI',
    'MI1': 'MAL',
    'Mot': 'FEM',    # Mother
    'MOT': 'FEM',
    'MOT*': 'FEM',
    'NOF': 'None',
    'NON': 'None',
    'TVF': 'None',
    'TVN': 'None',
    'UA1': 'None',     # Unknown adult
    'UC1': 'CHI',       # Unknown child
    'UC2': 'CHI',
    'UC3': 'CHI',
    'UC4': 'CHI',
    'UC5': 'CHI',
    'UC6': 'CHI',
    'UU1': 'NONE',      # Unknown unknown
    'OCH': 'CHI',       # other child
    'OLF': 'None',
    'OLN': 'None',
    'OTH': 'None',
    'Sis': 'CHI',       # Sister
    'SIS': 'CHI',
    'Uni': 'NONE',      # Unidentified
    'silences': 'NONE',
    '2POPMT': 'NONE',
    '<NA>': 'NONE',
    '': 'NONE',
    'SIL': 'NONE'
}


def is_CHI(speaker_name):
    # black magic that returns True if speaker is a man, False otherwise
    return label_map[speaker_name] == 'CHI'


def is_MAL(speaker_name):
    return label_map[speaker_name] == 'MAL'


def is_FEM(speaker_name):
    return label_map[speaker_name] == 'FEM'


class StatSpkr(BaseMetric):
    @classmethod
    def metric_name(cls):
        # Return human-readable name of the metric
        return 'speaker activity'

    @classmethod
    def metric_components(cls):
        # Return component names from which the metric is computed
        return ['CHI_ref', 'MAL_ref', 'FEM_ref', 'CHI_hyp', 'MAL_hyp', 'FEM_hyp']

    def compute_components(self, reference, hypothesis, **kwargs):
        # Actually compute the value of each component
        total_duration_hyp, total_duration_ref = 0.0, 0.0
        components = {'CHI_ref': 0., 'MAL_ref': 0., 'FEM_ref': 0.,
                      'CHI_hyp': 0., 'MAL_hyp': 0., 'FEM_hyp': 0.}

        for segment, _, speaker_name in hypothesis.itertracks(yield_label=True):
            if is_CHI(speaker_name):
                components['CHI_hyp'] += segment.duration
                total_duration_hyp += segment.duration
            elif is_MAL(speaker_name):
                components['MAL_hyp'] += segment.duration
                total_duration_hyp += segment.duration
            elif is_FEM(speaker_name):
                components['FEM_hyp'] += segment.duration
                total_duration_hyp += segment.duration

        for segment, _, speaker_name in reference.itertracks(yield_label=True):
            if is_CHI(speaker_name):
                components['CHI_ref'] += segment.duration
                total_duration_ref += segment.duration
            elif is_MAL(speaker_name):
                components['MAL_ref'] += segment.duration
                total_duration_ref += segment.duration
            elif is_FEM(speaker_name):
                components['FEM_ref'] += segment.duration
                total_duration_ref += segment.duration

        if total_duration_hyp != 0.0:
            components['CHI_hyp'] /= total_duration_hyp
            components['MAL_hyp'] /= total_duration_hyp
            components['FEM_hyp'] /= total_duration_hyp
        else:
            components['CHI_hyp'] = 0.0
            components['MAL_hyp'] = 0.0
            components['FEM_hyp'] = 0.0

        if total_duration_ref != 0.0:
            components['CHI_ref'] /= total_duration_ref
            components['MAL_ref'] /= total_duration_ref
            components['FEM_ref'] /= total_duration_ref
        else:
            components['CHI_ref'] = 0.0
            components['MAL_ref'] = 0.0
            components['FEM_ref'] = 0.0

        return components

    def compute_metric(self, components):
        # Actually compute the metric based on the component values
        return ''

    def report(self, display=False):
        """Evaluation report
        Parameters
        ----------
        display : bool, optional
            Set to True to print the report to stdout.
        Returns
        -------
        report : pandas.DataFrame
            Dataframe with one column per metric component, one row per
            evaluated item, and one final row for accumulated results.
        """

        report = []
        uris = []

        percent = 'total' in self.metric_components()

        for uri, components in self.results_:
            row = {}
            if percent:
                total = components['total']
            for key, value in components.items():
                if key == self.name:
                    row[key, '%'] = 100 * value
                else:
                    row[key, ''] = 100 * value
                    if percent:
                        if total > 0:
                            row[key, '%'] = 100 * value / total
                        else:
                            row[key, '%'] = np.NaN

            report.append(row)
            uris.append(uri)

        row = {}
        components = self.accumulated_

        if percent:
            total = components['total']

        for key, value in components.items():
            if key == self.name:
                row[key, '%'] = 100 * value
            elif key == 'total':
                row[key, ''] = value
            else:
                row[key, ''] = value
                if percent:
                    row[key, '%'] = 100 * value / total
        row[self.name, '%'] = 100 * abs(self)
        report.append(row)
        uris.append('AVERAGE')

        df = pd.DataFrame(report)

        df['item'] = uris
        df = df.set_index('item')

        df.columns = pd.MultiIndex.from_tuples(df.columns)

        df = df[[self.name] + self.metric_components()]

        if display:
            print(df.to_string(index=True, sparsify=False, justify='right',
                               float_format=lambda f: '{0:.2f}'.format(f)))
        return df
