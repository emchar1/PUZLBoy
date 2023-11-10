//
//  transitionShader.fsh
//  PUZL Boy
//
//  Created by Eddie Char on 7/7/23.
//

#define M 1000.0 // Multiplier

void main() {
    float aspect = a_sprite_size.y / a_sprite_size.x;
    float u = v_tex_coord.x;
    float v = v_tex_coord.y * aspect;
    vec2 uv = vec2(u,v) * M;
    vec2 center = vec2(0.60,0.55 * aspect) * M;
    float t = u_time / a_duration;

    if(t < 1.0) {
        float easeIn = pow(t,5.0);
        float radius = easeIn * 2.0 * M;
        float d = length(center - uv) - radius;
        float a = clamp(d, 0.0, 1.0);
        
        gl_FragColor = vec4(0.0,0.0,0.0, a);
    }
    else {
        gl_FragColor = vec4(0.0,0.0,0.0,0.0);
    }
}
