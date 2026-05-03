#version 150
/* 
    Hi! This lightmap is taken from Fullbright UB, so all credits go to World Resource Pack for making the pack!
*/

uniform float AmbientLightFactor;
uniform float SkyFactor;
uniform float BlockFactor;
uniform int UseBrightLightmap;
uniform vec3 SkyLightColor;
uniform float NightVisionFactor;
uniform float DarknessScale;
uniform float DarkenWorldFactor;
uniform float BrightnessFactor;


in vec2 texCoord;

out vec4 fragColor;

float get_brightness(float level) {
    float curved_level = level / (4.0 - 3.0 * level);
    return mix(curved_level, 1.0, AmbientLightFactor);
}

vec3 notGamma(vec3 x) {
    vec3 nx = 1.0 - x;
    return 1.0 - nx * nx * nx * nx;
}

void main() {
    float block_brightness = get_brightness(texCoord.x) * BlockFactor;
	float sky_brightness = 1.00;
	if(BrightnessFactor >= 0.10) {
		sky_brightness = get_brightness(texCoord.y) * SkyFactor/2;
	} else {
		sky_brightness = get_brightness(texCoord.y) * SkyFactor;
	}
	float brightness = 0.20;
	vec3 color;
	if(BrightnessFactor >= 0.10) {
		color = vec3(
			block_brightness/3,
			block_brightness * ((block_brightness * 0.6 + 0.4) * 0.6 + 0.4)/3,
			block_brightness * (block_brightness * block_brightness * 0.6 + 0.4)/3
		);
	} else {
		color = vec3(
			block_brightness,
			block_brightness * ((block_brightness * 0.6 + 0.4) * 0.6 + 0.4),
			block_brightness * (block_brightness * block_brightness * 0.6 + 0.4)
		);
	}

    if (UseBrightLightmap != 0) {
        color = mix(color, vec3(0.99, 1.12, 1.0), 0.25);
        color = clamp(color, 0.0, 1.0);
    } else {
        color += SkyLightColor * sky_brightness;
        color = mix(color, vec3(0.75), 0.04);

        vec3 darkened_color = color * vec3(0.7, 0.6, 0.6);
        color = mix(color, darkened_color, DarkenWorldFactor);
    }

    if (NightVisionFactor > 0.0) {
        float max_component = max(color.r, max(color.g, color.b));
        if (max_component < 1.0) {
            vec3 bright_color = color / max_component;
            color = mix(color, bright_color, NightVisionFactor);
        }
    }

    if (UseBrightLightmap == 0) {
        color = clamp(color - vec3(DarknessScale), 0.0, 1.0);
    }
	
	if(BrightnessFactor >= 0.80 && BrightnessFactor != 1.00) {
		brightness = 1;
	} else {
		if(BrightnessFactor >= 0.10) {
			brightness = 0.2;
		} else {
			brightness = 0.05;
		}	
	}

    vec3 notGamma = notGamma(color);
    color = mix(color, notGamma, brightness * 10);
    color = mix(color, vec3(0.75), 0.04);
    color = clamp(color, 0.0, 1.0);
    
    if (BrightnessFactor <= 0.10) {
        color = vec3(1.0);
    }

    fragColor = vec4(color, 1.0);
}
