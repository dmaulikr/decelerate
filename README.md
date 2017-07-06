Driver Analysis Logic in BDMotionManager.m\s\s
\s\s
Trip starts for driverID for routeID\s\s
App retrieves MASTER driver data for routeID\s\s
MASTER driver data is sorted into segments for all ACC and GYRO axis\s\s
-Baseline data is calculated from first 30 seconds of MASTER data\s\s
--Loop through first data values and find sum of absolute values\s\s
--Baseline is absolute value of average (sum/number_of_values) - specified tolerance\s\s
-Remaining MASTER data compared to baseline data to find segments\s\s
--Loop through each item in list\s\s
---If the new value is positive and greater than the +Baseline\s\s
----Start a new segment\s\s
----Loop through next items starting from current item\s\s
-----If item is also positive and greater than the +Baseline\s\s
------Add it to the segment\s\s
-----Otherwise, finalze the segment\s\s
------Calculate the peak value of the segment and the segment type\s\s
------Store the new segment in the segmentArray\s\s
------End the loop, parent loop contines with last item to find appropriate segment\s\s
---If the new value is negative and less than the -Baseline\s\s
----Same as above, but for negative values\s\s
---If the new value is within the Baseline range\s\s
----Same as above, but for all other contents\s\s
MotionListener is started\s\s
As new motion events are received, MotionListener compares them to the master data for all ACC and GYRO axis\s\s
-If no current segment\s\s
--Assume the closest item is the first segment\s\s
--Stores currentSegment\s\s
-App loops through each segment looking for closest item based on GPS, starting from current segment\s\s
--App loops through each item in each segment to find the item with the closest distance\s\s
--If closest item in next segment is closer\s\s
---Replace currentItem and currentSegment\s\s
--if closest item in next segment is further away\s\s
---Break the loop\s\s
---Next parent loop starts from currentSegment\s\s
-If new event value is greater than peak value from current segment\s\s
--Show an alert \s\s
--Send the new event data to the server\s\s
