int n = 6; // needs to be >2;
int a = 40;
int rmax = 200;
float l = 100;
float l2 = sqrt(sq(l)/4+sq(tan(PI/a)*rmax));
float t = 0;
float r;

PVector[] points = new PVector[n+1];

float epsilon = PI/a;

float cameraAngle1 = 0;
float cameraAngle2 = 0;

PVector light = new PVector();

void setup(){
  size(600,600,P3D);
  background(220);
}

void draw(){
  r = 200-exp(-t);
  l2 = sqrt(sq(l)/4+sq(sin(PI/a)*rmax));
  println(r);
  points[0] = new PVector(r,0,0);
  points[1] = functionFirstPoint(r, epsilon, l, l2);
  for (int i=2; i<n; i++){
    if(i%2==0){
      points[i] = NextPoint1(points[i-2], points[i-1], l, l2);
    }else{
      points[i] = NextPoint2(points[i-2], points[i-1], l, l2);
    }
  }
  if(n%2==0){
    points[n] = NextPoint1(points[n-2], points[n-1], l/2, sin(PI/a)*rmax);
  }else{
    points[n] = NextPoint2(points[n-2], points[n-1], l/2, sin(PI/a)*rmax);
  }
  translate(width/2,height/2);
  background(220);
  directionalLight(255, 237, 209, light.x, light.y, light.z);
  ambientLight(110, 70, 20);
  for (float delta = 0; delta < TWO_PI; delta += TWO_PI/a){
    rotateY(TWO_PI/a);
    drawStrip(points);
  }
}

void drawStrip(PVector[] p){
  beginShape(TRIANGLE_STRIP);
  for (int i=p.length-1; i>0; i--){
    vertex(p[i].x, p[i].y, p[i].z);
  }
  for (int i=0; i<p.length; i++){
    vertex(p[i].x, -p[i].y, p[i].z);
  }
  endShape();
  
  beginShape(TRIANGLE_STRIP);
  for (int i=p.length-1; i>0; i--){
    if(i % 2 == 0){
      vertex(p[i].x, p[i].y, p[i].z);
    }else{
      vertex(p[i].x, p[i].y, -p[i].z);
    }
  }
  for (int i=0; i<p.length; i++){
    if(i % 2 == 0){
      vertex(p[i].x, -p[i].y, p[i].z);
    }else{
      vertex(p[i].x, -p[i].y, -p[i].z);
    }
  }
  endShape();
}

PVector invert(PVector v){
  PVector inv = new PVector(-v.x, -v.y, v.z);
  return inv;
}

PVector invertX(PVector v){
  PVector inv = new PVector(-v.x, v.y, v.z);
  return inv;
}

PVector invertY(PVector v){
  PVector inv = new PVector(v.x, -v.y, v.z);
  return inv;
}

void mouseDragged() {
  cameraAngle1 = (mouseX-width/2)/100.0;
  cameraAngle2 = (mouseY-height/2)/200.0;
  float d = (height/2.0) / tan(PI*30.0 / 180.0);
  camera(width/2.0+d*sin(cameraAngle1)*cos(cameraAngle2), height/2.0+d*sin(cameraAngle2), d*cos(cameraAngle1)*cos(cameraAngle2), width/2.0, height/2.0, 0, 0, 1, 0);
  light.set(-sin(cameraAngle1-0.5)*cos(cameraAngle2-1), -sin(cameraAngle2-1), -cos(cameraAngle1-0.5)*cos(cameraAngle2-1));
}

PVector functionFirstPoint(float r, float epsilon, float l1, float l2){
  if(sq(r*cos(epsilon))+sq(l2) < sq(l1)/4+sq(r)){
    println("l2 needs to be larger");
  }
  float value = r*cos(epsilon) - sqrt(sq(r*cos(epsilon))+sq(l2)-sq(l1)/4-sq(r));
  PVector vector = new PVector(value*cos(epsilon), l1/2, value*sin(epsilon));
  return vector;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  t += e/5;
}

void keyPressed(){
  if(key == '+'){
    l+=5;
  }
  if(key == '-'){
    l-=5;
  }
}

PVector NextPoint1(PVector p1, PVector p2, float l1, float l2){ // calculate the position of the next point on the plane z=0
  float l3 = sqrt(sq(l2)-sq(sqrt(sq(p2.x)+sq(p2.z))*sin(epsilon)));
  PVector np2 = new PVector(p2.x, p2.y, 0);
  PVector intersection = circleIntersection(p1, np2, l1, l3);
  return intersection;
}

PVector NextPoint2(PVector p1, PVector p2, float l1, float l2){ // calculate the position of the next point on the tilted plane
  float l3 = sqrt(sq(l2)-sq(p2.x*sin(epsilon)));
  PVector np1 = new PVector(p1.x/cos(epsilon), p1.y, 0);
  PVector np2 = new PVector(p2.x*cos(epsilon), p2.y, 0);
  PVector intersection = circleIntersection(np1, np2, l1, l3);
  PVector NextPoint = new PVector(intersection.x*cos(epsilon),intersection.y, intersection.x*sin(epsilon));
  return NextPoint;
}

PVector circleIntersection(PVector p1, PVector p2, float r1, float r2){ // trouve un point d'intersection entre 2 cercles (possiblement pas le bon)
  PVector dif = p2.copy().sub(p1);
  PVector horizontal = new PVector(1,0,0);
  float d = dif.mag();
  if (r1+r2 <= d || abs(r1-r2) >= d){
    println("No intersection of the cirles.");
  }
  float x = (sq(d) - sq(r2) + sq(r1))/(2*d);
  float y = sqrt((4*sq(d)*sq(r1)-sq(sq(d)-sq(r2)+sq(r1)))/(4*sq(d)));
  PVector intersection = new PVector(x,y);
  if(p1.y<p2.y){
    intersection.rotate(PVector.angleBetween(dif, horizontal));
  }else{
    intersection.rotate(-PVector.angleBetween(dif, horizontal));
  }
  return p1.copy().add(intersection);
}
