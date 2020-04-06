import peasy.*;

PeasyCam cam;
PShader shader;
PImage diffuse, specular, normal, cloud, lights;

int loadState = 0;
int preloadState = 0;
float percent = 0;
float percentDsiplay = 0;
float lightRotation = 0;
PGraphics starBG;

void setup() {
  size(1280, 720, P3D);
  smooth(10);
  cam = new PeasyCam(this, 1200);
  cam.setMinimumDistance(2);

  shader = loadShader("frag.glsl", "vert.glsl");

  sphereDetail(80);
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
      percent = loadState/9.0*100;
      preloadState = loadState;
    }
    percentDsiplay = lerp(percentDsiplay, percent, 0.05);

    String s = String.format("Loading Texture...  %.1f%%", percentDsiplay);
    text(s, width/2-s.length()*5, height/2);
    stroke(255);
    line(0, height/2+20, (percentDsiplay/100)*width, height/2+20);
    if (99.9 - percentDsiplay < EPSILON) {
      s = String.format("Initializing...", percentDsiplay);
      text(s, width/2-s.length()*5, height/2 + 50);
    }
    cam.endHUD();
  }
}
void loadTexture() {
  int textureSize = 6144;

  diffuse = loadImage("6k_earth_daymap.jpg");
  loadState = 1;
  specular = loadImage("6k_earth_specular_map.jpg");
  loadState = 2;
  normal = loadImage("6k_earth_normal_map.jpg");
  loadState = 3;
  cloud = loadImage("6k_earth_clouds.jpg");
  loadState = 4;
  lights = loadImage("6k_earth_nightmap.jpg");
  loadState = 5;
  diffuse.resize(textureSize, textureSize);
  loadState = 6;
  specular.resize(textureSize, textureSize);
  loadState = 7;
  cloud.resize(textureSize, textureSize);
  loadState = 8;
  lights.resize(textureSize, textureSize);
  loadState = 9;
}
