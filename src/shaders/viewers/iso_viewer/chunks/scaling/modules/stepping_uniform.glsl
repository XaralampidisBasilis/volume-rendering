
// STEPPING_MEAN
/**
 * Sets the trace's stepping size to the average of the minimum and maximum stepping values.
 *
 * This function computes a constant stepping size by taking the mean of the 
 * `u_raycast.min_stepping` and `u_raycast.max_stepping` values.
 *
 * @input u_raycast.min_stepping   : the minimum allowable stepping size (float)
 * @input u_raycast.max_stepping   : the maximum allowable stepping size (float)
 *
 * @output trace.stepping          : the adjusted trace stepping size (float)
 */

// set the stepping size to the mean of the minimum and maximum stepping values.
trace.stepping = mean(u_raycast.min_stepping, u_raycast.max_stepping);
