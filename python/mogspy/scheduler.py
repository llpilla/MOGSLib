import mogslib              # for access to the C++ library
import inputs               # for simple data types
import scipy.stats as stats # for statistics

# Class to interface schedulers to simplify calls
class Scheduler:
    """Simplified interface between MOGSLib and Python. Includes analysis tools"""
    def __init__(self,tasks,pes,algorithm,load_aware = False):
        """Creates a scheduling scenario"""
        self.tasks = tasks
        self.pes = pes
        self.algorithm = algorithm
        # Defining if the scheduler is load aware or not (for the moment, here)
        if load_aware:
            self.schedule = self.load_aware
        else:
            self.schedule = self.load_oblivious
        self.mogs = mogslib.Scheduler()

    def load_aware(self):
        """Calls a load-aware scheduler on MOGSLib"""
        self.mapping = self.mogs.load_aware(
                self.algorithm, self.pes.num, self.tasks.num, self.tasks.loads)
        self.pes.update(self.mapping,self.tasks)

    def load_oblivious(self):
        """Calls a load-oblivious scheduler on MOGSLib"""
        self.mapping = self.mogs.load_oblivious(
                self.algorithm, self.pes.num, self.tasks.num)
        self.pes.update(self.mapping,self.tasks)







