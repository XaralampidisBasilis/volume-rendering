export default [     
    
    // Colormaps
    {
        name: 'colorMaps',
        type: 'texture',
        path: 'textures/colormaps/colormaps.png',
    },

    // NIFTI    
    {
        name: 'intensityMap',
        type: 'niftiFile',
        path: 'nifti/cardiac/ct_train_1002_image.nii.gz',
    }, 

    {
        name: 'binaryMap',
        type: 'niftiFile',
        path: 'nifti/cardiac/ct_train_1002_label.nii.gz',
    }, 
]