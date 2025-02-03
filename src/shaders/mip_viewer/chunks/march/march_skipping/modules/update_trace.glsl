    
trace.distance = cell.exit_distance;
trace.position = camera.position + ray.direction * trace.distance; 
trace.intersected = cell.intersected;
trace.terminated = trace.distance > ray.end_distance;
