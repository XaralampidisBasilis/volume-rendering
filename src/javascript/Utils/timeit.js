export function timeit(name, callback) 
{
    console.time(name)
    callback() 
    console.timeEnd(name) 
}

export async function timeitAsync(name, callback) 
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