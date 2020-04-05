import peasy.*;

PeasyCam cam;
PShader shader;
PImage diffuse, specular, cloud, lights;


void setup() {
  size(800, 800, P3D);
  loadTexture();
  cam = new PeasyCam(this, 600);
  shader = loadShader("frag.glsl", "vert.glsl");
  shader(shader);
  sphereDetail(50);
  noStroke();
}

void draw() {
  surface.setTitle(frameRate + "");
  shader.set("u_smoothness", 64.0);
  shader.set("u_texture", diffuse);
  shader.set("u_texture_specular", specular);
  shader.set("u_texture_cloud", cloud);
  shader.set("u_texture_lights", lights);
  
  background(0);

  pointLight(255, 255, 255, 
    1000*cos(radians(frameCount/5.0)), -500, 1000*sin(radians(frameCount/5.0)));

  sphere(200);
}
void loadTexture() {
  int textureSize = 2048;
  diffuse = loadImage("2k_earth_daymap.jpg");
  specular = loadImage("2k_earth_specular_map.jpg");
  cloud = loadImage("2k_earth_clouds.jpg");
  lights = loadImage("2k_earth_nightmap.jpg");
  diffuse.resize(textureSize, textureSize);
  specular.resize(textureSize, textureSize);
  cloud.resize(textureSize, textureSize);
  lights.resize(textureSize, textureSize);
}
