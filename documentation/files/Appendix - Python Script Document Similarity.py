import argparse
import csv
import os
import progressbar
import regex
import unicodedata
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
from six import u, iteritems
import random
from collections import Counter
from multiprocessing import Pool
import json

sample_size = 2000
samples = 5

REPLACE_DASH = regex.compile(ur'[\p{Pd}\/\\]', regex.UNICODE)  # replace with \s
TOKENIZE = regex.compile(ur'((\p{P}*+(?:\p{L}|\p{M}|\d)+\p{P}*+)+)', regex.UNICODE)  # tokenizer
STRIP_QUOTES = regex.compile(ur'[\p{Ps}\p{Pe}\p{Pi}\p{Pf}\p{Pc}]', regex.UNICODE)  # remove before lemmatization
STRIP_PUNCTUATION = regex.compile(ur'\p{P}', regex.UNICODE)  # remove after lemmatization

# fix seeds for each source, so the random sample can be reproduced
random_ints = {
    "Germany\\German\\Blog\\143.csv": -993048719,
    "Turkey\\English\\Blog\\189.csv": 829719491,
    "Lebanon\\Arabic\\News Website\\504.csv": 140107620,
    "Turkey\\Turkish\\News Website\\126.csv": 66281975,
    "Germany\\German\\News Website\\106.csv": -1735384588,
    "Switzerland\\German\\Blog\\165.csv": 1970275544,
    "Lebanon\\English\\Blog\\160.csv": -1562840892,
    "Australia\\English\\Printed Newspaper\\801.csv": -1900059401,
    "USA\\English\\News Website\\506.csv": 740537633,
    "USA\\English\\Blog\\178.csv": 442595856,
    "Lebanon\\English\\Blog\\157.csv": 2007563887,
    "Germany\\German\\Blog\\142.csv": -1900636937,
    "Turkey\\Turkish\\News Website\\121.csv": -1484292749,
    "USA\\English\\Blog\\180.csv": 1567361526,
    "Australia\\English\\News Website\\103.csv": -1575830147,
    "USA\\English\\Blog\\186.csv": 957526075,
    "Switzerland\\German\\News Website\\113.csv": 1661166685,
    "USA\\English\\Blog\\177.csv": -1201063143,
    "Lebanon\\English\\Blog\\155.csv": -1024233509,
    "USA\\English\\Printed Newspaper\\804.csv": 598080271,
    "Australia\\English\\Blog\\136.csv": 2023246858,
    "USA\\English\\Blog\\182.csv": 1285412226,
    "Turkey\\Turkish\\Blog\\191.csv": 2001568858,
    "Lebanon\\Arabic\\News Website\\501.csv": 1226890311,
    "Australia\\English\\Blog\\137.csv": 7339168,
    "Switzerland\\German\\Blog\\170.csv": 534729766,
    "Germany\\German\\News Website\\110.csv": 1454218083,
    "Germany\\German\\Blog\\148.csv": 991292546,
    "USA\\English\\News Website\\131.csv": -908952536,
    "Germany\\German\\News Website\\111.csv": -77787653,
    "Lebanon\\Arabic\\News Website\\503.csv": 873536705,
    "Switzerland\\German\\Blog\\168.csv": 872859986,
    "Australia\\English\\News Website\\104.csv": 1485404481,
    "Germany\\German\\Blog\\147.csv": -538132398,
    "Switzerland\\German\\News Website\\114.csv": -1092897992,
    "Switzerland\\German\\Blog\\171.csv": 727023370,
    "Australia\\English\\Blog\\135.csv": -2085574599,
    "Turkey\\Turkish\\Blog\\190.csv": 236166568,
    "Germany\\German\\News Website\\109.csv": 1249647225,
    "Switzerland\\German\\Blog\\167.csv": 141388524,
    "Turkey\\Turkish\\Blog\\197.csv": -1770443648,
    "Germany\\German\\Printed Newspaper\\806.csv": 706335733,
    "Turkey\\Turkish\\News Website\\120.csv": -2066010878,
    "Turkey\\Turkish\\Blog\\196.csv": -938621106,
    "USA\\English\\Blog\\185.csv": -2040879454,
    "Germany\\German\\Blog\\144.csv": 1157346618,
    "Lebanon\\Arabic\\News Website\\502.csv": -195302750,
    "Australia\\English\\Blog\\139.csv": -1300331023,
    "Switzerland\\German\\Blog\\166.csv": 476597094,
    "USA\\English\\Printed Newspaper\\805.csv": -196033710,
    "Switzerland\\German\\Blog\\195.csv": 979904035,
    "Lebanon\\English\\Blog\\162.csv": 34008612,
    "Germany\\German\\Blog\\151.csv": 181713213,
    "USA\\English\\Blog\\184.csv": 1419134095,
    "Australia\\English\\Printed Newspaper\\802.csv": -700315207,
    "Switzerland\\German\\Printed Newspaper\\809.csv": -830552140,
    "Australia\\English\\Blog\\138.csv": -29748961,
    "Switzerland\\German\\News Website\\117.csv": -987480987,
    "Turkey\\Turkish\\News Website\\123.csv": 499561071,
    "USA\\English\\Blog\\176.csv": 1977981704,
    "Turkey\\Turkish\\Blog\\187.csv": 2052912552,
    "USA\\English\\News Website\\130.csv": 207920563,
    "Turkey\\Turkish\\News Website\\127.csv": 177476533,
    "USA\\English\\Blog\\183.csv": 1989978141,
    "Lebanon\\English\\Blog\\159.csv": 1960510899,
    "Turkey\\Turkish\\Blog\\172.csv": -90826110,
    "Australia\\English\\Blog\\133.csv": 2097260196,
    "Lebanon\\Arabic\\News Website\\508.csv": -1913173670,
    "Lebanon\\English\\Blog\\154.csv": 1784168878,
    "USA\\English\\News Website\\128.csv": 2141744485,
    "Germany\\German\\Printed Newspaper\\808.csv": -1409491484,
    "Switzerland\\German\\Blog\\164.csv": -472660176,
    "Switzerland\\German\\Blog\\192.csv": -1619970184,
    "Turkey\\Turkish\\News Website\\124.csv": 1124528124,
    "Germany\\German\\Blog\\149.csv": 1367777082,
    "Australia\\English\\News Website\\101.csv": -1974150382,
    "USA\\English\\News Website\\129.csv": -1459110991,
    "Australia\\English\\Blog\\132.csv": 765424877,
    "Australia\\English\\Printed Newspaper\\800.csv": -245808206,
    "Australia\\English\\Blog\\193.csv": -1787332016,
    "USA\\English\\Blog\\179.csv": 1725981777,
    "Germany\\German\\Blog\\153.csv": 69370814,
    "Switzerland\\German\\Blog\\169.csv": -1288838491,
    "Switzerland\\German\\Printed Newspaper\\810.csv": -1948226924,
    "Germany\\German\\Blog\\145.csv": 390655012,
    "Switzerland\\German\\Printed Newspaper\\807.csv": 180631175,
    "Germany\\German\\Blog\\152.csv": -1904236398,
    "Lebanon\\Arabic\\Blog\\163.csv": 1166701897,
    "Turkey\\English\\Blog\\174.csv": 1307169257,
    "Germany\\German\\Blog\\146.csv": -1919611217,
    "Lebanon\\Arabic\\News Website\\500.csv": 1766604543,
    "Turkey\\Turkish\\News Website\\125.csv": -1816644431,
    "Germany\\German\\Blog\\140.csv": -1656294548,
    "Germany\\German\\Blog\\150.csv": -1176450026,
    "USA\\English\\Blog\\175.csv": 1464979047,
    "Germany\\German\\News Website\\107.csv": 123264928,
    "Australia\\English\\Blog\\134.csv": 1147530751,
    "USA\\English\\News Website\\507.csv": -1962904030,
    "Germany\\German\\Blog\\141.csv": -976509503,
    "Switzerland\\German\\News Website\\116.csv": -271580746,
    "Australia\\English\\News Website\\105.csv": 492306788,
    "Australia\\English\\News Website\\100.csv": 1165988793,
    "Turkey\\Turkish\\Blog\\173.csv": -1634221824,
    "USA\\English\\Blog\\181.csv": -480551761,
    "Turkey\\Turkish\\Blog\\188.csv": -668728184,
    "Germany\\German\\News Website\\108.csv": 1016423006,
    "Lebanon\\English\\Blog\\158.csv": -1860745757,
    "Lebanon\\Arabic\\News Website\\112.csv": 1013852806,
    "Switzerland\\German\\News Website\\115.csv": 1483170787}


class DocumentSimilarity(object):
    def __init__(self, input_directory):
        self.input_directory = input_directory

    def compare(self, sample_chunk, csv_chunk):
        # configure CSV module
        csv.field_size_limit(131072 * 4)

        # get all files to process
        all_dirs = [(os.path.relpath(root, self.input_directory), files)
                    for root, dirs, files in os.walk(self.input_directory)]
        all_files = [os.path.join(d, f) for d, fs in all_dirs for f in fs]

        csv_files = [f for f in all_files if f.lower().endswith(".csv")]
        random.seed(2001)
        random.shuffle(csv_files)

        bar = progressbar.ProgressBar()

        corpus_lengths = dict()
        duplicate_count = Counter()
        results = []

        # split dataset into chunks of 37 sources and assign a worker to each of them
        for csv_file in bar(csv_files[37*csv_chunk:37*(csv_chunk+1)]):
            random.seed(random_ints[csv_file])
            item_ids = []
            with open(os.path.join(self.input_directory, csv_file), 'rb') as input_file:
                csv_reader = csv.DictReader(input_file)
                for item in csv_reader:
                    item_ids.append(item['story_id'])

            if not len(item_ids) <= 10000:
                continue

            random_id_sample = random.sample(item_ids, min(len(item_ids), sample_size*samples))
            random_id_sample = random_id_sample[sample_size*sample_chunk:sample_size*(sample_chunk+1)]

            if len(random_id_sample) == 0:
                continue

            corpus = []
            reported = []
            with open(os.path.join(self.input_directory, csv_file), 'rb') as input_file:
                csv_reader = csv.DictReader(input_file)
                for item in csv_reader:
                    if item['story_id'] not in random_id_sample:
                        continue

                    # preprocess text
                    content = item['content'].decode('utf-8')

                    if content.startswith("Content extracted from"):
                        try:
                            content = content.split(' ', 4)[4]
                        except IndexError:
                            content = ""

                    # lowercase
                    content = content.lower()

                    # replace -
                    content = REPLACE_DASH.sub(' ', content)

                    # strip quotes
                    content = STRIP_QUOTES.sub('', content)

                    # strip other punctuation
                    content = STRIP_PUNCTUATION.sub('', content)

                    # normalize unicodes, tokenize (normalizes spaces)
                    tokens = [unicodedata.normalize('NFKC', match.group()) for match in TOKENIZE.finditer(content)]

                    corpus.append(("\t".join([item['story_id']]), u(' ').join(tokens)))

                corpus_lengths[csv_file] = len(corpus)

            # tf-idf
            tfidf = TfidfVectorizer(analyzer='word', ngram_range=(1, 3), min_df=0)
            tfs = tfidf.fit_transform([content for filename, content in corpus])

            for doc_idx in range(0, len(corpus)):
                if doc_idx not in reported:
                    for sim_idx, _ in DocumentSimilarity.find_similar(tfs, doc_idx, 0.75):
                        reported.append(sim_idx)
                        duplicate_count[csv_file] += 1

        for csv_file, corpus_length in iteritems(corpus_lengths):
            results.append({"csv_file": csv_file, "duplicates": duplicate_count[csv_file], "length": corpus_length, "sample_chunk": sample_chunk, "csv_chunk": csv_chunk})
            print("%s\t%d\t%d\t%d\t%d" % (csv_file, duplicate_count[csv_file], corpus_length, sample_chunk, csv_chunk))

        return results

    # calculate similarities for each document with all other documents
    @staticmethod
    def find_similar(tfidf_matrix, index, threshold):
        cosine_similarities = linear_kernel(tfidf_matrix[index:index + 1], tfidf_matrix).flatten()
        cosine_similarity_tuples = [(i, cosine_similarities[i]) for i in range(len(cosine_similarities))
                                    if cosine_similarities[i] >= threshold and i > index]
        return cosine_similarity_tuples


def pool_process(args):
    input_directory, sample_chunk, csv_chunk = args
    print(args)

    # set up filter and reader
    document_similarity = DocumentSimilarity(
                        input_directory=input_directory,
    )

    # results = {"duplicates": 1, "length": 100, "sample_chunk": sample_chunk, "csv_chunk": csv_chunk}
    results = document_similarity.compare(sample_chunk=sample_chunk, csv_chunk=csv_chunk)

    # store
    with open("D:\\mc\\sim_test\\results.%d.%d.json" % (sample_chunk, csv_chunk), "w") as rf:
        json.dump(results, rf)

    return results


# if called from command line, parse arguments
if __name__ == '__main__':
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-directory", help="path to input csv files")

    args = parser.parse_args()

    p = Pool(3)

    # process five samples #0 to #4 across three chunks of sources #0, #1, and #2
    # split the work across three workers
    queue = [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2),
            (2, 0), (2, 1), (2, 2), (3, 0), (3, 1), (3, 2),
            (4, 0), (4, 1), (4, 2)]
    queue = [(args.input_directory, sample_chunk, csv_chunk) for (sample_chunk, csv_chunk) in queue]

    mapped_results = p.map(pool_process, queue)

    # flatten result lists and store results
    mapped_results = [item for sublist in mapped_results for item in sublist]
    with open("D:\\mc\\sim_test\\results.json", "w") as mrf:
        json.dump(mapped_results, mrf)
