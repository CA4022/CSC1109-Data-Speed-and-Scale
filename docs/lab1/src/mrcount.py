import sys
import shlex

# This patch fixes Python 3.13 compatibility for mrjob 0.7.4
# (pipes was removed in Python 3.13, PEP 594)
if sys.version_info >= (3, 13) and "pipes" not in sys.modules:
    sys.modules["pipes"] = shlex

from mrjob.job import MRJob
import re
from collections.abc import Iterator


WORD_REGEX = re.compile(r"[\w']+")


class MRWordFreqCount(MRJob):
    def mapper(self, _, line: str) -> Iterator[tuple[str, int]]:
        for word in WORD_REGEX.findall(line):
            yield (word.lower(), 1)

    def combiner(
        self, word: str, counts: list[int]
    ) -> Iterator[tuple[str, int]]:
        yield (word, sum(counts))

    def reducer(
        self, word: str, counts: list[int]
    ) -> Iterator[tuple[str, int]]:
        yield (word, sum(counts))


if __name__ == "__main__":
    MRWordFreqCount.run()
