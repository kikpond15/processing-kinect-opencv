import processing.video.*;
import gab.opencv.*;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;


Kinect kinect;
OpenCV opencv;

PImage depthImg, dst;
int minDepth =  60;
int maxDepth = 960;
float angle;
ArrayList<Contour> contours;
ArrayList<PVector> points;
int thresVal = 70;
int blurVal = 5;

void setup() {
  size(1280, 960);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  kinect.enableColorDepth(false);
  angle = kinect.getTilt();
  depthImg = new PImage(kinect.width, kinect.height);
  opencv = new OpenCV(this, kinect.width, kinect.height);
  points = new ArrayList<PVector>();
}

void draw() {
  background(0);

  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }
  depthImg.updatePixels();

  //OpenCv
  opencv.loadImage(depthImg);
  opencv.gray();
  opencv.blur(blurVal);
  opencv.threshold(thresVal);
  dst = opencv.getOutput();
  contours = opencv.findContours();

  image(kinect.getVideoImage(), 0, 0);
  image(kinect.getDepthImage(), 640, 0);
  image(depthImg, 0, 480);

  //draw contour 
  pushMatrix();
  translate(640, 480);
  for (Contour contour : contours) {
    float sumX=0;
    float sumY=0;
    noFill();
    stroke(255);
    beginShape();
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      vertex(point.x, point.y);
      sumX += point.x;
      sumY += point.y;
    }
    endShape(CLOSE);
    int pointsNum = contour.getPolygonApproximation().numPoints();
    PVector center = new PVector(sumX/pointsNum, sumY/pointsNum);
    stroke(255, 0, 0);
    ellipse(center.x, center.y, 10, 10);
  }
  popMatrix();
}

void keyPressed() {   
  if (keyCode == UP) thresVal = constrain(thresVal+10, 1, 255);
  else if (keyCode == DOWN) thresVal = constrain(thresVal-10, 1, 255);
  else if (keyCode == LEFT) blurVal = constrain(blurVal-5, 1, 50);
  else if (keyCode == RIGHT) blurVal = constrain(blurVal+5, 1, 50);
  else if (key == 'a') minDepth = constrain(minDepth+10, 0, maxDepth);
  else if (key == 's') minDepth = constrain(minDepth-10, 0, maxDepth);
  else if (key == 'z') maxDepth = constrain(maxDepth+10, minDepth, 2047);
  else if (key =='x') maxDepth = constrain(maxDepth-10, minDepth, 2047);

  if (key == 'q' || key == 'w') {
    if (key == 'q'){
      angle--;
    } else if(key == 'w'){
      angle++;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  }

  println("threshold:" + thresVal + ", blur:" + blurVal);
  println("minDepth:" + minDepth + ", maxDepth:" + maxDepth);
  println("------------------------------");
}
