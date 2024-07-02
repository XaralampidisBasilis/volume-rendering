export async function importer(path)
{
    try 
    {
        const module = await import(path)
        return module
    } 
    catch (error) 
    {
        console.error(`Error loading module: ${path}`, error);
        throw error;
    }
}
