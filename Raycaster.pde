class Ray {
  float x0;
  float y0;
  float endX;
  float endY;
  float magnitude;
  color c;
  int texLookupX = 1;
  int texLookupY = 1;
  boolean isVert = false;
  
  Ray(float tx0, float ty0, float tEndX, float tEndY, color tc, boolean tisVert) {
    x0 = tx0;
    y0 = ty0;
    endX = tEndX;
    endY = tEndY;
    magnitude = dist(x0, y0, endX, endY);
    c = tc;
    isVert = tisVert;
    if(isVert) {
      texLookupX = ((int)endY % 64) >> 3; 
      texLookupY = ((int)endX % 64) >> 3;  
    } else {
      texLookupX = ((int)endX % 64) >> 3; 
      texLookupY = ((int)endY % 64) >> 3;
    }
  }
}

float rad2deg = 0.0174533;
int yStretch = 45;

int mapX = 8;
int mapY = 8;

int[] map = { 1, 1, 1, 1, 1, 1, 1, 1,
              1, 0, 0, 0, 0, 0, 0, 1,
              1, 0, 0, 0, 0, 0, 0, 1,
              1, 0, 0, 1, 0, 0, 0, 1,
              1, 0, 0, 0, 1, 0, 0, 1,
              1, 0, 0, 0, 0, 1, 0, 1,
              1, 0, 0, 0, 0, 1, 0, 1,
              1, 1, 1, 1, 1, 1, 1, 1 };
              
int[] wallTex = { 1, 0, 1, 0, 1, 1, 1, 1,
                  0, 0, 0, 0, 0, 0, 0, 1,
                  1, 0, 0, 1, 0, 0, 0, 1,
                  0, 0, 0, 1, 0, 0, 0, 1,
                  1, 0, 0, 1, 0, 0, 0, 1,
                  0, 0, 0, 1, 0, 0, 0, 1,
                  1, 0, 0, 0, 0, 0, 0, 1,
                  0, 1, 1, 1, 1, 1, 1, 1 };
                  
float[] hues = { 0.3, 0.6, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3 };

boolean[] moveKeys = new boolean[4];

color white;
float red;
float blue;
float green;

float playerX = 128;
float playerY = 128;
float rotation = 1;

float lookDirX = cos(rotation);
float lookDirY = sin(rotation);
int moveSpeed = 2;
int turnSpeed = 3;

void setup() {
  size(1024, 512);
  
  colorMode(HSB, 1.0);
  white = color(1, 0, 1);
  red = 1;
  blue = 0.6;
  green = 0.4;
}

void draw() {
  background(0);
  
  handleInput();
  
  loadPixels();
  //Draw Sky
  drawSquare(width/2, 0, width/2, color(0.6, 0.5, 1));
  //Draw ground
  drawSquare(width/2, height/2, height/2, color(0, 0.5, 0.1));
  drawSquare(3*width/4, height/2, height/2, color(0, 0.5, 0.1));
  
  drawMap(8);
  drawPlayer2D();
  draw3DView(64);
  updatePixels();
}

void handleInput() {
  if(moveKeys[0]) { // W
    int xoIndex = (int)(playerX + 20*sign(lookDirX)) >> 6; //check 20 pixels in front for collisions
    int yoIndex = (int)(playerY + 20*sign(lookDirY)) >> 6;
    if(map[xoIndex + ((int)playerY >> 6) * mapX] == 0) playerX += lookDirX * moveSpeed;
    if(map[yoIndex * mapX + ((int)playerX >> 6)] == 0) playerY += lookDirY * moveSpeed;
  } else if(moveKeys[2]) { // S
    int xoIndex = (int)(playerX - 20*sign(lookDirX)) >> 6;
    int yoIndex = (int)(playerY - 20*sign(lookDirY)) >> 6;
    if(map[xoIndex + ((int)playerY >> 6) * mapX] == 0) playerX -= lookDirX * moveSpeed;
    if(map[yoIndex * mapX + ((int)playerX >> 6)] == 0) playerY -= lookDirY * moveSpeed;
  }
  if(moveKeys[1]) { // A
    rotation -= turnSpeed * 0.01;
    if(rotation < 0) rotation += 2 * PI;
    lookDirX = cos(rotation);
    lookDirY = sin(rotation);
  } else if(moveKeys[3]) { // D
    rotation += turnSpeed * 0.01;
    if(rotation > 2 * PI) rotation -= 2 * PI;
    lookDirX = cos(rotation);
    lookDirY = sin(rotation);
  }
}

void setMovement(int k, boolean b) {
  switch (k) {
  case 'w':
    moveKeys[0] = b;
    break;
  case 'a':
    moveKeys[1] = b;
    break;
  case 's':
    moveKeys[2] = b;
    break;
  case 'd':
    moveKeys[3] = b;
    break;
  }
}

void keyPressed() {
  setMovement(key, true);
}

void keyReleased() {
  setMovement(key, false);
}

int sign(float x) {
  if(x >= 0) return 1;
  else if(x < 0) return -1;
  else return 1;
}

void drawPixel(int x, int y, color c) {
  int index = constrain(y * width + x, 0, pixels.length - 1);
  pixels[index] = c;  
}

void drawSquare(int x0, int y0, int length, color c) {
  for(int i = 0; i < length; i++) {
    for(int j = 0; j < length; j++) {
      drawPixel(x0 + i, y0 + j, c);
    }
  }
}

void drawMap(int size) {
  for(int i = 0; i < size; i++) {
    for(int j = 0; j < size; j++) {
      if(map[i + j*size] != 0) { 
        drawSquare(i * 64, j * 64, (height / size) - 2, white); 
      }
    }
  }
}

void drawPlayer2D() {
  drawSquare((int)playerX - 3, (int)playerY - 3, 6, color(blue, 1, 1));  
  drawLine((int)playerX, (int)playerY, 
          (int)(playerX + lookDirX*10), (int)(playerY + lookDirY*10), 
          color(green, 1, 1));
}

void drawVerticalLine(int x0, int y0, int w, int h, int texLookup, boolean isVert) {
  for(int i = 0; i < w; i++) {
    for(int j = 0; j < h; j++) {
      float shading = 0.9;
      if(isVert) shading = 0.7;
      drawPixel(x0 + i, y0 + j, color(hues[wallTex[j*8/h + texLookup]], 1, shading));
    }
  }
}

void drawLineH(int x0, int y0, int x1, int y1, color c) {
  if(x0 > x1) { 
    x0 ^= x1; // swap their values using xor swap!
    x0 ^= x1 ^= x0;
    y0 ^= y1;
    y0 ^= y1 ^= y0;
  }
  
  int dx = x1 - x0;
  int dy = y1 - y0;
  
  int dir = 1; if(dy < 0) { dir = -1; }
  dy *= dir;
  
  if(dx != 0) {
    int y = y0;  
    int p = 2*dy - dx;
    for(int i = 0; i < dx + 1; i++) {
      drawPixel(x0 + i, y, c);
      if(p >= 0) {
        y += dir;
        p = p - 2*dx;
      }
      p = p + 2*dy;
    }
  }
}

void drawLineV(int x0, int y0, int x1, int y1, color c) {
  if(y0 > y1) { 
    x0 ^= x1; // swap their values using xor swap!
    x0 ^= x1 ^= x0;
    y0 ^= y1;
    y0 ^= y1 ^= y0;
  }
  
  int dx = x1 - x0;
  int dy = y1 - y0;
  
  int dir = 1; if(dx < 0) { dir = -1; }
  dx *= dir;
  
  if(dy != 0) {
    int x = x0;  
    int p = 2*dx - dy;
    for(int i = 0; i < dy + 1; i++) {
      drawPixel(x, y0 + i, c);
      if(p >= 0) {
        x += dir;
        p = p - 2*dy;
      }
      p = p + 2*dx;
    }
  }
}

void drawLine(int x0, int y0, int x1, int y1, color c) {
  if(abs(x0 - x1) < abs(y0 - y1)) {
    drawLineV(x0, y0, x1, y1, c);
  } else {
    drawLineH(x0, y0, x1, y1, c);
  }
}

Ray RayH(float x0, float y0, float angle) {
  int mx, my, mI = 0, dof = 0;  
  float rx = 0, ry = 0, xo = 0, yo = 0;
  float aTan = -1/tan(angle);
  
  if(angle > PI) {
    ry = (((int)y0 >> 6) << 6) - 0.001;  
    rx = (y0 - ry) * aTan + x0;
    yo = -64;
    xo = -yo * aTan;
  } else if(angle < PI) {
    ry = (((int)y0 >> 6) << 6) + 64;  
    rx = (y0 - ry) * aTan + x0;
    yo = 64;
    xo = -yo * aTan;
  }
  
  if(angle == 0 || angle == PI) dof = 8;
  
  while(dof < 8) {
    mx = (int)rx >> 6;
    my = (int)ry >> 6;
    mI = mx + my * mapX;
    mI = constrain(mI, 0, map.length - 1);
    if(map[mI] != 0) {
      dof = 8; // hit wall
    } else {
      rx += xo;
      ry += yo;
      dof += 1;
    }
  }
  float hue = map[mI];
  return new Ray(x0, y0, rx, ry, color(hue, 1, 0.9), false);
}

Ray RayV(float x0, float y0, float angle) {
  int mx, my, mI = 0, dof = 0;  
  float rx = 0, ry = 0, xo = 0, yo = 0;
  float nTan = -tan(angle);
  
  if(angle > HALF_PI && angle < 3*HALF_PI) {
    rx = (((int)x0 >> 6) << 6) - 0.001;  
    ry = (x0 - rx) * nTan + y0;
    xo = -64;
    yo = -xo * nTan;
  } else if(angle < HALF_PI || angle > 3*HALF_PI) {
    rx = (((int)x0 >> 6) << 6) + 64;  
    ry = (x0 - rx) * nTan + y0;
    xo = 64;
    yo = -xo * nTan;
  }
  
  if(angle == 0 || angle == PI) dof = 8;
  
  while(dof < 8) {
    mx = (int)rx >> 6;
    my = (int)ry >> 6;
    mI = mx + my * mapX;
    mI = constrain(mI, 0, map.length - 1);
    if(map[mI] != 0) {
      dof = 8; // hit wall
    } else {
      rx += xo;
      ry += yo;
      dof += 1;
    }
  }
  float hue = map[mI];
  return new Ray(x0, y0, rx, ry, color(hue, 1, 0.7), true);
}

Ray drawRay(float angle) {
  Ray rayV = RayV(playerX, playerY, angle);
  Ray rayH = RayH(playerX, playerY, angle);
  
  if(rayV.magnitude < rayH.magnitude) {
    drawLine((int)playerX, (int)playerY, (int)rayV.endX, (int)rayV.endY, rayV.c);
    rayV.c = color(hues[wallTex[rayV.texLookupY]], 1, 0.9);
    return rayV;
  } else {
    drawLine((int)playerX, (int)playerY, (int)rayH.endX, (int)rayH.endY, rayH.c);
    rayH.c = color(hues[wallTex[rayH.texLookupX]], 1, 0.7);
    return rayH;
  }
}

void draw3DView(int numRays) {
  int xStep = (width/2) / numRays;
  
  for(int i = 0; i < numRays; i++) {
    float angleOffset = (numRays/2 - i) * rad2deg;
    float newAngle = rotation - angleOffset;
    if(newAngle > 2*PI) newAngle -= 2*PI;
    if(newAngle < 0) newAngle += 2*PI;
    
    Ray thisRay = drawRay(newAngle);
    float newMagnitude = thisRay.magnitude * cos(angleOffset);
    float h = yStretch * (height / newMagnitude);
    drawVerticalLine(width/2 + (int)xStep*i, (int)(height - h)/2, (int)xStep, (int)h, 
      thisRay.texLookupX, thisRay.isVert);
  }
}
