import mogslib              # for access to the C++ library
import inputs               # for simple data types
import datetime             # for date (for files)
import csv                  # for handling csv files
import os                   # for creating directories

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
        self.path = name+"+"+date+"/"

    @staticmethod
    def from_csv(description):
        """Imports scheduling information to CSV format from a description file"""
        try: # read information from the description file
            with open(description,'r') as f:
                lines = f.read().splitlines()
                info = dict(i.split('=') for i in lines)
        except IOError:
            print "Error: could not read file "+description
        try: # create objects based on their csv files
            tasks = inputs.Tasks.from_csv(info['tasks_file'])
            pes = inputs.PEs.from_csv(info['pes_file'])
            scheduler = Scheduler(tasks,pes,info['algorithm'],bool(info['load_aware']))
        except NameError:
            pass
        try: # read mapping information from csv file
            with open(info['mapping_file'],'r') as f:
                reader = csv.reader(f, quoting=csv.QUOTE_NONNUMERIC)
                mapping = list(reader)[0]
            scheduler.mapping = [int(x) for x in mapping]
            pes.update(mapping,tasks)
            return scheduler
        except IOError:
            print "Error: could not read file "+info['mapping_file']

    def to_csv(self, description = "description.txt", filename = "mapping.csv"):
        """Exports scheduling information to CSV format"""
        try:
            os.mkdir(self.path)
        except OSError:
            print "Error: could not create directory "+self.path
        tasks_file = self.path+"tasks.csv"
        pes_file = self.path+"pes.csv"
        mapping_file = self.path+filename
        description_file = self.path+description
        # export csvs
        self.tasks.to_csv(tasks_file)   # export tasks
        self.pes.to_csv(pes_file)       # export pes
        try:                            # export mapping
            with open(mapping_file, 'wb') as f:
                writer = csv.writer(f)
                try:
                    writer.writerow(self.mapping)
                except AttributeError:
                    print "Error: no mapping to export"
        except IOError:
            print "Error: could not write file "+mapping_file
        # export general iinformation of the test
        try:
            with open(description_file,'wb') as f:
                f.write("algorithm="+self.algorithm+"\n")
                if self.schedule == self.load_aware:
                    load_aware="True"
                else:
                    load_aware="False"
                f.write("load_aware="+load_aware+"\n")
                f.write("tasks_file="+tasks_file+"\n")
                f.write("pes_file="+pes_file+"\n")
                f.write("mapping_file="+mapping_file+"\n")
        except IOError:
            print "Error: could not write file "+description_file

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

    def stats(self):
        """Computes statistics related to the mapping"""
        self.tasks.stats()
        self.pes.stats()

    def report(self):
        """Reports statistics in standard output"""
        self.tasks.report(self.mapping)
        self.pes.report()











