import glsl from 'vite-plugin-glsl'
import path from 'path'
import { defineConfig } from 'vite'

export default ({
    root: 'src/',
    publicDir: '../static/',
    base: './',
    server:
    {
        host: true, // Open to local network and display URL
        open: !('SANDBOX_URL' in process.env || 'CODESANDBOX_HOST' in process.env) // Open if it's not a CodeSandbox
    },
    build:
    {
        outDir: '../dist', // Output in the dist/ folder
        emptyOutDir: true, // Empty the folder first
        sourcemap: true // Add sourcemap
    },
    resolve: 
    {
        alias: {
            '@': path.resolve(__dirname, 'src'),
            '@static': path.resolve(__dirname, 'static'),
            '@textures': path.resolve(__dirname, 'static/textures'),
            '@shaders': path.resolve(__dirname, 'src/shaders'),
        }
    },
    plugins:
    [
        glsl({
            include: '**/*.glsl',  // Include all .glsl files
            root: '**/src/shaders', // Directory for root imports
            warnDuplicatedImports: false, // Warn if the same chunk was imported multiple times
            compress: false,             // Compress output shader code
        })
    ],      
})