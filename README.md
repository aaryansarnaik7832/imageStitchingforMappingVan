# Image Stitching Pipeline for Autonomous Vehicle Mapping

## Project Overview
This project develops an efficient image stitching pipeline to process and combine image data collected from multiple cameras mounted on mapping vans. The work is part of a collaborative effort between the United States Department of Transportation, Carnegie Mellon University, and Pennsylvania State University, aimed at advancing autonomous vehicle technology.

## Background
Mapping vans equipped with multiple cameras collect vast amounts of visual data essential for autonomous vehicle navigation and mapping. However, storing and processing this data presents significant challenges due to storage requirements and computational overhead. Our pipeline addresses these challenges by efficiently combining overlapping images while maintaining data quality.

## Key Features
The pipeline implements a sophisticated image stitching process that:
* Processes overlapping images from multiple camera angles
* Preserves critical visual information for autonomous navigation
* Reduces storage requirements by more than 60%
* Maintains high-quality visual data necessary for mapping applications

## Technical Approach
The pipeline employs advanced computer vision techniques including:
* Feature detection and matching using SIFT (Scale-Invariant Feature Transform)
* RANSAC-based outlier removal for robust feature matching
* Homography estimation for image alignment
* Multi-band blending for seamless image composition

## Applications
The developed pipeline has direct applications in:
* Creating comprehensive visual maps for autonomous vehicles
* Reducing storage and processing requirements for large-scale mapping operations
* Supporting real-time navigation systems
* Enhancing the efficiency of autonomous vehicle mapping infrastructure

## Project Impact
This work contributes to the broader goal of making autonomous vehicle mapping more efficient and cost-effective. The significant reduction in storage requirements, combined with maintained data quality, represents a substantial improvement in mapping infrastructure capabilities.

## Research Context
This project was conducted at Pennsylvania State University under the guidance of Professor Sean Brennan, as part of a broader initiative to advance autonomous vehicle technology through improved mapping capabilities.

## Acknowledgments
This work was made possible through collaboration between:
* United States Department of Transportation
* Carnegie Mellon University
* Pennsylvania State University

## Timeline
June 2024 - August 2024

---
For technical details and implementation specifics, please refer to the project documentation.
