export function throttleByDelay(callback, delay) 
{
    let wait = false

    return (...args) => {

        if (wait) return
    
        callback.apply(this, args) // Ensures the correct `this` context is used
        
        wait = true

        setTimeout(() => {

            wait = false

        }, delay)

    }
}

export function throttleByCalls(callback, calls) {

    let count = 0

    return function (...args) {

        count++

        if (count >= calls) {

            callback.apply(this, args)
            count = 0 // Reset the call count after executing the callback
        }
    }

}

export function throttleByTimestamp(callback, delay) 
{
    let last = 0

    return function (...args) {

        const now = Date.now()
        
        if (now - last >= delay) {

            last = now

            callback.apply(this, args)
        }
    }
}