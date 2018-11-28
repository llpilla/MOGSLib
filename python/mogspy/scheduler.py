import mogslib              # for access to the C++ library
import inputs               # for simple data types
import datetime             # for date (for files)

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

        date = "date:"+datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
        name = "sched:"+self.algorithm+"+tasks:"+str(tasks.num)+"+pes:"+str(pes.num)
        self.name = name+"+"+date+"/"
        tasks.path = self.name
        pes.path = self.name

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











