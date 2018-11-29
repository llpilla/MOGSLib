# Example of the report functionality
from mogspy.inputs import Tasks as Tasks
from mogspy.inputs import PEs as PEs
from mogspy.scheduler import Scheduler as Scheduler

tasks = Tasks(30)
pes = PEs(5)
scheduler = Scheduler(tasks,pes,"roundrobin")
scheduler.schedule()
print "# Calling directly on the Tasks object"
tasks.stats()
tasks.report(scheduler.mapping)
print "# Calling directly on the PEs object"
pes.stats()
pes.report()
print "# Calling from the Scheduler object"
# no need to call scheduler.stats() because we already did it for Tasks and PEs
scheduler.report()
