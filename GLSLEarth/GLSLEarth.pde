import peasy.*;

PeasyCam cam;
PShader shader;
PImage diffuse, specular, normal, cloud, lights;
int textureSize = 6000;

int loadState = 0;
int preloadState = 0;
float percent = 0;
float percentDsiplay = 0;
float lightRotation = 0;
PGraphics starBG;

void setup() {
  //fullScreen(P3D, 2);
  size(1600, 900, P3D);
  background(0);
  sphereDetail(100);
  cam = new PeasyCam(this, 1200);
  cam.setMinimumDistance(2);

  shader = loadShader("frag.glsl", "vert.glsl");

  thread("loadTexture");

  starBG = createGraphics(width, height, P3D);
  starBG.beginDraw();
  starBG.background(0);
  starBG.stroke(255);
  for (int i=0; i<2000; i++) {
    starBG.strokeWeight(random(1.9));
    starBG.point(random(width), random(height));
  }
  starBG.endDraw();
}

void draw() {
  if (keyPressed && key == 'r')
    lightRotation += radians(0.5);
  background(0);

  if (100 - percentDsiplay <= EPSILON) {
    resetShader();
    cam.beginHUD();
    image(starBG, 0, 0);
    text("Press 'r' to rotate light", 20, 30);
    cam.endHUD();

    shader(shader);
    surface.setTitle(frameRate + "");
    shader.set("u_smoothness", 40.0);
    shader.set("u_specular_strength", 1.0);
    shader.set("u_cloud_brightness", 1.0);
    shader.set("u_fresnel", 1.3);
    shader.set("u_fresnel_strength", 1.4);
    shader.set("u_texture", diffuse);
    shader.set("u_texture_specular", specular);
    shader.set("u_texture_normal", normal);
    shader.set("u_texture_cloud", cloud);
    shader.set("u_texture_lights", lights);

    pointLight(255, 255, 255,
      10000*cos(lightRotation), -5000, 10000*sin(lightRotation));

    noStroke();
    sphere(500);
  } else {
    cam.beginHUD();
    fill(255);
    textSize(20);
    if (preloadState != loadState) {
      percent = loadState/5.0*100;
      preloadState = loadState;
    }
    percentDsiplay = lerp(percentDsiplay, percent, 0.1);

    String s = String.format("Loading Texture...  %.1f%%", percentDsiplay);
    text(s, width/2-s.length()*5, height/2);
    stroke(255);
    line(0, height/2+20, (percentDsiplay/100)*width, height/2+20);
    if (99.9 - percentDsiplay < EPSILON) {
      s = "Initializing...";
      text(s, width/2-s.length()*5, height/2 + 50);
    }
    cam.endHUD();
  }
}

void loadTexture() {
  thread("loadDiffuse");
  thread("loadSpecular");
  thread("loadNormal");
  thread("loadCloud");
  thread("loadLights");
}
void loadDiffuse() {
  diffuse = loadImage("6k_earth_daymap.jpg");
  diffuse.resize(textureSize, textureSize);
  loadState ++;
}
void loadSpecular() {
  specular = loadImage("6k_earth_specular_map.jpg");
  specular.resize(textureSize, textureSize);
  loadState ++;
}
void loadNormal() {
  normal = loadImage("6k_earth_normal_map.jpg");
  normal.resize(textureSize, textureSize);
  loadState ++;
}
void loadCloud() {
  cloud = loadImage("6k_earth_clouds.jpg");
  cloud.resize(textureSize, textureSize);
  loadState ++;
}
void loadLights() {
  lights = loadImage("6k_earth_nightmap.jpg");
  lights.resize(textureSize, textureSize);
  loadState ++;
}
