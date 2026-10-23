#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float uYaw;
uniform float uPitch;
uniform float uTanHalfFov;
uniform vec4 uRegion;
uniform vec2 uSourceSize;
uniform vec3 uWarp0;
uniform vec3 uWarp1;
uniform vec3 uWarp2;
uniform float uUseWarp;
uniform sampler2D uPanorama;
out vec4 fragColor;
const float pi = 3.141592653589793;
void main() {
  vec2 p = (FlutterFragCoord().xy - uSize * .5) / (uSize.y * .5) * uTanHalfFov;
  vec3 ray = normalize(vec3(p.x, -p.y, 1.));
  float cp = cos(uPitch), sp = sin(uPitch);
  ray = vec3(ray.x, ray.y * cp + ray.z * sp, ray.z * cp - ray.y * sp);
  float cy = cos(uYaw), sy = sin(uYaw);
  ray = vec3(ray.x * cy + ray.z * sy, ray.y, ray.z * cy - ray.x * sy);
  vec2 uv = vec2(fract(atan(ray.x, ray.z) / (2. * pi) + .5), acos(clamp(ray.y, -1., 1.)) / pi);
  // Longitude wraps for independent layers spanning the panorama seam too.
  vec2 delta = uv - uRegion.xy;
  delta.x = fract(delta.x);
  vec2 local = delta / uRegion.zw;
  if (uUseWarp < 1.5 && (local.x < 0. || local.x > 1. || local.y < 0. || local.y > 1.)) {
    fragColor = vec4(0.);
    return;
  }
  if (uUseWarp > .5) {
    vec3 q = vec3(uUseWarp > 1.5 ? FlutterFragCoord().xy / uSize : local, 1.);
    vec3 h = vec3(dot(uWarp0,q), dot(uWarp1,q), dot(uWarp2,q));
    local = h.xy / h.z;
    if (local.x < 0. || local.x > 1. || local.y < 0. || local.y > 1.) {
      fragColor = vec4(0.); return;
    }
  }
  // Source-aligned patches reproduce the authored four-corner wall/table
  // perspective exactly, including its spherical projection. No billboarding.
  fragColor = texture(uPanorama, local);
  if (uRegion.z > .99) {
    // Wrap just the half texel that straddles the join; no broad mirror blur.
    float edge = min(uv.x, 1. - uv.x) * uSourceSize.x;
    if (edge < .5) {
      vec2 other = vec2(uv.x < .5 ? 1. - .5/uSourceSize.x : .5/uSourceSize.x, uv.y);
      fragColor = mix(fragColor, texture(uPanorama, other), .5-edge);
    }
  }
}
