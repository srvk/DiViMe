import os
import glob
import shutil
import numpy as np
import argparse
from math import floor, ceil

### GLOBAL VARIABLE
default_test_prop = 0.5

def _create_empty_train_test(input_folder):
    """
    Given an input folder, create a train and test folder.
    If these folders already exist, move their content to the input folder before creating new train and test folders.

    Parameters
    ----------
    input_folder    path to the input folder

    Returns
    -------
            path of the train folder and path of the test folder
    """
    train_folder, test_folder = os.path.join(input_folder, 'train'), os.path.join(input_folder, 'test')

    # Bring back files to the parent directory
    files = glob.glob(os.path.join(train_folder, '*'))+glob.glob(os.path.join(test_folder, '*'))
    for path_f in files:
        basename = os.path.basename(path_f)
        shutil.move(path_f, os.path.join(input_folder, basename))

    # Delete train and test folder
    if os.path.isdir(train_folder):
        shutil.rmtree(train_folder)

    if os.path.isdir(test_folder):
        shutil.rmtree(test_folder)

    # Create new ones
    os.makedirs(train_folder)
    os.makedirs(test_folder)

    return train_folder, test_folder


def split(input_folder, test_prop, train_prop):
    """
    Given an input folder, a proportion for the test set, a proportion for the training set, split the pairs
    (.wav/.rttm) into a training folder and a test folder.

    Parameters
    ----------
    input_folder    the path to the input folder (containing wav and rttm files)
    test_prop       the proportion of the data that will be included in the test set
    train_prop      the proportion of the data that will be included in the training set
    """
    # Create empty train and test directories.
    # Move their content to the parent directory if they already exist
    train_folder, test_folder = _create_empty_train_test(input_folder)

    # Check for all the wav into the the input_folder
    wav = np.array(glob.glob(os.path.join(input_folder, "*.wav")))
    np.random.shuffle(wav)

    n_samples = len(wav)
    n_train, n_test = np.int(floor(train_prop*n_samples)), np.int(ceil(test_prop*n_samples))

    training_idx = np.arange(n_train)
    test_idx = np.arange(n_train, n_train + n_test)

    train, test = wav[training_idx], wav[test_idx]

    # Move wav files ONLY if an associated rttm is found
    for train_f in train:
        basename = os.path.splitext(os.path.basename(train_f))[0]
        old_path = os.path.join(input_folder, basename)
        new_path = os.path.join(train_folder, basename)
        if os.path.exists(old_path+'.rttm'):
            os.rename(old_path+'.rttm', new_path+'.rttm')
            os.rename(old_path+'.wav', new_path+'.wav')
        else:
            print("Ignoring file %s whose rttm has not been found." % (basename+'.wav'))

    for test_f in test:
        basename = os.path.splitext(os.path.basename(test_f))[0]
        old_path = os.path.join(input_folder, basename)
        new_path = os.path.join(test_folder, basename)
        if os.path.exists(old_path+'.rttm'):
            os.rename(old_path+'.rttm', new_path+'.rttm')
            os.rename(old_path+'.wav', new_path+'.wav')
        else:
            print("Ignoring file %s whose rttm has not been found." % (basename+'.wav'))

    n_real_train = len([f for f in glob.glob(os.path.join(train_folder, '*')) if os.path.isfile(f)]) / 2
    n_real_test = len([f for f in glob.glob(os.path.join(test_folder, '*')) if os.path.isfile(f)]) / 2

    if n_real_train == 0:
        print("Warning : The training set that you generated is empty !")
    if n_real_test == 0:
        print("Warning : The test set that you generated is empty !")





def main():
    parser = argparse.ArgumentParser(description="Split a folder into a train set and a test set.")
    parser.add_argument('-f', '--folder', type=str, required=True,
                        help='path to the folder that needs to be splitted.')
    parser.add_argument('--test_prop', type=float, default=None,
                        help='''a float between 0.0 and 1.0 representing the proportion of the
                        dataset to include in the test set. If not specfied, the
                        value is automatically set to the complement of the
                        --train_prop.  If --train_prop is not specified, --test_prop is set to
                        {}'''.format(default_test_prop))
    parser.add_argument('--train_prop', default=None, type=float,
                        help='''a float between 0.0 and 1.0 representing the proportion of the
                         dataset to include in the train set. If not specified, the
                         value is automatically set to the complement of --test_prop''')
    parser.add_argument('-r', '--random_seed', default=None, type=int,
                        help='Seed the generator (for reproducible results)')
    args = parser.parse_args()

    if args.train_prop is None:
        test_prop = default_test_prop if args.test_prop is None else args.test_prop
    else:
        test_prop = 1.0-args.train_prop if args.test_prop is None else args.test_prop
    train_prop = args.train_prop

    if test_prop < 0.0 or test_prop > 1.0 or train_prop < 0.0 or train_prop > 1.0:
        raise ValueError("The test proportion and the train proportion must be between 0 and 1")

    data_dir = "/vagrant"
    input_folder = os.path.join(data_dir, args.folder)
    if not os.path.isdir(input_folder):
        raise ValueError("The folder that you want to split is not found. Please check the path that you provided.")

    # Set the random seed
    if args.random_seed is not None:
        np.random.seed(args.random_seed)

    split(input_folder, test_prop, train_prop)


if __name__ == '__main__':
    main()