from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

##

tasks = Tasks.range(1,21,1)
pes = PEs(5)
scheduler = Scheduler(tasks,pes,"greedy",True)
scheduler.schedule()
scheduler.report_tasks()
scheduler.report_pes()

scheduler2 = Scheduler(tasks,pes,"roundrobin")
scheduler2.schedule()
scheduler2.report_tasks()
scheduler2.report_pes()

##

uniform_tasks = Tasks.uniform(10,100,50,1)
other_pes = PEs(20)
extra_scheduler = Scheduler(uniform_tasks,other_pes,"greedy",True)
extra_scheduler.schedule()
extra_scheduler.report_tasks()
extra_scheduler.report_pes()

