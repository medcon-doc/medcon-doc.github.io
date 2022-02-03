# -*- coding: utf-8 -*-
import matplotlib.pyplot as pyplot
import matplotlib
from matplotlib.offsetbox import AnchoredText
import six
from sklearn.metrics import roc_curve, auc, precision_recall_curve, average_precision_score, precision_score, recall_score, f1_score
import argparse
from os import path
import numpy
import numbers
import csv
from operator import itemgetter


class ROCPRCPlotter(object):
    def __init__(self, tsv_file, out_dir):
        self.tsv_file = tsv_file
        self.out_dir = out_dir

    def plot_roc(self):
        # read scores
        # sort scores in dictionaries
        coded_items = dict()

        # only care about validated certain relevant items
        relevance_types = ['VCR']

        for cnT in [('Australia', 100), ('Australia', 500), ('Australia', 1000),
                    ('Switzerland', 100), ('Switzerland', 500), ('Switzerland', 1000),
                    ('Turkey', 100), ('Turkey', 500), ('Turkey', 1000)]:
            coded_items[cnT] = {'UNR+UR+CR': [], 'UR+CR': [], 'CR': [], 'VCR': [], 'scores': []}

        with open(self.tsv_file) as tf:
            tf = csv.DictReader(tf, delimiter='\t')
            for item in tf:
                # filter out unranked items (i.e. items with less than 50 words)
                if not 0 <= float(item['relevance_500']) <= 1:
                    continue

                # VCR (validated relevant)
                try:
                    relevant = int(item['relevant'])
                except ValueError:
                    print(item)
                    raise

                # NR (not relevant)
                if item['code'] == "2":
                    codes = (0, 0, 0, relevant)
                # UNR (uncertain not relevant)
                elif item['code'] == "4":
                    codes = (1, 0, 0, relevant)
                # UR (uncertain relevant)
                elif item['code'] == "3":
                    codes = (1, 1, 0, relevant)
                # CR (certain relevant)
                elif item['code'] == "1":
                    codes = (1, 1, 1, relevant)

                # 100
                node = coded_items[(item['country'], 100)]
                for idx, relType in enumerate(relevance_types):
                    node[relType].append(codes[idx])
                node['scores'].append(float(item['relevance_100']))

                # 500
                node = coded_items[(item['country'], 500)]
                for idx, relType in enumerate(relevance_types):
                    node[relType].append(codes[idx])
                node['scores'].append(float(item['relevance_500']))

                # 1000
                node = coded_items[(item['country'], 1000)]
                for idx, relType in enumerate(relevance_types):
                    node[relType].append(codes[idx])
                node['scores'].append(float(item['relevance_1000']))

        # set up combined figures (3x3 grid)
        fig_prc, ax_prc = pyplot.subplots(3, 3, sharey=True, sharex=True, squeeze=True)
        fig_roc, ax_roc = pyplot.subplots(3, 3, sharey=True, sharex=True, squeeze=True)

        # give ordinate for subplot in combined figure
        country2ord = dict([(country, coord) for coord, country in enumerate(['Australia', 'Switzerland', 'Turkey'])])
        numtopics2ord = dict([(nt, coord) for coord, nt in enumerate([100, 500, 1000])])

        for (country, numTopics) in coded_items:
            # get a reference to the current subplot in the combined plot
            cur_ax_prc = ax_prc[country2ord[country], numtopics2ord[numTopics]]
            cur_ax_roc = ax_roc[country2ord[country], numtopics2ord[numTopics]]

            # calculate roc and prc
            # get reference to the data for the curves
            data = coded_items[(country, numTopics)]

            fpr, tpr, thresholds = roc_curve(data['VCR'], data['scores'])
            roc_auc = auc(fpr, tpr)

            precision, recall, _ = precision_recall_curve(data['VCR'], data['scores'])

            # optimize f1 score
            f1_scores = []
            precision_scores = []
            recall_scores = []
            threshold_scores = []

            def binarize(x, thresh):
                if x >= thresh:
                    return 1
                else:
                    return 0

            for threshold in thresholds:
                if not 0 <= threshold <= 1:
                    continue

                # binarize the scores for the current threshold and calculate the f1 score for the threshold
                binary_scores = [binarize(dp, threshold) for dp in data['scores']]
                p = precision_score(data['VCR'], binary_scores)
                precision_scores.append(p)
                r = recall_score(data['VCR'], binary_scores)
                recall_scores.append(r)
                threshold_scores.append(threshold)
                f1_scores.append((p,
                                  r,
                                  f1_score(data['VCR'], binary_scores)))

            # find the maximum f1 score
            prec, rec, fscore = max(f1_scores, key=itemgetter(2))

            # calculate average precision
            average_precision = average_precision_score(data['VCR'], data['scores'])

            # draw average precision into graph
            text_string = "F1: %.2f\nAP: %.2f" % (fscore, average_precision)
            cur_ax_prc.add_artist(AnchoredText(text_string, loc=2))

            # plot ROC
            cur_ax_roc.plot(fpr, tpr, color='red',
                    lw=2, label='ROC curve %s (AUC = %0.2f)' % ('VCR', roc_auc))
            cur_ax_roc.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
            cur_ax_roc.set_xlim([0, 1])
            cur_ax_roc.set_ylim([0, 1.05])
            cur_ax_roc.set_yticks((0, 0.3, 0.6, 0.9))
            cur_ax_roc.set_xticks((0, 0.3, 0.6, 0.9))
            text_string = "AUC %.2f" % (roc_auc)
            cur_ax_roc.add_artist(AnchoredText(text_string, loc=4))

            # plot PRC
            cur_ax_prc.set_label('VCR')
            cur_ax_prc.set_xlim([0, 1])
            cur_ax_prc.set_ylim([0, 1])
            cur_ax_prc.set_xticks((0.0, 0.3, 0.6, 0.9))
            cur_ax_prc.set_yticks((0.0, 0.3, 0.6, 0.9))
            cur_ax_prc.step(recall, precision, color='b', alpha=0.2, where='post')
            cur_ax_prc.fill_between(recall, precision, step='post', alpha=0.2, color='b')

        # format multi roc plot
        # add row / column labels
        ax_roc[0, -1].set_ylabel("Australia")
        ax_roc[0, -1].yaxis.set_label_position("right")
        ax_roc[1, -1].set_ylabel("Switzerland")
        ax_roc[1, -1].yaxis.set_label_position("right")
        ax_roc[2, -1].set_ylabel("Turkey")
        ax_roc[2, -1].yaxis.set_label_position("right")
        ax_roc[0, 0].set_xlabel("100 topics")
        ax_roc[0, 0].xaxis.set_label_position("top")
        ax_roc[0, 1].set_xlabel("500 topics")
        ax_roc[0, 1].xaxis.set_label_position("top")
        ax_roc[0, 2].set_xlabel("1000 topics")
        ax_roc[0, 2].xaxis.set_label_position("top")
        ax_roc[1, 0].set_ylabel("True Positive Rate")
        ax_roc[-1, 1].set_xlabel("False Positive Rate")

        # set common labels
        fig_roc.text(0.5, -0.04, 'Recall', ha='center', va='center')
        fig_roc.text(-0.04, 0.5, 'Precision', ha='center', va='center', rotation='vertical')
        fig_roc.subplots_adjust(hspace=0.05, wspace=0.05)

        # write plot
        fig_roc.savefig(path.join(self.out_dir, "multi_roc.pdf"))
        fig_roc.savefig(path.join(self.out_dir, "multi_roc.svg"))

        # format multi prc plot
        # add row / column labels
        ax_prc[0, -1].set_ylabel("Australia")
        ax_prc[0, -1].yaxis.set_label_position("right")
        ax_prc[1, -1].set_ylabel("Switzerland")
        ax_prc[1, -1].yaxis.set_label_position("right")
        ax_prc[2, -1].set_ylabel("Turkey")
        ax_prc[2, -1].yaxis.set_label_position("right")
        ax_prc[0, 0].set_xlabel("100 topics")
        ax_prc[0, 0].xaxis.set_label_position("top")
        ax_prc[0, 1].set_xlabel("500 topics")
        ax_prc[0, 1].xaxis.set_label_position("top")
        ax_prc[0, 2].set_xlabel("1000 topics")
        ax_prc[0, 2].xaxis.set_label_position("top")
        ax_prc[1, 0].set_ylabel("Precision")
        ax_prc[-1, 1].set_xlabel("Recall")
        ax_prc[1, 0].legend(loc=6, fontsize=9)
        fig_prc.subplots_adjust(hspace=0.05, wspace=0.05)

        # write plot
        fig_prc.savefig(path.join(self.out_dir, "multi_prc.pdf"))
        fig_prc.savefig(path.join(self.out_dir, "multi_prc.svg"))


if __name__ == '__main__':
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--tsv-file", help="path to tsv file containing cell results")
    parser.add_argument("--out-dir", help="path to output the roc and prc curves to")

    args = parser.parse_args()

    # set up combiner & combine
    roc_prc_plotter = ROCPRCPlotter(tsv_file=args.tsv_file, out_dir=args.out_dir)
    roc_prc_plotter.plot_roc()