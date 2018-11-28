from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

tasks = Tasks(30)
pes = PEs(5)
scheduler = Scheduler(tasks,pes,"roundrobin")
scheduler.schedule()
tasks.stats()
tasks.report(scheduler.mapping)
pes.stats()
pes.report()
