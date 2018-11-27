import numpy.random as nr
import numpy

# Class to describe tasks
class Tasks:
    """List of tasks to provide to a scheduler"""
    def __init__(self,num,loads = None):
        """Creates a list of tasks with or without their loads"""
        self.num = num
        if type(loads) is numpy.ndarray:
            self.loads = numpy.ndarray.tolist(loads)
        else:
            self.loads = loads

    @staticmethod
    def from_loads(loads):
        """Creates a list of tasks from their list of loads"""
        return Tasks(len(loads), loads)

    @staticmethod
    def uniform(low = 1.0, high = 10.0, size = 10.0, seed = None):
        """Creates a list of tasks with a uniform distribution of loads"""
        nr.seed(seed)
        return Tasks.from_loads(nr.uniform(low,high,size))

    @staticmethod
    def lognormal(mean = 0.0, sigma = 1.0, size = 10.0, scale = 1.0, seed = None):
        """Creates a list of tasks with a lognormal distribution of loads"""
        nr.seed(seed)
        return Tasks.from_loads(scale*nr.lognormal(mean,sigma,size))

    @staticmethod
    def normal(loc = 10.0, scale = 1.0, size = 10.0, seed = None):
        """Creates a list of tasks with a normal distribution of loads"""
        nr.seed(seed)
        return Tasks.from_loads(nr.normal(loc,scale,size))

    @staticmethod
    def range(minvalue = 1, maxvalue = 10, step = 1):
        """Creates a list of tasks with a range of loads"""
        return Tasks.from_loads(range(minvalue,maxvalue,step))

# Class to describe PEs
class PEs:
    """Information about the PEs to provide to a scheduler"""
    def __init__(self, num):
        self.num = num

    def update(self, mapping, tasks):
        """Updates information about PEs based on information from the tasks"""
        self.loads = [0]*self.num
        self.tasks = []
        for pe in range(self.num):
            # for each PE, sets all tasks that are mapped to it
            self.tasks.append([i for i, x in enumerate(mapping) if x == pe])
            for t in self.tasks[pe]:
                # for each task in said PE, add its load to the load of the PE
                self.loads[pe] = self.loads[pe] + tasks.loads[t]






