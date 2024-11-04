
// STEPPING_MEAN
/**
 * Sets the trace's stepping size to the average of the minimum and maximum stepping values.
 *
 * This function computes a constant stepping size by taking the mean of the 
 * `raymarch.min_step_scaling` and `raymarch.max_step_scaling` values.
 *
 * @input raymarch.min_step_scaling   : the minimum allowable stepping size (float)
 * @input raymarch.max_step_scaling   : the maximum allowable stepping size (float)
 *
 * @output trace.step_scaling          : the adjusted trace stepping size (float)
 */

// set the stepping size to the mean of the minimum and maximum stepping values.
trace.step_scaling = min(raymarch.min_step_scaling, raymarch.max_step_scaling);
