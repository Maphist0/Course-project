# A human flow detection system using lidar
 - Version: 0.1
 - Library used in development:
   - pcl
   - svm (```svm.h``` and ```svm.cpp``` are downloded from [libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/))
 - Compile with cmake

# Prior knowledge
1. The lidar is installed on the floor, with the scan surface crossing the target tunnel.

1. A flat mirror is used to reflect half of the lidar signal back to ground (otherwise this portion of signal will points to the ceil, wasted).

# Steps
1. Data pre-processing, including:
    - Separate points for ground (pre-calculated by existing data)
    - Stack points in current time frame with previous data
    - Combine reflected data with normal data

1. Human flow detection using clustering algorithm

1. Better detection using features + SVM

# TODO
1. Speedup the code
1. Develop a GUI
1. Use neural network for better accuracy
