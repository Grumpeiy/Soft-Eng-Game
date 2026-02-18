shader_type canvas_item;

// Controls how big the circle is (1.0 = full screen, 0.0 = closed)
uniform float circle_size : hint_range(0.0, 1.5) = 1.05;

// Controls where the center of the circle is (0.5, 0.5 is middle of screen)
uniform vec2 circle_center = vec2(0.5, 0.5);

void fragment() {
    // Correct for aspect ratio so the circle isn't an oval
    float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    vec2 uv = SCREEN_UV;
    uv.x = (uv.x - circle_center.x) * ratio + circle_center.x;
    
    // Calculate distance from the center
    float dist = distance(uv, circle_center);
    
    // If inside the circle size, become transparent (discard). 
    // If outside, draw the ColorRect's color (Black).
    if (dist < circle_size) {
        discard;
    }
}