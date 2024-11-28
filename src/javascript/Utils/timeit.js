export function timeit(callback, name = 'timeit') 
{
    console.time(name)
    callback() 
    console.timeEnd(name) 
}

export async function timeitAsync(callback, name = 'timeit') 
{
    console.time(name)
    try 
    {
        return await callback() 
    } 
    finally 
    {
        console.timeEnd(name) 
    }
}