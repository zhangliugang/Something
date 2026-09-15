//
//  check.metal
//  Example
//
//  Created by liugang zhang on 2026/6/2.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 checkerboard(float2 position, half4 currentColor, float checkSize, float opacity) {
    // A view will consist of a certain number of checkers in the x and y direction
    // posInChecks gives which checker will the given pixel belongs to.
    uint2 posInChecks = uint2(position.x / checkSize, position.y / checkSize);
    bool isOpaque = (posInChecks.x ^ posInChecks.y) & 1;
    return isOpaque ? currentColor * opacity : currentColor;
}

[[ stitchable ]] float2 rainbow(float2 position, float viewWidth, float maxHeightOffset) {
    float newPositionY =  sqrt(pow(maxHeightOffset, 2) - pow(position.x - viewWidth / 2, 2))  + position.y;
    return float2(position.x, newPositionY);
}

[[ stitchable ]] half4 rainbowCheckerboard(float2 position, SwiftUI::Layer layer, float viewWidth, float maxHeightOffset, float checkSize, float opacity) {
    float newPositionY =  sqrt(pow(maxHeightOffset, 2) - pow(position.x - viewWidth / 2, 2))  + position.y;
    float2 newPosition = float2(position.x, newPositionY);

    uint2 posInChecks = uint2(position.x / checkSize, position.y / checkSize);
    bool isOpaque = (posInChecks.x ^ posInChecks.y) & 1;

    half4 color = layer.sample(newPosition);
    return isOpaque ? color * opacity : color;
}

[[ stitchable ]] half4 checkerboardRainbow(float2 position, SwiftUI::Layer layer, float viewWidth, float maxHeightOffset, float checkSize, float opacity) {
    float newPositionY =  sqrt(pow(maxHeightOffset, 2) - pow(position.x - viewWidth / 2, 2))  + position.y;
    float2 newPosition = float2(position.x, newPositionY);

    uint2 posInChecks = uint2(newPosition.x / checkSize, newPosition.y / checkSize);
    bool isOpaque = (posInChecks.x ^ posInChecks.y) & 1;

    half4 color = layer.sample(newPosition);
    return isOpaque ? color * opacity : color;
}
