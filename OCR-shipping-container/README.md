# OCR-stable
Automatic OCR System for Detection of Shipping Container

Make use of two-stream OCR system, and their aggregation to detect the BIC code of shipping container.

# Install
 - Git clone this repository, ```cd``` to this directory
 - Git clone [Caffe](https://github.com/BVLC/caffe) and compile Caffe
 - Install [Pytorch](http://pytorch.org/), used for [CRNN.pytorch](https://github.com/meijieru/crnn.pytorch)
 - Download pre-processed dataset from [here](https://jbox.sjtu.edu.cn/l/MoZdp6). Extract the zip file to ```./data/```.
 - Download pre-trained AlexNet model from [here](https://jbox.sjtu.edu.cn/l/qJly0T). Put it inside ```./model/```.
 

 # Run
Please refer to ```./demo.m```

 # Other information
If you would like to use the original dataset, download from [here](https://jbox.sjtu.edu.cn/l/vuBlUM) and put inside ```./data/```.

Refer to ```./demo.m``` for functions to pre-process.
 