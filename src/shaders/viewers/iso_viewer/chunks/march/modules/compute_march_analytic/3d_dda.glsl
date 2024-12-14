void ddaTraversalWithIntersections(
    vec3 start,
    vec3 direction,
    ivec3 gridSize,
    out ivec3 voxel,
    out vec3 intersectionPoint
) {
    // Initialize the voxel coordinates
    voxel = ivec3(floor(start));

    // Determine step direction
    ivec3 step = ivec3(
        direction.x > 0.0 ? 1 : (direction.x < 0.0 ? -1 : 0),
        direction.y > 0.0 ? 1 : (direction.y < 0.0 ? -1 : 0),
        direction.z > 0.0 ? 1 : (direction.z < 0.0 ? -1 : 0)
    );

    // Calculate tMax for each axis
    vec3 nextBoundary = vec3(
        (direction.x > 0.0 ? voxel.x + 1.0 : voxel.x) - start.x,
        (direction.y > 0.0 ? voxel.y + 1.0 : voxel.y) - start.y,
        (direction.z > 0.0 ? voxel.z + 1.0 : voxel.z) - start.z
    );

    vec3 tMax = vec3(
        direction.x != 0.0 ? nextBoundary.x / direction.x : 1e30,
        direction.y != 0.0 ? nextBoundary.y / direction.y : 1e30,
        direction.z != 0.0 ? nextBoundary.z / direction.z : 1e30
    );

    // Calculate tDelta
    vec3 tDelta = vec3(
        direction.x != 0.0 ? abs(1.0 / direction.x) : 1e30,
        direction.y != 0.0 ? abs(1.0 / direction.y) : 1e30,
        direction.z != 0.0 ? abs(1.0 / direction.z) : 1e30
    );

    // Traverse the grid
    for (int i = 0; i < 100; i++) { // Limit to prevent infinite loops
        if (voxel.x < 0 || voxel.y < 0 || voxel.z < 0 ||
            voxel.x >= gridSize.x || voxel.y >= gridSize.y || voxel.z >= gridSize.z) {
            break; // Exit if outside grid bounds
        }

        // Compute the intersection point at the current voxel boundary
        float t = min(tMax.x, min(tMax.y, tMax.z));
        intersectionPoint = start + t * direction;

        // Return the current voxel and intersection point (can collect them in an array instead)
        return;

        // Advance to the next voxel
        if (tMax.x < tMax.y && tMax.x < tMax.z) {
            voxel.x += step.x;
            tMax.x += tDelta.x;
        } else if (tMax.y < tMax.z) {
            voxel.y += step.y;
            tMax.y += tDelta.y;
        } else {
            voxel.z += step.z;
            tMax.z += tDelta.z;
        }
    }

    // If no intersection, set dummy values
    voxel = ivec3(-1, -1, -1);
    intersectionPoint = vec3(0.0);
}
