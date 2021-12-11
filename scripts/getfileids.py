#!/usr/bin/env python3

import sys
import csv


def get_filepath(row):
    """return formatted metadata string by file_id"""
    return "vert/{}.vert".format(row['id'])


def main():
    metafile = sys.argv[1]
    with open(metafile, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            print(get_filepath(row))


if __name__ == '__main__':
    main()
