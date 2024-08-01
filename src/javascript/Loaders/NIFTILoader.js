import { FileLoader, Loader, Matrix4, Vector3 } from 'three';
import { Volume } from 'three/examples/jsm/misc/Volume';
import * as nifti from 'nifti-reader-js';

class NIFTILoader extends Loader {

    constructor(manager) 
    {
        super(manager);
    }

    load(url, onLoad, onProgress, onError) 
    {
        const scope = this;

        const loader = new FileLoader(scope.manager);
        loader.setPath(scope.path);
        loader.setResponseType('arraybuffer');
        loader.setRequestHeader(scope.requestHeader);
        loader.setWithCredentials(scope.withCredentials);
        loader.load(url, function(data) {

            try 
            {
                onLoad(scope.parse(data));
            } 
            catch (e) 
            {
                if (onError) 
                    onError(e);
                else 
                    console.error(e);


                scope.manager.itemError(url);
            }

        }, onProgress, onError);
        
    }

    parse(data) {

        // Parse the NIfTI file using nifti-reader-js
        if ( nifti.isCompressed(data) ) {

            data = nifti.decompress(data);

        }

        if ( !nifti.isNIFTI(data) ) {

            throw new Error('Not a NIfTI file');

        }

        const header = nifti.readHeader(data);
        const image = nifti.readImage(header, data);

        // Prepare the volume
        const volume = new Volume();         
        volume.header = header; 
        // console.log(header.toFormattedString());
        
        // Check for extensions
        if ( nifti.hasExtension(header) ) 
        {
            volume.extension = nifti.readExtensionData(header, data);
        }

        // convert raw data to typed array based on nifti datatype
        if (header.datatypeCode === nifti.NIFTI1.TYPE_UINT8) {
            volume.data = new Uint8Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_INT16) {
            volume.data = new Int16Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_INT32) {
            volume.data = new Int32Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_FLOAT32) {
            volume.data = new Float32Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_FLOAT64) {
            volume.data = new Float64Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_INT8) {
            volume.data = new Int8Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_UINT16) {
            volume.data = new Uint16Array(image);
        } 
        else if (header.datatypeCode === nifti.NIFTI1.TYPE_UINT32) {
            volume.data = new Uint32Array(image);
        } 
        else {
            throw new Error('Not recognized NIfTI data type');
        }        

        // Remove negative values
        // for(let i = 0; i < volume.data.length; i++)
        // {
        //     volume.data[i] = Math.abs(volume.data[i])
        // }
            
        // Compute min and max intensities
        [volume.windowLow, volume.windowHigh] = volume.computeMinMax();
      
        // Dimensions and spacing
        volume.dimensions = [header.dims[1], header.dims[2], header.dims[3]];
        volume.spacing = [header.pixDims[1], header.pixDims[2], header.pixDims[3]];
        volume.xLength = volume.dimensions[0];
        volume.yLength = volume.dimensions[1];
        volume.zLength = volume.dimensions[2];

        // Convert spatial units to meters
        const units = header.getUnitsCodeString(nifti.NIFTI1.SPATIAL_UNITS_MASK & header.xyzt_units)
        const factor = { 
            Meters: 1, 
            Millimeters: 1e-3, 
            Microns: 1e-6 
        }
        volume.spacing = volume.spacing.map((x) => x * (factor[units] || 1))
        volume.spatialUnits = "Meters"

        // Convert temporal units to meters
        // const units = header.getUnitsCodeString(nifti.NIFTI1.TEMPORAL_UNITS_MASK & header.xyzt_units)
        // const factor = { Seconds: 1, Milliseconds: 1e-3, Microseconds: 1e-6 }

        // Compute the physical size
        volume.size = [
            volume.xLength * volume.spacing[0],
			volume.yLength * volume.spacing[1],
			volume.zLength * volume.spacing[2]
        ]

        // Calculate axis order and create the IJK to RAS matrix
        const affine = new Matrix4();
        const V = header.affine;

        affine.set(
            V[0][0], V[0][1], V[0][2], V[0][3],
            V[1][0], V[1][1], V[1][2], V[1][3],
            V[2][0], V[2][1], V[2][2], V[2][3],
            0, 0, 0, 1
        );

        volume.matrix = affine;
        volume.inverseMatrix = new Matrix4().copy(volume.matrix).invert();

        volume.getDataUint8 = function() 
        {
            const range = this.max - this.min;
            const dataUint8 = new Uint8Array(this.data.length);

            if (range > 0)
            {
                for (let i=0; i < dataUint8.length; i++)
                {
                    dataUint8[i] = Math.round(((this.data[i] - this.min) / range ) * 255);
                }                
            }
            else 
            {
                dataUint8.fill(255)
            }
           
            return dataUint8;
        }

        return volume;
    }       
}

export { NIFTILoader };
