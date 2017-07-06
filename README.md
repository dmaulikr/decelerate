Driver Analysis Logic in BDMotionManager.m

Trip starts for driverID for routeID
App retrieves MASTER driver data for routeID
MASTER driver data is sorted into segments for all ACC and GYRO axis
*Baseline data is calculated from first 30 seconds of MASTER data
**Loop through first data values and find sum of absolute values
**Baseline is absolute value of average (sum/number_of_values) * specified tolerance
*Remaining MASTER data compared to baseline data to find segments
**Loop through each item in list
***If the new value is positive and greater than the +Baseline
****Start a new segment
****Loop through next items starting from current item
*****If item is also positive and greater than the +Baseline
******Add it to the segment
*****Otherwise, finalze the segment
******Calculate the peak value of the segment and the segment type
******Store the new segment in the segmentArray
******End the loop, parent loop contines with last item to find appropriate segment
***If the new value is negative and less than the -Baseline
****Same as above, but for negative values
***If the new value is within the Baseline range
****Same as above, but for all other contents
MotionListener is started
As new motion events are received, MotionListener compares them to the master data for all ACC and GYRO axis
*If no current segment
**Assume the closest item is the first segment
**Stores currentSegment
*App loops through each segment looking for closest item based on GPS, starting from current segment
**App loops through each item in each segment to find the item with the closest distance
**If closest item in next segment is closer
***Replace currentItem and currentSegment
**if closest item in next segment is further away
***Break the loop
***Next parent loop starts from currentSegment
*If new event value is greater than peak value from current segment
**Show an alert 
**Send the new event data to the server