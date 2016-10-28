# CPVR_FaceRecognition
This project is developed during the course Advanced Computer Perception at BFH.


### Output Directory Structure
The output directory should be structured as follows:

The root only contains the folders FaceDetection and FaceRecognition. They separate the different steps of the algorithm.
Both directories contain as subfolders n folders, one for each algorithm implemented.
Each subfolder contains a two diget number, which describes the test set used. These folders contains all the output files for the particular algorithm and the data set used.

'''
├── FaceDetection
│   └── ViolaJones
│       ├── 01
│       │   ├── face1.png
│       │   ├── face2.png
│       │   ├── face3.png
│       │   └── faces.bin
│       ├── 02
│       └── 03
└── FaceRecognition
    └── FisherFace
        └── 01
            ├── faces.bin
            └── group.png
'''

