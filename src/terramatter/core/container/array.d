module terramatter.core.container.array;

/** 
* Fills array with values `val` up to `size` if it's not 0
* Params:
*   arr = array to fill
*   val = values to fill with
*   size = amount of pos to fill
* Returns: filled array
*/
T[] fill(T)(T[] arr, T val){

    arr = arr.dup;

    for (int i = 0; i < arr.length; i ++) {
        arr[i] = val;
    }

    return arr;
}