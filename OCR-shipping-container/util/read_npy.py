import numpy as np
mean = np.load('./alex/mean.npy')
print mean.shape
for channel in range(3):
	with open('./alex/mean_%d.csv'%channel, 'w') as ofile:
		for i in range(mean.shape[1]):
			for j in range(mean.shape[2]):
				ofile.write(str(mean[channel][i][j])+',')
			ofile.write('\n')
