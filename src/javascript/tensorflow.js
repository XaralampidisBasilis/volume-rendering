import * as tf from '@tensorflow/tfjs'

console.time('setTensorflow') 

tf.enableProdMode() 
tf.env().set('WEBGL_FORCE_F16_TEXTURES', false) // halves bandwidth on many GPUs
tf.env().set('WEBGL_PACK', true)               // ensure packing is on
tf.env().set('WEBGL_CPU_FORWARD', false)       // be strict about staying on GPU
tf.env().set('WEBGL_VERSION', 2)               // prefer WebGL2 if available
tf.env().set('WEBGL_DELETE_TEXTURE_THRESHOLD', 0)
tf.env().set('WEBGL_FLUSH_THRESHOLD', 1)

await tf.setBackend('webgl')
await tf.ready()

console.timeEnd('setTensorflow') 