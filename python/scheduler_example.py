from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

tasks = Tasks.range(1,21,1)
pes = PEs(5)
scheduler = Scheduler(tasks,pes,"greedy",True)
scheduler.schedule()
print pes.tasks
print pes.loads
scheduler2 = Scheduler(tasks,pes,"roundrobin")
scheduler2.schedule()
print pes.tasks
print pes.loads

