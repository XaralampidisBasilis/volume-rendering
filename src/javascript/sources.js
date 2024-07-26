export default [     
    
    // NIFTI    
    {
        name: 'volumeNifti',
        type: 'niftiFile',
        path: 'nifti/colon/volume.nii.gz'
    },
    {
        name: 'maskNifti',
        type: 'niftiFile',
        path: 'nifti/colon/mask.nii.gz'
    },    

    // Colormaps
    {
        name: 'colormaps',
        type: 'texture',
        path: 'textures/colormaps/colormaps.png'
    },

    // Noisemaps  
    {
        name: 'blue256Noisemap',
        type: 'texture',
        path: 'textures/noisemaps/blue_256.png'
    },   
    // {
    //     name: 'white256Noisemap',
    //     type: 'texture',
    //     path: 'textures/noisemaps/white_256.png'
    // },
    // {
    //     name: 'white512Noisemap',
    //     type: 'texture',
    //     path: 'textures/noisemaps/white_512.png'
    // },   
]