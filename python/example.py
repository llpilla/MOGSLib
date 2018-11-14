import mogslib
sched = mogslib.Scheduler()
print sched.load_oblivious("roundrobin",5,15)

loads = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
print sched.load_aware("greedy",5,15,loads)
