import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
import gab.opencv.*;

Kinect kinect;
OpenCV opencv;

PImage depthImg, dst;
ArrayList<Contour> contours;
ArrayList<PVector> points;
int thresVal = 70;
int blurVal = 5;


void setup()
{
  //fullScreen();
  size(1280, 960);
  kinect = new Kinect(this);
  depthImg = new PImage(kinect.GetDepth().width, kinect.GetDepth().height);
  opencv = new OpenCV(this, kinect.GetDepth().width, kinect.GetDepth().height);
  points = new ArrayList<PVector>();
}

void draw()
{
  background(0);
  image(kinect.GetImage(), 0, 0);
  image(kinect.GetDepth(), 640, 0);

  opencv.loadImage(kinect.GetDepth());
  opencv.gray();
  opencv.blur(blurVal);
  opencv.threshold(thresVal);
  dst = opencv.getOutput();
  contours = opencv.findContours();
  image(dst, 0, 480);

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
  //else if (key == 'a') minDepth = constrain(minDepth+10, 0, maxDepth);
  //else if (key == 's') minDepth = constrain(minDepth-10, 0, maxDepth);
  //else if (key == 'z') maxDepth = constrain(maxDepth+10, minDepth, 2047);
  //else if (key =='x') maxDepth = constrain(maxDepth-10, minDepth, 2047);


  println("threshold:" + thresVal + ", blur:" + blurVal);
  //println("minDepth:" + minDepth + ", maxDepth:" + maxDepth);
  println("------------------------------");
}
