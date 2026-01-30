#ifndef Shared_h
#define Shared_h
#include <simd/simd.h>

// Uniforms structure shared between Swift and Metal shaders
typedef struct {
    float time;           // Elapsed animation time in seconds
    simd_float2 gridSize; // Cell size in pixels (width, height)
    float duration;       // Total animation duration in seconds
    float cellDuration;   // Per-cell animation duration in seconds
    int direction;        // Animation direction
    float randomSeed;     // Seed for random ordering
} Uniforms;

#endif /* Shared_h */
