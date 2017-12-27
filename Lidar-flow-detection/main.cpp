#include "pcd_project.h"

int main (int argc, char **argv) {

    // Show point cloud, use '-s pcd_filename.[pcd]'
    if (pcl::console::find_switch (argc, argv, "-s")) {
        showCloud (argv[2]);
        return 0;
    }
//
//    // Auto check point cloud with SVM model.
//    if (pcl::console::find_switch (argc, argv, "-auto")) {
//        is_auto = 1;
//    }
//
//    if (pcl::console::find_switch (argc, argv, "-gen")) {
//
//    }
/*
    std::string filename;
    cout << "File name ---> ";
    cin >> filename;

    cout << "Loading file: " << filename << endl;

//    CloudPtr cloud (new Cloud());
//    CloudPtr tmp (new Cloud());

    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZ>);
    pcl::PointCloud<pcl::PointXYZ>::Ptr tmp(new pcl::PointCloud<pcl::PointXYZ>);
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_filtered(new pcl::PointCloud<pcl::PointXYZ>);
    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_one_frame(new pcl::PointCloud<pcl::PointXYZ>);

    if (pcl::io::loadPCDFile<pcl::PointXYZ> (filename, *cloud) == -1) { //* load the file
        PCL_ERROR ("Couldn't read file test_pcd.pcd \n");
        return 0;
    }


//    for (int i = 0; i < cloud->points.size(); i++) {
//        if (201.3 < cloud->points[i].z && cloud->points[i].z < 201.7) {
//            pcl::PointXYZ p = cloud->points[i];
//            tmp->points.push_back(p);
//        }
//        if (204.3 < cloud->points[i].z && cloud->points[i].z < 204.7) {
//            pcl::PointXYZ p = cloud->points[i];
//            p.z += 100;
//            tmp->points.push_back(p);
//        }
//        if (207.3 < cloud->points[i].z && cloud->points[i].z < 207.7) {
//            pcl::PointXYZ p = cloud->points[i];
//            p.z += 200;
//            tmp->points.push_back(p);
//        }
//    }

    pcl::PassThrough<PointXYZ> pass;
    // Extract for z direction;
    pass.setInputCloud(cloud);
    pass.setFilterFieldName("z");
//    pass.setFilterLimits(200, 250);
        pass.setFilterLimits(1880, 2120);
    pass.filter(*tmp);

//    for (int i = 0; i < inliers->indices.size(); i++) {
//        cloud_filtered->points.push_back(tmp->points[inliers->indices[i]]);
//    }



    int distanceThreshold(5);
//    cout << "Distance threshold ---> ";
//    cin >> distanceThreshold;

    int times(4);
//    cout << "Times ---> ";
//    cin >> times;

    for (int i = 0; i < times; i++) {

        pcl::ModelCoefficients::Ptr coefficients (new pcl::ModelCoefficients);
        pcl::PointIndices::Ptr inliers (new pcl::PointIndices);
        // Create the segmentation object
        pcl::SACSegmentation<pcl::PointXYZ> seg;
        // Optional
        seg.setOptimizeCoefficients (true);
        // Mandatory
        seg.setModelType (pcl::SACMODEL_PLANE);
        seg.setMethodType (pcl::SAC_RANSAC);
        seg.setDistanceThreshold (distanceThreshold);
        seg.setInputCloud (tmp);
        seg.segment (*inliers, *coefficients);

        cout << "Indices size: " << inliers->indices.size() << endl;

        if (inliers->indices.size () == 0)
        {
            PCL_ERROR ("Could not estimate a planar model for the given dataset.");
//            return (-1);
            break;
        }


        pcl::ExtractIndices<pcl::PointXYZ> extract;
        extract.setInputCloud (tmp);
        extract.setIndices (inliers);
        extract.setNegative (true);
        extract.filter (*cloud_filtered);
        tmp.swap(cloud_filtered);
    }

    int cnt_frame(0);
    cout << "Cnt_frame ---> ";
    cin >> cnt_frame;

    int z(0);
    for (int i = 0; i < cloud_filtered->points.size(); i++) {
        if (z != cloud_filtered->points[i].z) {
            cout << cloud_filtered->points[i].z << endl;
            z = cloud_filtered->points[i].z;
        }
    }


    ViewerPtr viewer(new Viewer("Cloud viewer"));

    viewer->setBackgroundColor(128, 128, 128);
//    pcl::visualization::PointCloudColorHandlerCustom<pcl::PointXYZ> single_color(tmp, 0, 0, 0);
//    viewer->addPointCloud(tmp, single_color, "cloud");
    viewer->addPointCloud(tmp, "cloud");
    viewer->setPointCloudRenderingProperties(pcl::visualization::PCL_VISUALIZER_POINT_SIZE, 2, "cloud");
//    viewer->addCoordinateSystem(1.0);
//    viewer->addSphere(ORIGIN, 50);

    while (!viewer->wasStopped()) {
        viewer->spinOnce();
    }
    */


    int is_auto = 0;
//    std::string pcd_filename(argv[1]);
    std::string pcd_filename;

    std::cout << "Enter file name --> ";
//    std::cin >> pcd_filename;
    pcd_filename = "PCD1/3.pcd";

    CloudPtr original_cloud (new Cloud());
    CloudPtr cloud (new Cloud());
//    CloudPtr tmp (new Cloud());
//    if (pcl::io::loadPCDFile<Point> (pcd_filename, *original_cloud) == -1) { //* load the file
    if (pcl::io::loadPCDFile<Point> (pcd_filename, *cloud) == -1) { //* load the file
        PCL_ERROR ("Couldn't read file test_pcd.pcd \n");
        return 0;
    }

//    std::vector<double> color_v_1;
//    std::vector<double> color_v_2;
//    std::vector<int> color_v_cnt_1;
//    std::vector<int> color_v_cnt_2;
    double color;
    int j;

//    for (int i = 0; i < original_cloud->points.size(); i++) {
//        if (625 < original_cloud->points[i].z && original_cloud->points[i].z < 860) {
//        if (1120 < original_cloud->points[i].z && original_cloud->points[i].z < 1360) {
//        if (1100 < original_cloud->points[i].z && original_cloud->points[i].z < 1500) {
//            cloud->points.push_back(original_cloud->points[i]);
//            color = original_cloud->points[i].rgb;
//            if (color == 3000) {
//                for (j = 0; j < color_v_1.size(); j++) {
//                    if (color_v_1[j] == original_cloud->points[i].z) {
//                        color_v_cnt_1[j]++;
//                        break;
//                    }
//                }
//                if (j == color_v_1.size()) {
//                    Point p = original_cloud->points[i];
//                    color_v_1.push_back((double) p.z);
//                    color_v_cnt_1.push_back(1);
//                }
//
//            } else if (color == 1000) {
//                for (j = 0; j < color_v_2.size(); j++) {
//                    if (color_v_2[j] == color) {
//                        color_v_cnt_2[j]++;
//                        break;
//                    }
//                }
//            }
//        }
//    }

//    for (int i = 0; i < color_v.size(); i++) {
//        std::cout << "Color: " << color_v[i] << " With num: " << color_v_cnt[i] << std::endl;
//    }

    ViewerPtr viewer(new Viewer("Cloud viewer"));
    viewer->addPointCloud(cloud, "cloud");
//    viewer->setBackgroundColor(0.05, 0.05, 0.05, 0);
    viewer->setBackgroundColor(128, 128, 128);  // White background
    viewer->setPointCloudRenderingProperties(pcl::visualization::PCL_VISUALIZER_POINT_SIZE, 2, "cloud");
//    viewer->addCoordinateSystem(1.0);
//    viewer->addSphere(ORIGIN, 50);
//    while (!viewer->wasStopped()) {
//        viewer->spinOnce();
//    }
//    return 0;


    PointXYZ bound_up(-1 * SIZE_X, SIZE_Y, 0), bound_lp(SIZE_X, 0, SIZE_Z);
    std::string name = drawCube(viewer, bound_lp, bound_up);
//     std::cout << name << endl;

    calcByCluster(cloud, viewer);

//     MovingBox *movingBox = new MovingBox(viewer, cloud);
//     movingBox->setPCDFileName(pcd_filename);
//     movingBox->loadSVMModel("data.txt.model");
//     viewer->registerKeyboardCallback (keyboardEventOccurred, (void*)movingBox);
//     Extracter extracter(movingBox->extract());
//     extracter.calcVector(movingBox->getPoints());
//
//     pcl::PointCloud<PointXYZ>::Ptr stamp_position (new pcl::PointCloud<PointXYZ>());
//    pcl::PointCloud<PointXYZ>::Ptr stamp_position_SVM (new pcl::PointCloud<PointXYZ>());

//    int start;
//    cin >> start;

    while (!viewer->wasStopped()) {
        if (is_auto) {
//             movingBox->update(RIGHT);
//             Extracter extracter(movingBox->extract());
//             movingBox->setFeatureVector(extracter.calcVector(movingBox->getPoints()));
////             double cat_no_svm = movingBox->checkFeature();
//            double cat_SVM = movingBox->checkFeatureSVM();
////             if (cat_no_svm == 1) {
////                 movingBox->stamp();
////                 stamp_position->points.push_back(movingBox->toPointXYZ());
////             }
//            if (cat_SVM == 1) {
////            movingBox->stamp();
//            stamp_position_SVM->points.push_back(movingBox->toPointXYZ());
//            }
////            std::vector<double> v = movingBox->getFeature();
////            std::cout << "(" << v[0];
////            for (size_t i = 1; i < v.size(); i++)
////                std::cout << ", " << v[i];
////            std::cout << ")" << std::endl;
//////              __printVector<double> (movingBox->getFeature());
////              std::cout << "Type: " << cat << std::endl;
//             if (movingBox->hasGoneToEnd()) {
//                 is_auto = 0;
////                 cluster(stamp_position, viewer, false);
//                 cluster(stamp_position_SVM, viewer, true);
//////                 return 0;
//             }
////            viewer->spinOnce();
        } else {
            viewer->spinOnce();
        }
    }

    return (0);
}