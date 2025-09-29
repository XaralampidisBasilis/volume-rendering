import { FileLoader, Loader, Matrix4 } from 'three'
import { Volume } from 'three/examples/jsm/misc/Volume'
import * as nifti from 'nifti-reader-js'

class NIFTILoader extends Loader 
{
    constructor(manager) 
    {
        super(manager)
    }

    load(url, onLoad, onProgress, onError) 
    {
        const scope = this

        const loader = new FileLoader(scope.manager)
        loader.setPath(scope.path)
        loader.setResponseType('arraybuffer')
        loader.setRequestHeader(scope.requestHeader)
        loader.setWithCredentials(scope.withCredentials)
        loader.load(url, function(data) 
        {
            try 
            {
                onLoad(scope.parse(data))
            } 
            catch (error) 
            {
                if (onError) 
                {
                    onError(error)
                }
                else 
                {
                    console.error(error)
                }

                scope.manager.itemError(url)
            }

        }, onProgress, onError)
        
    }

    parse(data) {

        // Parse the NIfTI file using nifti-reader-js
        if ( nifti.isCompressed(data) ) 
        {
            data = nifti.decompress(data)

        }

        if ( !nifti.isNIFTI(data) ) 
        {
            throw new Error('Not a NIfTI file')

        }

        const header = nifti.readHeader(data)
        const image = nifti.readImage(header, data)

        // Prepare the volume
        const volume = new Volume()         
        volume.header = header  // console.log(header.toFormattedString())
        
        // Check for extensions
        if ( nifti.hasExtension(header) ) 
        {
            volume.extension = nifti.readExtensionData(header, data)
        }

        // convert raw data to typed array based on nifti datatype
        if (header.datatypeCode === nifti.NIFTI1.TYPE_UINT8) 
        {
            volume.data = new Uint8Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_INT16) 
        {
            volume.data = new Int16Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_INT32) 
        {
            volume.data = new Int32Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_FLOAT32) 
        {
            volume.data = new Float32Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_FLOAT64) 
        {
            volume.data = new Float64Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_INT8) 
        {
            volume.data = new Int8Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_UINT16) 
        {
            volume.data = new Uint16Array(image)
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_UINT32) 
        {
            volume.data = new Uint32Array(image)
        } 
        else 
        {
            throw new Error('Not recognized NIfTI data type')
        }        
            
        // Compute min and max intensities
        // volume.computeMinMax()
      
        // Dimensions and spacing
        volume.dimensions = [header.dims[1], header.dims[2], header.dims[3]]
        volume.spacing = [header.pixDims[1], header.pixDims[2], header.pixDims[3]]
        volume.xLength = volume.dimensions[0]
        volume.yLength = volume.dimensions[1]
        volume.zLength = volume.dimensions[2]

        // Convert spatial units to meters
        const units = header.getUnitsCodeString(nifti.NIFTI1.SPATIAL_UNITS_MASK & header.xyzt_units)
        const factor = 
        { 
            Meters: 1, 
            Millimeters: 1e-3, 
            Microns: 1e-6 
        }
        volume.spacing = volume.spacing.map((x) => x * (factor[units] || 1))
        volume.spatialUnits = "Meters"

        // Convert spatial units to meters
        // const units = header.getUnitsCodeString(nifti.NIFTI1.TEMPORAL_UNITS_MASK & header.xyzt_units)
        // const factor = { Seconds: 1, Milliseconds: 1e-3, Microseconds: 1e-6 }

        // Compute the physical size
        volume.size = [
            volume.xLength * volume.spacing[0],
			volume.yLength * volume.spacing[1],
			volume.zLength * volume.spacing[2]
        ]

        return volume
    }       
}

export { NIFTILoader }
