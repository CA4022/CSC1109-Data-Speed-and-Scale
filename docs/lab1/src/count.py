from collections import Counter
from pathlib import Path
import sys
import re

WORD_REGEX = re.compile(r"[\w']+")


def main(filepath: Path) -> Counter:
    with filepath.open("rt") as file:
        return Counter(WORD_REGEX.findall(file.read()))


if __name__ == "__main__":
    input = sys.argv[1]
    filepath = Path(input)
    words = main(filepath)
    print(words.most_common(10))
