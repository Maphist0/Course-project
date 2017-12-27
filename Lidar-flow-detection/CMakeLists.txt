cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

project(pcl)

find_package(PCL 1.8 REQUIRED COMPONENTS common io features visualization console filters kdtree sample_consensus segmentation search)

include_directories(${PCL_INCLUDE_DIRS})

link_directories(${PCL_LIBRARY_DIRS})

add_definitions(${PCL_DEFINITIONS})

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp)

add_executable(pcl pcd_project.h svm.cpp svm.h viewer.cpp calculator.cpp ${SOURCE_FILES})

target_link_libraries(pcl ${PCL_LIBRARIES})

set_target_properties(pcl PROPERTIES COMPILE_FLAGS "-w")    #Ignore all warnings.