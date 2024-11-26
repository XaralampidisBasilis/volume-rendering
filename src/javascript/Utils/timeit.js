export default async function timeit(callback, name = 'timeit') 
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