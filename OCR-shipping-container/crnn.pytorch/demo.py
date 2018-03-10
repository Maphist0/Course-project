import torch
from torch.autograd import Variable
import utils
import dataset
from PIL import Image

import sys, os
import models.crnn as crnn

root = None
assert root, 'Undefined root path, please edit "demo.py" before invoking.'
model_path = os.path.join(root, 'crnn.pytorch/data/crnn.pth')
alphabet = '0123456789abcdefghijklmnopqrstuvwxyz'

if 1:
	img_paths = sys.argv[1].split(',')

model = crnn.CRNN(32, 1, 37, 256)
if torch.cuda.is_available():
    model = model.cuda()
print('loading pretrained model from %s' % model_path)
model.load_state_dict(torch.load(model_path))

converter = utils.strLabelConverter(alphabet)

transformer = dataset.resizeNormalize((100, 32))

with open(os.path.join(root, 'data/rcnn_result.csv'), 'w') as ifile:
	for i in range(len(img_paths)):
		img_path = img_paths[i]
		image = Image.open(img_path).convert('L')
		image = transformer(image)
		if torch.cuda.is_available():
		    image = image.cuda()
		image = image.view(1, *image.size())
		image = Variable(image)

		model.eval()
		preds = model(image)

		_, preds = preds.max(2)
		preds = preds.transpose(1, 0).contiguous().view(-1)

		preds_size = Variable(torch.IntTensor([preds.size(0)]))
		raw_pred = converter.decode(preds.data, preds_size.data, raw=True)
		sim_pred = converter.decode(preds.data, preds_size.data, raw=False)
		print(img_path)
		print('%-20s => %-20s' % (raw_pred, sim_pred))
		ifile.write(img_path.split('/')[-1] + ',' + img_path.split('/')[-2] + ',' + sim_pred + '\n')
