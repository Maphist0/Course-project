# coding=utf-8
import os
import csv
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

plt.rcParams["figure.figsize"] = [6,6]
matplotlib.rcParams[u'font.sans-serif'] = ['simhei']

flows = []

if os.path.exists('flows.npy'):
	flows = np.load('flows.npy')
else:
	# Read size from local file
	filename = 'attempt.csv'
	with open(filename) as ifile:
		reader = csv.DictReader(ifile)
		for row in reader:
			# Pick up the size
			if (row['shuffleTime']):
				size = int(row['sortTime']) - int(row['shuffleTime'])
				flows.append(size)
	flows = np.asarray(flows)

np.save('flows.npy', flows)

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
#plt.ylabel(u'流族数目占比（CDF）')
#plt.xlabel(u'流族大小（Normalized）')
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
