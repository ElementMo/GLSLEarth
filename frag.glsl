uniform float u_smoothness;
uniform sampler2D u_texture;
uniform sampler2D u_texture_specular;
uniform sampler2D u_texture_cloud;
uniform sampler2D u_texture_lights;

uniform vec3 cameraPosition;

varying vec3 pixelNormal;
varying vec4 vertColor;
varying vec3 light_dir;
varying vec3 pixel_cam_dir;
varying vec4 pixel_texCoord;


void main(){
    vec3 N = normalize(pixelNormal);
    vec3 R = normalize( (N*dot(N, 2*light_dir)) - light_dir );

    float intensity = max(0.0, dot(light_dir, N));
    float specular = pow(max( dot(pixel_cam_dir, R), 0.0), u_smoothness);
    float dot_value = normalize(dot(N, pixel_cam_dir));

    vec3 texture_color = texture2D (u_texture, pixel_texCoord.xy).xyz;
    vec3 texture_specular = texture2D(u_texture_specular, pixel_texCoord.xy).xyz;
    vec3 texture_cloud = texture2D(u_texture_cloud, pixel_texCoord.xy).xyz;
    vec3 texture_lights = texture2D(u_texture_lights, pixel_texCoord.xy).xyz;

    vec3 surface_color = vec3(1,1,1);
    surface_color *= 
        texture_color * intensity + 
        texture_color * texture_specular * vec3(specular*2.0, specular*1.7, specular*1.4) * 2 + 
        smoothstep(0.22, 0.06, intensity ) * texture_lights;
    vec3 atmosphere = texture_cloud * (intensity + 0.06) * (1 + 5*smoothstep( 0.4, 0.0, intensity ) * vec3(0.9, 0.5, 0.2) * smoothstep(-0.1, 0.4, intensity ));
    
    surface_color *= (1 - atmosphere);
    surface_color += atmosphere;

    gl_FragColor = vec4(surface_color, 1);
}