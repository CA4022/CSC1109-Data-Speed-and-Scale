from mrjob.job import MRJob
import re
from typing import Generator

WORD_REGEX = re.compile(r"[\w']+")


class MRWordFreqCount(MRJob):
    def mapper(self, _, line: str) -> Generator[tuple[str, int], None, None]:
        for word in WORD_REGEX.findall(line):
            yield (word.lower(), 1)

    def combiner(
        self, word: str, counts: list[int]
    ) -> Generator[tuple[str, int], None, None]:
        yield (word, sum(counts))

    def reducer(
        self, word: str, counts: list[int]
    ) -> Generator[tuple[str, int], None, None]:
        yield (word, sum(counts))


if __name__ == "__main__":
    MRWordFreqCount.run()
