% Define the size of the kernel
kernelSize = [3, 3, 3];

% Define the standard deviation (sigma) for the Gaussian function
sigma = 2;

% Create a 3D grid of coordinates centered at zero
[x, y, z] = ndgrid(-floor(kernelSize(1)/2):floor(kernelSize(1)/2), ...
                   -floor(kernelSize(2)/2):floor(kernelSize(2)/2), ...
                   -floor(kernelSize(3)/2):floor(kernelSize(3)/2));

% Calculate the Gaussian function
gaussianKernel = exp(-(x.^2 + y.^2 + z.^2) / (2 * sigma^2));

% Normalize the kernel so that the sum of all elements is 1
gaussianKernel = gaussianKernel / sum(gaussianKernel(:));

% Display the kernel
disp(gaussianKernel(:));