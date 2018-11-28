from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

##

tasks = Tasks.range(1,21,1)
pes = PEs(5)
scheduler = Scheduler(tasks,pes,"greedy",True)
scheduler.schedule()
scheduler.tasks.stats()
scheduler.tasks.report()
scheduler.pes.stats()
scheduler.pes.report()

scheduler2 = Scheduler(tasks,pes,"roundrobin")
scheduler2.schedule()
scheduler2.tasks.stats()
scheduler2.tasks.report()
scheduler2.pes.stats()
scheduler2.pes.report()

##

uniform_tasks = Tasks.uniform(10,100,50,1)
other_pes = PEs(20)
extra_scheduler = Scheduler(uniform_tasks,other_pes,"greedy",True)
extra_scheduler.schedule()
extra_scheduler.tasks.stats()
extra_scheduler.tasks.report()
extra_scheduler.pes.stats()
extra_scheduler.pes.report()


