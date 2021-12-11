#!/usr/bin/env python3

import sys
import csv
import html


def get_filemeta(meta, file_id):
    """return formatted metadata string by file_id"""
    d = meta[file_id]
    s = " ".join(['{}="{}"'.format(k, html.escape(v)) for k, v in d.items()])
    return "<doc {}>".format(s)


def main():
    metafile = sys.argv[1]
    file_id = sys.argv[2]
    meta = {}
    with open(metafile, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            meta[row['id']] = row
    print(get_filemeta(meta, file_id))


if __name__ == '__main__':
    main()
