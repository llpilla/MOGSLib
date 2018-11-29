# Example on the way to save a mapping to a CSV file
from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

tasks = Tasks.range(1,21,1)
pes = PEs(5)
sched = Scheduler(tasks,pes,"greedy",True)
sched.schedule()
sched.stats()
#sched.report() # remove comment if you want to see information in the standard output
sched.to_csv()
