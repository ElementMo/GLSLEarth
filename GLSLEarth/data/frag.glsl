uniform float u_smoothness;
uniform float u_specular_strength;
uniform float u_cloud_brightness;
uniform float u_fresnel;
uniform float u_fresnel_strength;
uniform sampler2D u_texture;
uniform sampler2D u_texture_specular;
uniform sampler2D u_texture_normal;
uniform sampler2D u_texture_cloud;
uniform sampler2D u_texture_lights;

varying vec3 pixelNormal;
varying vec3 pixelPosition;
varying vec3 light_dir;
varying vec3 pixel_cam_dir;
varying vec4 pixel_texCoord;

mat3 cotangent_frame( vec3 N, vec3 p, vec2 uv ) {
    vec3 dp1 = dFdx( p );
    vec3 dp2 = dFdy( p );
    vec2 duv1 = dFdx( uv );
    vec2 duv2 = dFdy( uv );
 
    vec3 dp2perp = cross( dp2, N );
    vec3 dp1perp = cross( N, dp1 );
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
 
    float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
    return mat3( T * invmax, B * invmax, N );
}

void main(){
    vec3 N = normalize(pixelNormal);
    vec3 texture_normal = texture2D(u_texture_normal, pixel_texCoord.xy).xyz;
    texture_normal = normalize(texture_normal*2.0 - 1.0);
    texture_normal.x = -texture_normal.x;
    texture_normal.y = -texture_normal.y;
    mat3 TBN = cotangent_frame(N, pixelPosition, pixel_texCoord.xy);
    N = TBN * texture_normal;
    vec3 R = normalize( (N*dot(N, 2*light_dir)) - light_dir );
    float intensity = max(0.0, dot(light_dir, N));
    float intensity_smooth = max(0.0, dot(light_dir, normalize(pixelNormal)));
    float specular = pow(max( dot(pixel_cam_dir, R), 0.0), u_smoothness);
    float dot_value = dot(N, pixel_cam_dir);

    vec3 texture_color = texture2D (u_texture, pixel_texCoord.xy).xyz;
    vec3 texture_specular = texture2D(u_texture_specular, pixel_texCoord.xy).xyz;
    vec3 texture_cloud = texture2D(u_texture_cloud, pixel_texCoord.xy).xyz;
    vec3 texture_lights = texture2D(u_texture_lights, pixel_texCoord.xy).xyz;

    vec3 surface_color = vec3(1,1,1);
    surface_color *= 
        texture_color * intensity + 
        texture_specular * vec3(specular*2.0, specular*1.7, specular*1.4) * u_specular_strength + 
        smoothstep(0.22, 0.06, intensity ) * texture_lights * 1;
    vec3 atmosphere = texture_cloud * u_cloud_brightness * smoothstep( 0.06, 0.6, intensity_smooth ) + 
        texture_cloud * (intensity_smooth + 0.02) * ( 5 * smoothstep( 0.4, 0.0, intensity_smooth ) * vec3(0.9, 0.5, 0.2) * smoothstep(-0.1, 0.4, intensity_smooth )) + 
        smoothstep(0.22, 0.06, intensity ) * texture_cloud * 0.02;
    vec3 fresnel = pow((1 - dot_value), u_fresnel) * u_fresnel_strength * vec3(0.4, 0.7, 0.9) * smoothstep( -0.03, 0.4, intensity_smooth );
    
    surface_color *= (1 - atmosphere);
    surface_color += atmosphere;

    surface_color *= (1 - fresnel);
    surface_color += fresnel;

    gl_FragColor = vec4(surface_color, 1);
}