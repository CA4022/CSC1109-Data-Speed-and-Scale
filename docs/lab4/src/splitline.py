from pystorm import Bolt, Tuple


class SplitLineBolt(Bolt):
    def process(self, tup: Tuple):
        [self.emit([word]) for word in tup.values[0].split()]


SplitLineBolt().run()
