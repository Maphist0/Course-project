#include "pcd_project.h"

MovingBox::MovingBox(ViewerPtr _viewer, CloudPtr _cloud) {

    viewer = _viewer;
    cloud = _cloud;

    // Initialize with (-800, 2000, 22)
    // Initial z offset is half of the distences between layers, i.e. 45/2.
    lp.x = -1 * SIZE_X;
    lp.y = SIZE_Y;
    lp.z = 20;

    // Initialize with (-800 + 100, 0, 122)
    up.x = -1 * SIZE_X + INTERVAL_X;
    up.y = 0;
    up.z = INTERVAL_Z + 20;

    draw();
}

void MovingBox::update(DIRECTION dir = RIGHT) {

    // Z direction out of bound.
    if (lp.z >= SIZE_Z) return;

    switch (dir) {
        case RIGHT: {

            // Normal state, move to right.
            lp.x += DELTA_X;
            up.x += DELTA_X;

            // X direction out of bound.
            if (lp.x >= SIZE_X) {
                lp.x = -1 * SIZE_X;
                up.x = -1 * SIZE_X + INTERVAL_X;
                lp.z += DELTA_Z;  // Move one layer each time.
                up.z += DELTA_Z;  // To use as much information as possible.
            }
            break;
        }
        case LEFT: {
            lp.x -= DELTA_X;
            up.x -= DELTA_X;
            break;
        }
        case UP: {
            lp.z += DELTA_Z;
            up.z += DELTA_Z;
            break;
        }
        case DOWN: {
            lp.z -= DELTA_Z;
            up.z -= DELTA_Z;
            break;
        }
        default: break;
    }

    // Remove past lines.
    for (int i = 0; i < 12; ++i) {
        std::string lineName(name + std::to_string(i));
        viewer->removeShape(lineName.c_str());
    }

    draw();
}

CloudPtr MovingBox::extract() {

    CloudPtr tmp(new Cloud());
    CloudPtr result(new Cloud());
    Passthrough pass;

    // Extract for z direction;
    pass.setInputCloud(cloud);
    pass.setFilterFieldName("z");
    pass.setFilterLimits(lp.z, up.z);
    pass.filter(*tmp);

    // Extract for x direction;
    pass.setInputCloud(tmp);
    pass.setFilterFieldName("x");
    pass.setFilterLimits(lp.x, up.x);
    pass.filter(*result);

    return result;
}

std::vector<PointXYZ> MovingBox::getPoints() {

    std::vector<PointXYZ> v;
    v.push_back(lp);
    v.push_back(up);
    return v;
}

void MovingBox::saveFeature(int is_true) {

    // Filestream state: append.
    std::ofstream ofs ("data.txt", std::ofstream::app);
    ofs << (is_true ? "+1" : "-1");
    for (size_t i = 0; i < feature.size(); i++)
        ofs << " " << i + 1 << ":" << feature[i];
    ofs << '\n';
    ofs.close();
}

void MovingBox::saveBoxPos() {

    // Filestream state: append.
    std::ofstream ofs ("head-pos.txt", std::ofstream::app);
    ofs << PCDFileName;
    ofs << " " << lp.x << " " << lp.y << " " << lp.z;
    ofs << " " << up.x << " " << up.y << " " << up.z;
    ofs << '\n';
    ofs.close();
}

void MovingBox::__createNode (svm_node *nodes) {

    for (size_t i = 0; i < feature.size(); ++i) {
        nodes[i].index = int(i+1);
        nodes[i].value = double(feature[i]);
    }
    nodes[feature.size()].index = -1;
    nodes[feature.size()].value = 0;
}

void MovingBox::loadSVMModel(const char *name = "data.txt.model") {

    model = svm_load_model(name);
    if (!model) {
        std::cerr << "Load SVM model failed!" << std::endl;
        return;
    }
}

int MovingBox::__minPos(std::vector<double> v){
    double min(INT_MAX);
    int max_ID(0);
    for (int i = 0; i < v.size(); i++) {
        if (v[i] < min) {
            min = v[i];
            max_ID = i;
        }
    }
    return max_ID;
}

double MovingBox::checkFeature() {
    return (__minPos(feature) == feature.size() - 1 && feature[feature.size()-1] != 0);
}

double MovingBox::checkFeatureSVM() {

    double result;
    svm_node nodes[FEATURE_DIM + 1];
    __createNode(nodes);
    result = svm_predict(model, nodes);
    return result;
//    return (__minPos(feature) == feature.size() - 1 && feature[feature.size()-1] != 0);
}

PointXYZ MovingBox::toPointXYZ() {

    PointXYZ result;
    result.x = (lp.x + up.x) * 0.5;
    result.y = 0;
    result.z = (lp.z + up.z) * 0.5;
    return result;
}

void showCloud(char *filename) {

    CloudPtr cloud (new Cloud());

    if (pcl::io::loadPCDFile<Point> (filename, *cloud) == -1) { //* load the file
        PCL_ERROR ("Couldn't read file test_pcd.pcd \n");
        return;
    }

    ViewerPtr viewer(new Viewer("Cloud viewer"));
    viewer->addPointCloud(cloud, "cloud");
    viewer->setBackgroundColor(128, 128, 128);
    viewer->setPointCloudRenderingProperties(pcl::visualization::PCL_VISUALIZER_POINT_SIZE, 2, "cloud");
    viewer->addCoordinateSystem(1.0);
    viewer->addSphere(ORIGIN, 50);

    while (!viewer->wasStopped()) {
       viewer->spinOnce();
    }
}

// Press "r" to accept the points. "t" to reject. "y" to skip.
void keyboardEventOccurred (const KeyboardEvent &event, void* MovingBox_void) {
    MovingBox *movingBox = static_cast<MovingBox *> (MovingBox_void);
    if (event.keyDown()) {
        // std::cout << event.getKeySym() << std::endl;
        if (event.getKeySym() == "Up") {
            movingBox->update(UP);
        } else if (event.getKeySym() == "Down") {
            movingBox->update(DOWN);
        } else if (event.getKeySym() == "Left") {
            movingBox->update(LEFT);
        } else if (event.getKeySym() == "Right") {
            movingBox->update(RIGHT);
        } else if (event.getKeySym() == "s") {
            // Save the position of moving box.
            // To save where heads are.
            movingBox->saveBoxPos();
        } else if (event.getKeySym () == "r" || event.getKeySym() == "t" || event.getKeySym() == "y") {
            // Save former result
            // 'r' --> accept positive result.
            // 't' --> accept negative result.
            // 'y' --> skip.
            if (event.getKeySym() == "r") {
                movingBox->stamp();
                // movingBox->saveBoxPos();
//                movingBox->saveFeature(1);
            } else if (event.getKeySym() == "t") {
                movingBox->stampRed();
//                movingBox->saveFeature(0);
            } else if (event.getKeySym() == "y") {
                // std::cout << movingBox->checkFeature() << std::endl;
            }
            movingBox->update();
        }
        Extracter extracter(movingBox->extract());
        movingBox->setFeatureVector(extracter.calcVector(movingBox->getPoints()));
        // std::cout << "r was pressed => accept points" << std::endl;
    }
}

// This function draw a cube.
// From the left bottom point "lp", to the right up point "up".
std::string drawCube (ViewerPtr viewer, PointXYZ lp, PointXYZ up) {

  std::string name = std::to_string((int) clock());
  name += '_';
  viewer->addLine (lp, PointXYZ(lp.x, lp.y, up.z), (name + std::to_string(0)).c_str(), 0);
  viewer->addLine (lp, PointXYZ(lp.x, up.y, lp.z), (name + std::to_string(1)).c_str(), 0);
  viewer->addLine (lp, PointXYZ(up.x, lp.y, lp.z), (name + std::to_string(2)).c_str(), 0);
  viewer->addLine (up, PointXYZ(up.x, up.y, lp.z), (name + std::to_string(3)).c_str(), 0);
  viewer->addLine (up, PointXYZ(up.x, lp.y, up.z), (name + std::to_string(4)).c_str(), 0);
  viewer->addLine (up, PointXYZ(lp.x, up.y, up.z), (name + std::to_string(5)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(lp.x, up.y, up.z), (name + std::to_string(6)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(up.x, lp.y, up.z), (name + std::to_string(7)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(up.x, up.y, lp.z), (name + std::to_string(8)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(lp.x, up.y, up.z), (name + std::to_string(9)).c_str(), 0);
  viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, up.y, lp.z), (name + std::to_string(10)).c_str(), 0);
  viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, lp.y, up.z), (name + std::to_string(11)).c_str(), 0);
  return name;
}

std::string drawCubeRed (ViewerPtr viewer, PointXYZ lp, PointXYZ up) {

  std::string name = std::to_string((int) clock());
  name += '_';
  viewer->addLine (lp, PointXYZ(lp.x, lp.y, up.z), 128, 0, 0, (name + std::to_string(0)).c_str(), 0);
  viewer->addLine (lp, PointXYZ(lp.x, up.y, lp.z), 128, 0, 0, (name + std::to_string(1)).c_str(), 0);
  viewer->addLine (lp, PointXYZ(up.x, lp.y, lp.z), 128, 0, 0, (name + std::to_string(2)).c_str(), 0);
  viewer->addLine (up, PointXYZ(up.x, up.y, lp.z), 128, 0, 0, (name + std::to_string(3)).c_str(), 0);
  viewer->addLine (up, PointXYZ(up.x, lp.y, up.z), 128, 0, 0, (name + std::to_string(4)).c_str(), 0);
  viewer->addLine (up, PointXYZ(lp.x, up.y, up.z), 128, 0, 0, (name + std::to_string(5)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(lp.x, up.y, up.z), 128, 0, 0, (name + std::to_string(6)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(up.x, lp.y, up.z), 128, 0, 0, (name + std::to_string(7)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(up.x, up.y, lp.z), 128, 0, 0, (name + std::to_string(8)).c_str(), 0);
  viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(lp.x, up.y, up.z), 128, 0, 0, (name + std::to_string(9)).c_str(), 0);
  viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, up.y, lp.z), 128, 0, 0, (name + std::to_string(10)).c_str(), 0);
  viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, lp.y, up.z), 128, 0, 0, (name + std::to_string(11)).c_str(), 0);
  return name;
}


std::string drawCubeGreen (ViewerPtr viewer, PointXYZ lp, PointXYZ up) {

    std::string name = std::to_string((int) clock());
    name += '_';
    viewer->addLine (lp, PointXYZ(lp.x, lp.y, up.z), 0, 128, 0, (name + std::to_string(0)).c_str(), 0);
    viewer->addLine (lp, PointXYZ(lp.x, up.y, lp.z), 0, 128, 0, (name + std::to_string(1)).c_str(), 0);
    viewer->addLine (lp, PointXYZ(up.x, lp.y, lp.z), 0, 128, 0, (name + std::to_string(2)).c_str(), 0);
    viewer->addLine (up, PointXYZ(up.x, up.y, lp.z), 0, 128, 0, (name + std::to_string(3)).c_str(), 0);
    viewer->addLine (up, PointXYZ(up.x, lp.y, up.z), 0, 128, 0, (name + std::to_string(4)).c_str(), 0);
    viewer->addLine (up, PointXYZ(lp.x, up.y, up.z), 0, 128, 0, (name + std::to_string(5)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(lp.x, up.y, up.z), 0, 128, 0, (name + std::to_string(6)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(up.x, lp.y, up.z), 0, 128, 0, (name + std::to_string(7)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(up.x, up.y, lp.z), 0, 128, 0, (name + std::to_string(8)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(lp.x, up.y, up.z), 0, 128, 0, (name + std::to_string(9)).c_str(), 0);
    viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, up.y, lp.z), 0, 128, 0, (name + std::to_string(10)).c_str(), 0);
    viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, lp.y, up.z), 0, 128, 0, (name + std::to_string(11)).c_str(), 0);
    return name;
}

std::string drawCubeBlue (ViewerPtr viewer, PointXYZ lp, PointXYZ up) {

    std::string name = std::to_string((int) clock());
    name += '_';
    viewer->addLine (lp, PointXYZ(lp.x, lp.y, up.z), 0, 0, 128, (name + std::to_string(0)).c_str(), 0);
    viewer->addLine (lp, PointXYZ(lp.x, up.y, lp.z), 0, 0, 128, (name + std::to_string(1)).c_str(), 0);
    viewer->addLine (lp, PointXYZ(up.x, lp.y, lp.z), 0, 0, 128, (name + std::to_string(2)).c_str(), 0);
    viewer->addLine (up, PointXYZ(up.x, up.y, lp.z), 0, 0, 128, (name + std::to_string(3)).c_str(), 0);
    viewer->addLine (up, PointXYZ(up.x, lp.y, up.z), 0, 0, 128, (name + std::to_string(4)).c_str(), 0);
    viewer->addLine (up, PointXYZ(lp.x, up.y, up.z), 0, 0, 128, (name + std::to_string(5)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(lp.x, up.y, up.z), 0, 0, 128, (name + std::to_string(6)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, lp.y, up.z), PointXYZ(up.x, lp.y, up.z), 0, 0, 128, (name + std::to_string(7)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(up.x, up.y, lp.z), 0, 0, 128, (name + std::to_string(8)).c_str(), 0);
    viewer->addLine (PointXYZ(lp.x, up.y, lp.z), PointXYZ(lp.x, up.y, up.z), 0, 0, 128, (name + std::to_string(9)).c_str(), 0);
    viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, up.y, lp.z), 0, 0, 128, (name + std::to_string(10)).c_str(), 0);
    viewer->addLine (PointXYZ(up.x, lp.y, lp.z), PointXYZ(up.x, lp.y, up.z), 0, 0, 128, (name + std::to_string(11)).c_str(), 0);
    return name;
}