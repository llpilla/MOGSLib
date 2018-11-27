from __future__ import division # for forcing float division
import mogslib              # for access to the C++ library
import inputs               # for simple data types
import scipy.stats as stats # for statistics
import numpy as np          # for statistics

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

    def report_tasks(self):
        """ Characterization of the tasks. Data printed:
            * Load of each task
            * Mapping of tasks to PEs
            * Arithmetic mean of loads
            * Median load
            * Max load
            * Min load
            * Ratio between max and min loads (max/min)
            * Standard deviation of loads
        """
        tasks = self.tasks
        mean = np.mean(tasks.loads)
        median = np.median(tasks.loads)
        max_load = max(tasks.loads)
        min_load = min(tasks.loads)
        stdev = np.std(tasks.loads)

        print "--- Tasks' report ---"
        print "Load - per task: "
        print tasks.loads
        print "Mapping of tasks to PEs:"
        print self.mapping
        print "Load - arithmetic mean:", mean
        print "Load - median:", median
        print "Load - max:", max_load
        print "Load - min:", min_load
        print "Load - ratio between max and min:", max_load/min_load
        print "Load - standard deviation:", stdev
        print "--- end of tasks' report ---"

    def report_pes(self):
        """ Characterion of the PEs. Data printed:
            * Load of each PE
            * Tasks mapped to each PE
            * Number of tasks mapped to each PE
            * Arithmetic mean of loads
            * Median load
            * Max load
            * Min load
            * Ratio between max and min loads (max/min)
            * Standard deviation of loads
            * Skewness of loads
            * Kurtosis of loads
        """
        pes = self.pes
        tasks_per_pe = [0]*pes.num
        for i in range(pes.num):
            tasks_per_pe[i] = len(pes.tasks[i])
        mean = np.mean(pes.loads)
        median = np.median(pes.loads)
        max_load = max(pes.loads)
        min_load = min(pes.loads)
        stdev = np.std(pes.loads)
        skew = stats.skew(pes.loads)
        kurt = stats.kurtosis(pes.loads)

        print "--- PEs' report ---"
        print "Load - per PE:"
        print pes.loads
        print "Tasks mapped to each PE:"
        print pes.tasks
        print "Number of tasks per PE:"
        print tasks_per_pe
        print "Load - arithmetic mean:", mean
        print "Load - median:", median
        print "Load - max:", max_load
        print "Load - min:", min_load
        print "Load - ratio between max and min:", max_load/min_load
        print "Load - standard deviation:", stdev
        print "Load - skewness:", skew
        print "Load - kurtosis:", kurt
        print "--- end of PEs' report ---"











