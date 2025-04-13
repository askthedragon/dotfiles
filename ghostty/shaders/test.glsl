// Hacker Theme Shader for Ghostty
// Inspired by cyberpunk aesthetics, digital glitches, and the Matrix

// Customizable parameters
float scanlineIntensity = 0.15;      // Scanline visibility (0.0 - 0.5)
float glitchIntensity = 0.03;        // How much glitch effect (0.0 - 0.1)
float flickerSpeed = 6.0;            // How fast the screen flickers
float flickerIntensity = 0.02;       // How pronounced the flicker is
float noiseAmount = 0.02;            // Static noise amount
vec3 mainColor = vec3(1.0, 1.0, 1.0); // Neutral color (no tint)

// Hash function for pseudo-random values
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Random function based on coordinates
float random(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // Screen curvature effect
    vec2 center = uv - 0.5;
    float distFromCenter = length(center);
    vec2 aberration = center * (0.01 * distFromCenter * distFromCenter);
    
    // CRT curvature warp
    float warp = 0.05;
    vec2 dc = abs(0.5 - uv);
    dc *= dc;
    
    vec2 warpedUV = uv;
    warpedUV.x -= 0.5; 
    warpedUV.x *= 1.0 + (dc.y * (0.2 * warp)); 
    warpedUV.x += 0.5;
    warpedUV.y -= 0.5; 
    warpedUV.y *= 1.0 + (dc.x * (0.2 * warp)); 
    warpedUV.y += 0.5;
    
    // Create glitch effect
    float time = iTime * 2.0;
    float glitchLine = step(1.0 - glitchIntensity, random(vec2(time, 0.0)));
    
    // Determine if current row has glitch
    float lineNoise = 0.0;
    if (glitchLine > 0.5 && random(vec2(time, 2.0)) > 0.75) {
        lineNoise = glitchIntensity * 5.0 * random(vec2(time, uv.y));
    }
    
    // Apply horizontal line shift for certain rows
    float lineShift = lineNoise * 0.05;
    warpedUV.x = fract(warpedUV.x + lineShift); 
    
    // Random color channel split (chromatic aberration)
    float rShift = aberration.x * (0.5 + 0.5 * sin(time * 0.5));
    float bShift = aberration.x * (0.5 + 0.5 * cos(time * 0.5));
    
    // Sample texture with RGB color splitting
    vec3 color;
    color.r = texture(iChannel0, vec2(warpedUV.x + rShift, warpedUV.y)).r;
    color.g = texture(iChannel0, warpedUV).g;
    color.b = texture(iChannel0, vec2(warpedUV.x + bShift, warpedUV.y)).b;
    
    // Add scanlines
    float scanline = smoothstep(0.0, scanlineIntensity, abs(sin(uv.y * iResolution.y * 0.7)));
    color = mix(color, color * (1.0 - scanlineIntensity), scanline);
    
    // CRT flickering
    float flicker = 1.0 - flickerIntensity * pow(abs(sin(iTime * flickerSpeed)), 2.0);
    
    // No color tinting applied
    // color = mix(color, color * mainColor, 0.85);
    
    // Add random noise
    float noise = random(uv + vec2(time, time));
    color += mix(-noiseAmount, noiseAmount, noise);
    
    // Digital distortion bands
    if (random(vec2(time, 5.0)) > 0.98) {
        float distortionPos = random(vec2(time, 7.0));
        float distortionHeight = 0.01 + random(vec2(time, 13.0)) * 0.03;
        if (abs(uv.y - distortionPos) < distortionHeight) {
            color *= 1.1; // Highlight distortion band
            color.r += 0.05; // Add slight red tint to distortion
        }
    }
    
    // Vignette effect (darker corners)
    float vignette = 1.0 - distFromCenter * 0.7;
    color *= vignette;
    
    // Apply flicker effect
    color *= flicker;
    
    // Final color
    fragColor = vec4(color, 1.0);
    
    // Add subtle "digital" horizontal lines 
    float horizontalLines = step(0.5, fract(uv.y * 320.0)) * 0.02;
    fragColor.rgb -= horizontalLines;
    
    // Edge enhancement for terminal text (using neutral color)
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    float edge = abs(dFdx(luminance)) + abs(dFdy(luminance));
    fragColor.rgb += edge * 2.0;
}
