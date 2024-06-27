export default [     
    
    // NIFTI    
    {
        name: 'volumeNifti',
        type: 'niftiFile',
        path: 'nifti/heart/volume2.nii.gz'
    },
    {
        name: 'maskNifti',
        type: 'niftiFile',
        path: 'nifti/heart/mask.nii.gz'
    },    

    // Colormaps
    {
        name: 'colormaps',
        type: 'texture',
        path: 'textures/colormaps/colormaps.png'
    },

    // Noisemaps    
    {
        name: 'white256Noisemap',
        type: 'texture',
        path: 'textures/noisemaps/white_256.png'
    },
    {
        name: 'white512Noisemap',
        type: 'texture',
        path: 'textures/noisemaps/white_512.png'
    },    
]