syms v_x v_y v_z y z

% Assume that v_x, v_y, and v_z are positive
assume(v_x > 0)
assume(v_y > 0)
assume(v_z > 0)

% Region 1: min is 1/v_x
f1 = 1/v_x;
region1 = int(int(f1, y, 0, 1-v_y/v_x), z, 0, 1-v_z/v_x);
region1 = simplify(region1);
pretty(region1);

% Region 2: min is (1 - y)/v_y
f2 = (1 - y)/v_y;
region2 = int(int(f2, y, 0, 1-v_y/v_x), z, 0, 1-v_z/v_y *(1-v_y));
region2 = simplify(region2);
pretty(region2);

% Region 3: min is (1 - z)/v_z
f3 = (1 - z)/v_z;
region3 = int(int(f3, z, 0, 1-v_z/v_x), y, 0, 1-v_y/v_z *(1-v_z));
region3 = simplify(region3);
pretty(region3);

% Sum the results from all regions
integral_result = simplify(region1 + region2 + region3);

% Display the result
pretty(integral_result);