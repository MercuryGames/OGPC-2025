shader_type spatial;
render_mode world_vertex_coords;
uniform sampler2D noise;
uniform float time;
 
void vertex() {
  VERTEX.y *= sin((VERTEX.z+time)/5.0);
}

void fragment() {
  vec4 VERTEX_WORLD = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
  ALBEDO = vec3(texture(noise, VERTEX_WORLD.xz / vec2(10, 10)).x, texture(noise, VERTEX_WORLD.xz / vec2(10, 10)).x, 200);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
