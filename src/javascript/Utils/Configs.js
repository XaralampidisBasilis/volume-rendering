import EventEmitter from './EventEmitter'

/**
 * Configs
 * Manages global app state (interpolation, gradients, marching, skipping, toggles).
 */
export default class Configs extends EventEmitter 
{
    static InterpolationMethods = Object.freeze([
        'trilinear',
        'tricubic',
    ])
    static GradientsMethods = Object.freeze([
        'analytic',
        'sobel',
        'bspline',
    ])
    static MarchingMethods = Object.freeze([
        'analytic',
        'approximate',
    ])
    static SkippingMethods = Object.freeze([
        'occupancyMap',
        'isotropicDistanceMap',
        'anisotropicDistanceMap',
        'extendedIsotropicDistanceMap',
        'extendedAnisotropicDistanceMap',
    ])

    constructor() 
    {
        super()

        this.blockSize = 2
        this.downscaleFactor = 0.8
        this.isosurfaceValue = 0.69

        this.interpolationMethod = 'tricubic'
        this.gradientsMethod = 'bspline'
        this.marchingMethod = 'analytic'
        this.skippingMethod = 'isotropicDistanceMap'

        this.bernsteinEnabled = true
        this.skippingEnabled = true
        this.debugEnabled = true
        this.statsEnabled = true
        this.discardingEnabled = true
    }

    set(key, value) 
    {
        if (key === 'interpolationMethod' && !Configs.InterpolationMethods.includes(value)) 
        {
            console.warn(`Invalid InterpolationMethod: "${value}"`)
            return
        }
        if (key === 'gradientsMethod' && !Configs.GradientsMethods.includes(value)) 
        {
            console.warn(`Invalid GradientsMethod: "${value}"`)
            return
        }
        if (key === 'marchingMethod' && !Configs.MarchingMethods.includes(value)) 
        {
            console.warn(`Invalid MarchingMethod: "${value}"`)
            return
        }
        if (key === 'skippingMethod' && !Configs.SkippingMethods.includes(value)) 
        {
            console.warn(`Invalid SkippingMethod: "${value}"`)
            return
        }

        if (key === 'blockSize' && (!Number.isInteger(value) || value <= 0)) 
        {
            console.warn(`blockSize must be a positive integer (got ${value})`)
            return
        }
        if (key === 'downscaleFactor' && (typeof value !== 'number' || value <= 0 || value > 1)) 
        {
            console.warn(`downscaleFactor must be in (0,1] (got ${value})`)
            return
        }
        if (key === 'isosurfaceValue' && (typeof value !== 'number' || value < 0 || value > 1)) 
        {
            console.warn(`isosurfaceValue must be in [0,1] (got ${value})`)
            return
        }
        if (key.endsWith('Enabled') && typeof value !== 'boolean') 
        {
            console.warn(`${key} must be boolean (got ${typeof value})`)
            return
        }

        if (key in this) 
        { 
            const newValue = value
            const oldValue = this[key] 
            this[key] = newValue 

            this.trigger('change', { key, oldValue, newValue }) 
        } 
        else 
        { 
            console.warn(`Unknown config key: ${key}`)
        }
    }

    get(key) 
    {
        return (key in this) ? this[key] : null
    }

    destroy() 
    {
    }
}
