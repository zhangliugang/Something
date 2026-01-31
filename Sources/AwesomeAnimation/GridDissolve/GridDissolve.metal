#include <metal_stdlib>
#include "../../Shared/Shared.h"
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
    float2 positions[4] = {
        float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1)
    };
    float2 texCoords[4] = {
        float2(0, 0), float2(1, 0), float2(0, 1), float2(1, 1)
    };
    VertexOut out;
    out.position = float4(positions[vertexID], 0, 1);
    out.texCoord = texCoords[vertexID];
    return out;
}

// Pseudo-random function (avoid conflict with built-in)
float random11(float2 uv, float seed) {
    return fract(sin(dot(uv + seed, float2(12.9898, 78.233))) * 43758.5453);
}

// Calculate cell start time based on direction
float calculateStartTime(int direction, int col, int row,
                         int numCols, int numRows,
                         float maxStartTime, float seed) {
    float t = 0.0;

    switch (direction) {
        case 0:  // leftToRight
            t = float(col) / max(1.0, float(numCols - 1)) * maxStartTime;
            break;
        case 1:  // rightToLeft
            t = float(numCols - 1 - col) / max(1.0, float(numCols - 1)) * maxStartTime;
            break;
        case 2:  // topToBottom
            t = float(row) / max(1.0, float(numRows - 1)) * maxStartTime;
            break;
        case 3:  // bottomToTop
            t = float(numRows - 1 - row) / max(1.0, float(numRows - 1)) * maxStartTime;
            break;
        case 4:  // topLeftToBottomRight
        {
            float colProgress = float(col) / max(1.0, float(numCols - 1));
            float rowProgress = float(row) / max(1.0, float(numRows - 1));
            t = (colProgress + rowProgress) / 2.0 * maxStartTime;
        }
            break;
        case 5:  // topRightToBottomLeft
        {
            float colProgress = float(numCols - 1 - col) / max(1.0, float(numCols - 1));
            float rowProgress = float(row) / max(1.0, float(numRows - 1));
            t = (colProgress + rowProgress) / 2.0 * maxStartTime;
        }
            break;
        case 6:  // bottomLeftToTopRight
        {
            float colProgress = float(col) / max(1.0, float(numCols - 1));
            float rowProgress = float(numRows - 1 - row) / max(1.0, float(numRows - 1));
            t = (colProgress + rowProgress) / 2.0 * maxStartTime;
        }
            break;
        case 7:  // bottomRightToTopLeft
        {
            float colProgress = float(numCols - 1 - col) / max(1.0, float(numCols - 1));
            float rowProgress = float(numRows - 1 - row) / max(1.0, float(numRows - 1));
            t = (colProgress + rowProgress) / 2.0 * maxStartTime;
        }
            break;
        case 8:  // centerOut
        {
            float2 center = float2(numCols - 1, numRows - 1) * 0.5;
            float2 pos = float2(col, row);
            float dist = distance(pos, center) / distance(float2(0.0, 0.0), center);
            t = dist * maxStartTime;
        }
            break;
        case 9:  // edgeIn
        {
            float2 center = float2(numCols - 1, numRows - 1) * 0.5;
            float2 pos = float2(col, row);
            float dist = distance(pos, center) / distance(float2(0.0, 0.0), center);
            t = (1.0 - dist) * maxStartTime;
        }
            break;
        case 10:  // random
        {
            float cellIndex = float(row * numCols + col);
            float rand = random11(float2(cellIndex, seed), seed);
            t = rand * maxStartTime;
        }
            break;
        default:  // leftToRight
            t = float(col) / max(1.0, float(numCols - 1)) * maxStartTime;
            break;
    }

    return t;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                                texture2d<float> inputTexture [[texture(0)]],
                                constant Uniforms &u [[buffer(0)]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    // Flip Y coordinate to fix texture orientation
    float2 uv = float2(in.texCoord.x, 1.0 - in.texCoord.y);

    float texW = float(inputTexture.get_width());
    float texH = float(inputTexture.get_height());
    float cellW = u.gridSize.x;
    float cellH = u.gridSize.y;

    float numCols = texW / cellW;
    float numRows = texH / cellH;

    // Get cell coordinates
    float cellCol = floor(uv.x * numCols);
    float cellRow = floor(uv.y * numRows);

    // Column and row indices
    int col = int(cellCol);
    int row = int(cellRow);

    // Cell bounds in UV space
    float cellMinU = cellCol / numCols;
    float cellMaxU = (cellCol + 1.0) / numCols;
    float cellMinV = cellRow / numRows;
    float cellMaxV = (cellRow + 1.0) / numRows;

    // Cell center
    float cellCenterU = (cellMinU + cellMaxU) * 0.5;
    float cellCenterV = (cellMinV + cellMaxV) * 0.5;

    // Cell animation duration
    float cellAnimDuration = u.cellDuration;

    // Calculate max start time
    float maxStartTime = u.duration - cellAnimDuration;

    // Calculate cell start time based on direction
    float startTime = calculateStartTime(u.direction, col, row, int(numCols), int(numRows), maxStartTime, u.randomSeed);

    // Cell end time
    float endTime = startTime + cellAnimDuration;

    // If animation hasn't reached this cell yet, show original
    if (u.time < startTime) {
        return inputTexture.sample(s, uv);
    }

    // If this cell has completed animation, return transparent
    if (u.time >= endTime) {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    // Animation progress (0 to 1)
    float progress = (u.time - startTime) / cellAnimDuration;
    progress = clamp(progress, 0.0, 1.0);

    // Scale from 1.0 to 0.0 (cell shrinks from center)
    float scale = 1.0 - progress;

    // Prevent division by zero
    scale = max(scale, 0.01);

    // Calculate local UV within cell (0 to 1)
    float localU = (uv.x - cellMinU) / (cellMaxU - cellMinU);
    float localV = (uv.y - cellMinV) / (cellMaxV - cellMinV);

    // Scale from center
    float scaledLocalU = (localU - 0.5) / scale + 0.5;
    float scaledLocalV = (localV - 0.5) / scale + 0.5;

    // If after scaling, the pixel is outside the cell bounds, return transparent
    if (scaledLocalU < 0.0 || scaledLocalU > 1.0 || scaledLocalV < 0.0 || scaledLocalV > 1.0) {
        return float4(0.0, 0.0, 0.0, 0.0);
    }

    // Convert back to texture UV
    float sampleU = cellMinU + scaledLocalU * (cellMaxU - cellMinU);
    float sampleV = cellMinV + scaledLocalV * (cellMaxV - cellMinV);

    return inputTexture.sample(s, float2(sampleU, sampleV));
}
