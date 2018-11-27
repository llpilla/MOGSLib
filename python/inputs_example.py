import mogspy.mogslib as mogslib
from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs

tasks = Tasks.range(1,20,1)
pes = PEs(5)

sched = mogslib.Scheduler()
mapping = sched.load_aware("greedy",pes.num,tasks.num,tasks.loads)
pes.update(mapping,tasks)

print tasks.loads
print mapping
print pes.tasks
print pes.loads
