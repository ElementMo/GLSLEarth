uniform mat4 transform;
uniform mat4 modelview;
uniform vec4 lightPosition;

uniform vec3 cameraPosition;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec3 pixelNormal;
varying vec3 pixelPosition;
varying vec3 light_dir;
varying vec3 pixel_cam_dir;
varying vec4 pixel_texCoord;

void main(){
    gl_Position = transform * position;
    pixelNormal = normalize(modelview * vec4(normal, 1.0)).xyz;
    pixelPosition = position.xyz;
    light_dir = normalize(lightPosition.xyz - pixelPosition);
    pixel_cam_dir = normalize(cameraPosition - pixelPosition);
    pixel_texCoord = modelview * vec4(texCoord, 1.0, 1.0);
}