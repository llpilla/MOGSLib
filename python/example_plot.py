# Example of plotting experiments
from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

tasks = Tasks.normal(40,5,50,16) # generate tasks from a normal distribution
pes = PEs(10)

greedy = Scheduler(tasks,pes,"greedy",True)
greedy.schedule()
greedy.stats()
greedy.plot_all()

roundrobin = Scheduler(tasks,pes,"roundrobin",False)
roundrobin.schedule()
roundrobin.stats()
roundrobin.plot_all()

