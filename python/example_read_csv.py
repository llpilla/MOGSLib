# Example on how to read a CSV report
from mogspy.scheduler import Scheduler as Scheduler

sched = Scheduler.from_csv("csv_example/description.txt")
sched.stats()
sched.report()
