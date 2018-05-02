import os
import matplotlib.pyplot as plt
import matplotlib
import math
import numpy as np
DEBUG = 0

plt.rcParams["figure.figsize"] = [6,6]

with open('FB2010-1Hr-150-0.txt', 'r') as ifile:
    lines = ifile.readlines()

# <Number of ports in the fabric> <Number of coflows below (one per line)>
# <Coflow ID> <Arrival time (ms)> <Number of mappers> <Location of map-m> <Number of reducers> <Location of reduce-r:Shuffle megabytes of reduce-r>
sizes = []
is_first_line = True
for line in lines:
    if is_first_line:
        num_coflows = int(line.split()[1])
        is_first_line = False
    else:
        split = line.split()
        num_mappers = int(split[2])
        if DEBUG: print(num_mappers)
        num_reducers = int(split[2+num_mappers+1])
        if DEBUG: print(num_reducers)
        reducers = split[2+num_mappers+2:]
        if DEBUG: print(len(reducers))
        coflow_size = 0
        for reducer in reducers:
            size = float(reducer.split(':')[1])
            coflow_size += size
            if DEBUG: print('coflow size: ', size)
        sizes.append(coflow_size)

#print(sizes)
#sizes = sorted(sizes)
#frac_coflow_x = [sizes[0]]
#frac_coflow_y = [1]
#for idx in range(len(sizes)):
#    size = sizes[idx]
#    if size in frac_coflow_x:
#        frac_coflow_y[-1] += 1
#    else:
#        frac_coflow_x.append(size)
#        frac_coflow_y.append(frac_coflow_y[-1])

#for idx in range(len(frac_coflow_x)):
#    frac_coflow_x[idx] = math.log(frac_coflow_x[idx])
#plt.plot(frac_coflow_x, frac_coflow_y)
#plt.show()

flows = sizes
# Normalize flow sizes
print('Total number of flows = %d' % len(flows))
flows = np.sort(flows)
normalize_flows = (flows - np.min(flows).astype(np.float)) / (np.max(flows) - np.min(flows))
# flows = flows[flows < 0.8]
# flows = (flows - np.min(flows)) / (np.max(flows) - np.min(flows))

x = normalize_flows
y = np.arange(0, len(flows), dtype=np.float32)
y = y / float(len(flows))

#plt.xlim((0, 1))
#plt.ylim((0, 1))
plt.plot(x, y, '-')
plt.show()


x = np.log10(flows)
total = np.sum(x)
y = [x[0]]
for idx, val in enumerate(x[1:]):
	y.append(y[idx] + val)
y = np.asarray(y) / total
plt.close('all')
plt.plot(x, y, '-')
plt.ylabel('Ratio of total coflow size')
plt.xticks(np.arange(8), [r'$10^%d$'%i for i in range(8)])
plt.show()
