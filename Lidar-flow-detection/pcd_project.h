#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <tgmath.h>
#include <pcl/console/parse.h>
#include <pcl/filters/passthrough.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/filters/extract_indices.h>
#include <pcl/filters/project_inliers.h>
#include <pcl/kdtree/kdtree.h>
#include <pcl/io/pcd_io.h>
#include <pcl/io/vtk_lib_io.h>
#include <pcl/point_types.h>
#include <pcl/ModelCoefficients.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/sample_consensus/method_types.h>
#include <pcl/sample_consensus/model_types.h>
#include <pcl/segmentation/sac_segmentation.h>
#include <pcl/segmentation/extract_clusters.h>
#include "svm.h"

typedef pcl::PointXYZRGB Point;
typedef pcl::PointXYZ PointXYZ;
typedef pcl::PointCloud<Point>::Ptr CloudPtr;
typedef pcl::PointCloud<Point> Cloud;
typedef pcl::visualization::PCLVisualizer::Ptr ViewerPtr;
typedef pcl::visualization::PCLVisualizer Viewer;
typedef pcl::PassThrough<Point> Passthrough;
typedef pcl::visualization::KeyboardEvent KeyboardEvent;

typedef std::vector<Point> Point_v;
typedef std::vector<Point_v> Point_v_v;

// For viewer.cpp

void showCloud (char*);
std::string drawCube (ViewerPtr, PointXYZ, PointXYZ);
std::string drawCubeRed (ViewerPtr, PointXYZ, PointXYZ);
std::string drawCubeGreen (ViewerPtr, PointXYZ, PointXYZ);
std::string drawCubeBlue (ViewerPtr, PointXYZ, PointXYZ);
void keyboardEventOccurred (const KeyboardEvent&, void*);
void cluster(pcl::PointCloud<PointXYZ>::Ptr, ViewerPtr, bool);

void calcByCluster(CloudPtr, ViewerPtr);

const static int SIZE_X (800);
const static int SIZE_Y (2000);
const static int SIZE_Z (4000);
const static int DELTA_Z(45);   // Z-distances between layers. Read from source pcd data.
const static int DELTA_X(100);  // The moving box will move one delta_x each time
const static int INTERVAL_X(2 * DELTA_X);  // Box has x direction size of 2 * delta_x
const static int INTERVAL_Z(3 * DELTA_Z);  // The moving box will read three layers each time.
const static int DIVIDE_X(8);    // Devide x direction by 8.
const static int FEATURE_DIM(DIVIDE_X / 2);    // Dimention of feature vector.
const static double CUBE_WIDTH(((double) INTERVAL_X) / DIVIDE_X);
const static Point ORIGIN (0, 0, 0);

enum DIRECTION {UP, DOWN, LEFT, RIGHT};

class MovingBox {
private:
    PointXYZ lp;
    PointXYZ up;
    ViewerPtr viewer;
    CloudPtr cloud;
    std::string name;
    std::string PCDFileName;
    svm_model * model;

    // This is not a good idea.
    // However, keyboard callback can only hold one class,
    //   so I have to use "MovingBox" to save feature vectors.
    std::vector<double> feature;

    void draw() { name = drawCube(viewer, lp, up); };
    void __createNode (svm_node *);
    int __minPos( std::vector<double> );

public:
    MovingBox(ViewerPtr, CloudPtr);
    ~MovingBox() {};

    void update(DIRECTION);
    void stamp() { drawCube(viewer, lp, up); };
    void stampRed() { drawCubeRed(viewer, lp, up); };
    CloudPtr extract();
    std::vector<PointXYZ> getPoints();
    void setFeatureVector(std::vector<double> v) { feature = v; };
    void saveFeature(int);
    void saveBoxPos();
    void setPCDFileName(std::string name) { PCDFileName = name; };
    void loadSVMModel(const char*);
    double checkFeature();
    double checkFeatureSVM();
    std::vector<double> getFeature() { return feature; };
    PointXYZ toPointXYZ();
    bool hasGoneToEnd() { return lp.z >= SIZE_Z; };
};


// For calculator.cpp

template <class elemtype>
void __printVector(std::vector<elemtype>);

class Extracter{
private:
    CloudPtr cloud;
    PointXYZ lp, up;

    void __dividePoints(CloudPtr, Point_v_v&);
    void __printVectorVectorPoint(Point_v_v);
    int __maximumY(Point_v v);
    void __normalize(std::vector<double>&);
    std::vector<double> __calcFeatureVector(Point_v_v, Point_v_v, Point_v_v);
public:
    // Should receive cloud from MovingBox::extract.
    Extracter(CloudPtr arg):cloud(arg) {};
    ~Extracter() {};

    // Should receive points from MovingBox::getPoints.
    std::vector<double> calcVector(std::vector<PointXYZ>);
};