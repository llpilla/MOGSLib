from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

tasks = Tasks.range(1,21,1)
pes = PEs(5)
sched = Scheduler(tasks,pes,"greedy",True)
sched.schedule()
sched.stats()
sched.report()
sched.to_csv()
