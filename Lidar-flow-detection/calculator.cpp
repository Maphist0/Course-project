#include "pcd_project.h"

void Extracter::__dividePoints(CloudPtr cloud, Point_v_v &v) {

    // The ERROR: "Segmentation fault: 11" is caused here.
    // Because of "index" out of bound(bigger than 7, equals 8).
    // Reason: The passthrough will contain all boundry-points.
    // Like (100 - -200) / 37.5 = 8, exactly out of bound.
    for (size_t i = 0; i < cloud->points.size(); i++) {
        int index = (cloud->points[i].x - lp.x) / CUBE_WIDTH;
        if (index == DIVIDE_X) index--;
        // std::cout << rangeOne.points[i].x << ' ' << lp.x << ' ' << index << std::endl;
        v[index].push_back(cloud->points[i]);
    }
}

void Extracter::__printVectorVectorPoint(Point_v_v v) {

    for (size_t i = 0; i < v.size(); i++) {
        if (v[i].size() <= 0) std::cout << "[N] ";
        else {
            std::cout << "[";
            for (size_t j = 0; j < v[i].size(); j++)
                std::cout << "(" << v[i][j].x << ", " << v[i][j].y
                    << ", " << v[i][j].z << ") ";
            std::cout << "]  ";
        }
    }
    std::cout << std::endl;
}

void Extracter::__normalize(std::vector<double> &v) {

    // Calculate vector length.
    double length(0);
    for (size_t i = 0; i < v.size(); i++)
        length += (v[i] * v[i]);
    length = sqrt(length);

    for (size_t i = 0; i < v.size(); i++) {
        v[i] = v[i] / length;
    }
}

std::vector<double> Extracter::__calcFeatureVector(
    Point_v_v rangeOne, Point_v_v rangeTwo, Point_v_v rangeThree) {

    std::vector<double> tmp, result;
    double average(0);
    int cnt_has_value(0);
    for (int i = 0; i < DIVIDE_X; i++) {
        // Find highest one. (0 for no point. This could be problematic!)
        // Then save the average value.
        cnt_has_value = 0;
        cnt_has_value += (__maximumY(rangeOne[i]) ? 1 : 0);
        cnt_has_value += (__maximumY(rangeTwo[i]) ? 1 : 0);
        cnt_has_value += (__maximumY(rangeThree[i]) ? 1 : 0);
        if (cnt_has_value == 0) tmp.push_back(0);
        else {
            average = __maximumY(rangeOne[i]) + __maximumY(rangeTwo[i]) + __maximumY(rangeThree[i]) + 0.;
            average /= cnt_has_value;
            tmp.push_back(average);
        }
    }

    // Calculate average for x axis.
    double ratio;
    for (int i = 0; i < FEATURE_DIM; i++) {
        ratio = ((tmp[i] != 0) && (tmp[7-i] != 0)) ? 0.5 : 1;
        result.push_back((tmp[i] + tmp[7-i]) * ratio);
    }

    // Normalization.
    // __normalize(result);

    return result;
}

int Extracter::__maximumY(Point_v v) {

    int max(0);
    for (int i = 0; i < v.size(); i++)
        if (v[i].y > max) max = v[i].y;
    return max;
}

template <class elemtype>
void __printVector(std::vector<elemtype> v) {

    if (v.size() <= 0) std::cout << "Empty" << std::endl;
    else {
        std::cout << "(" << v[0];
        for (size_t i = 1; i < v.size(); i++)
            std::cout << ", " << v[i];
        std::cout << ")" << std::endl;
    }
}

std::vector<double> Extracter::calcVector(std::vector<PointXYZ> v) {

    lp = v[0];
    up = v[1];

    // |-----INTERVAL_X------|
    // [] [] [] [] [] [] [] []  --> rowOne & rangeOne
    // [] [] [] [] [] [] [] []  --> rowTwo & rangeTwo
    // [] [] [] [] [] [] [] []  --> rowThree & rangeThree
    Point_v_v rowOne, rowTwo, rowThree;

    CloudPtr rangeOne(new Cloud());
    CloudPtr rangeTwo(new Cloud());
    CloudPtr rangeThree(new Cloud());
    Passthrough pass;

    // std::cout << "Cloud size: " << cloud->points.size() << std::endl;

    pass.setInputCloud(cloud);
    pass.setFilterFieldName("z");
    pass.setFilterLimits(lp.z, lp.z + DELTA_Z); // Extract first layer.
    pass.filter(*rangeOne);
    pass.setFilterLimits(lp.z + DELTA_Z, lp.z + 2 * DELTA_Z); // Extract second layer.
    pass.filter(*rangeTwo);
    pass.setFilterLimits(lp.z + 2 * DELTA_Z, lp.z + 3 * DELTA_Z); // Extract third layer.
    pass.filter(*rangeThree);

    // std::cout << "Cloud rangeOne size: " << rangeOne->points.size() << std::endl;
    // std::cout << "Cloud rangeTwo size: " << rangeTwo->points.size() << std::endl;
    // std::cout << "Cloud rangeThree size: " << rangeThree->points.size() << std::endl;

    // Initialize
    Point_v tmp;
    for (int i = 0; i < DIVIDE_X; i++) {
        rowOne.push_back(tmp);
        rowTwo.push_back(tmp);
        rowThree.push_back(tmp);
    }

    __dividePoints(rangeOne, rowOne);
    __dividePoints(rangeTwo, rowTwo);
    __dividePoints(rangeThree, rowThree);

    // __printVectorVectorPoint(rowOne);
    // __printVectorVectorPoint(rowTwo);
    // __printVectorVectorPoint(rowThree);

    std::vector<double> feature;
    feature = __calcFeatureVector(rowOne, rowTwo, rowThree);
    // __printVector<double>(feature);

    return feature;
}


void cluster(pcl::PointCloud<PointXYZ>::Ptr cloud, ViewerPtr viewer, bool changeColor = false) {
    // Creating the KdTree object for the search method of the extraction
    pcl::search::KdTree<PointXYZ>::Ptr tree (new pcl::search::KdTree<PointXYZ>);
    tree->setInputCloud (cloud);

    std::vector<pcl::PointIndices> cluster_indices;
    pcl::EuclideanClusterExtraction<pcl::PointXYZ> ec;
    ec.setClusterTolerance (230);
    ec.setMinClusterSize (2);
    ec.setMaxClusterSize (200);
    ec.setSearchMethod (tree);
    ec.setInputCloud (cloud);
    ec.extract (cluster_indices);

    std::cout << "Cluster: " << cluster_indices.size() << std::endl;
    std::ofstream ofs ("cluster.txt", std::ofstream::app);
    ofs << cluster_indices.size() << '\n';
    ofs.close();

    for (std::vector<pcl::PointIndices>::const_iterator it = cluster_indices.begin ();
        it != cluster_indices.end (); ++it) {

        double x(0), z(0);
        PointXYZ lp, up;
        for (std::vector<int>::const_iterator pit = it->indices.begin ();
            pit != it->indices.end (); ++pit) {

            x += cloud->points[*pit].x;
            z += cloud->points[*pit].z;
        }
        if (it->indices.size() != 0) {
            x /= it->indices.size();
            z /= it->indices.size();
            lp.x = x - 2 * INTERVAL_X;
            lp.z = z - 2 * INTERVAL_Z;
            up.x = x + 2 * INTERVAL_X;
            up.z = z + 2 * INTERVAL_Z;

            lp.y = 0;
            up.y = SIZE_Y;
            if (changeColor) drawCubeBlue(viewer, lp, up);
            else drawCubeGreen(viewer, lp, up);
        }
    }
}


// Calculate the number of people.
// First project to 'y = 0'.
// Then apply cluster.
void calcByCluster(CloudPtr cloud, ViewerPtr viewer) {

    CloudPtr cloud_projected (new Cloud());

    // Create a set of planar coefficients with Y=0
    pcl::ModelCoefficients::Ptr coefficients (new pcl::ModelCoefficients ());
    coefficients->values.resize (4);
    coefficients->values[0] = 0;
    coefficients->values[1] = 1;
    coefficients->values[2] = 0;
    coefficients->values[3] = 0;

    // Create the filtering object
    pcl::ProjectInliers<Point> proj;
    proj.setModelType (pcl::SACMODEL_PLANE);
    proj.setInputCloud (cloud);
    proj.setModelCoefficients (coefficients);
    proj.filter (*cloud_projected);

    // Creating the KdTree object for the search method of the extraction
    pcl::search::KdTree<Point>::Ptr tree (new pcl::search::KdTree<Point>);
    tree->setInputCloud (cloud_projected);

    std::vector<pcl::PointIndices> cluster_indices;
    pcl::EuclideanClusterExtraction<Point> ec;
    ec.setClusterTolerance (100);
    ec.setMinClusterSize (10);
    ec.setMaxClusterSize (200000);
    ec.setSearchMethod (tree);
    ec.setInputCloud (cloud_projected);
    ec.extract (cluster_indices);

    std::cout << "Cluster: " << cluster_indices.size() << std::endl;
    std::ofstream ofs ("calculate-by-cluster.txt", std::ofstream::app);
    ofs << cluster_indices.size() << '\n';
    ofs.close();

    for (std::vector<pcl::PointIndices>::const_iterator it = cluster_indices.begin ();
        it != cluster_indices.end (); ++it) {

        double x(0), z(0);
        PointXYZ lp, up;
        for (std::vector<int>::const_iterator pit = it->indices.begin ();
            pit != it->indices.end (); ++pit) {

            x += cloud_projected->points[*pit].x;
            z += cloud_projected->points[*pit].z;
        }
        if (it->indices.size() != 0) {
            x /= it->indices.size();
            z /= it->indices.size();
            lp.x = x - 2 * INTERVAL_X;
            lp.z = z - 2 * INTERVAL_Z;
            up.x = x + 2 * INTERVAL_X;
            up.z = z + 2 * INTERVAL_Z;

            lp.y = 0;
            up.y = 0;
            drawCubeRed(viewer, lp, up);
        }
    }
    viewer->addPointCloud(cloud_projected, "cloud_projected");
}



