import java.util.Arrays;

/**
 * 
 */

/**
 * @author Kirsten Koa
 *
 */
public class ActivityAnalyzer {

	private static final int NUM_OF_SENSOR_DATA = 16;
	private static final int NUM_OF_ACTIVITIES = 8; // sitting, talking, shouting, walking, jogging, running, biking, driving
	private static final boolean DEBUG = false;
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		// checks if the correct number of arguments were passed in
		if (args.length != NUM_OF_SENSOR_DATA) 
		{
			// print error message
			throw new IllegalArgumentException("Incorrect number of arguments.");
		}
		
		/* 
		 * parses arguments from args 
		 */
		
		// previous GPS data
		double prevLat = Double.parseDouble(args[0]);
		double prevLong = Double.parseDouble(args[1]);
		double prevSpeed = Double.parseDouble(args[2]); // in meters per second
		String prevTimeStampGPS = args[3];

		// current GPS data
		double currLat = Double.parseDouble(args[4]);
		double currLong = Double.parseDouble(args[5]);
		double currSpeed = Double.parseDouble(args[6]);
		String currTimeStampGPS = args[7];

		// accelerometer data
		double acc_x = Double.parseDouble(args[8]);
		double acc_y = Double.parseDouble(args[9]);
		double acc_z = Double.parseDouble(args[10]);

		// gyroscope data
		double gyr_x = Double.parseDouble(args[11]);
		double gyr_y = Double.parseDouble(args[12]);
		double gyr_z = Double.parseDouble(args[13]);

		// microphone data
		double avgDB = Double.parseDouble(args[14]);
		double peakDB = Double.parseDouble(args[15]);

		/*
		 *  convert sensor data 
		 */
		
		// get user's current speed in mph
		double speed = metersSecToMPH(currSpeed);
		
		/* have Peter send in the avg magnitude at each instance instead */
		
		// get user's current acceleration in g's
		double accelInGs = getMagnitude(acc_x,acc_y,acc_z);
		
		// convert acceleration to m/s^2
		double acceleration = Math.abs(accelInGs * 9.8);
	
		// gets gyroscope magnitude
		double gyroMag = getMagnitude(gyr_x, gyr_y, gyr_z);
		
		avgDB = Math.abs(avgDB);
		
		if (DEBUG)
		{
			System.out.println("Speed = " + speed);
			System.out.println("Acceleration = " + acceleration);
			System.out.println("Gyroscope Magnitude = " + gyroMag);
		}
		
		/* 
		 * Data we have so far:
		 *   speed (in MPH)
		 *   acceleration (in m/s^2)
		 *   avgDB
		 *   gyroMag (gyroscope data's magnitude)
		 */
		
		 Activity[] activitiesArray = classify(speed, acceleration, avgDB, gyroMag);
		 
		 /*
		  * creates a String array based on the activities
		  */
		 String[] arrayToSend = new String[activitiesArray.length];
		 for (int i = 0; i < activitiesArray.length; i++)
		 {
			 arrayToSend[i] = activitiesArray[i].toString();
		 }
		 
		 /*
		  * Print out ArrayToSend
		  */
		
		 for (int i = 0; i < 4; i++)
		 {
			 System.out.println(arrayToSend[i]);
		 }
		 
	} // ends main() method

	private static double metersSecToMPH(double meters) {
		// converts m/s to km/hr
		double kmPerHr = (meters * 60 * 60) / 1000;
		return kmPerHr * 0.621;
	}
	
	private static double getMagnitude(double x, double y, double z)
	{
		return Math.sqrt(x*x + y*y + z*z); 
	}
	
	/*
	 * Returns a list of activities in order of which is most probable
	 */
	
	private static Activity[] classify(double speed, double acceleration, double dB, double gyroscope)
	{
		Activity[] array = new Activity[NUM_OF_ACTIVITIES];
		
		/*
		 * creates new activities which contain a probability that the user is now doing it
		 * 
		 * Format of information (constructor): 
		 * 
		 * Activity(String name, boolean speedDependent, double minSpeed, double avgSpeed,
			double maxSpeed, double speedDev, boolean noiseDependent, double minDb, double avgDb,
			double maxDb, double noiseDev, boolean accelDependent, double minAcc, double avgAcc,
			double maxAcc, double accDev, double speed, double acceleration,
			double dB, boolean gyroDependent, double minGyro, double maxGyro, double gyroscope)
		 */
		
		array[0] = new Activity("sitting", true, 0, 0, 0.5, 0.1, // speed
				false, -1, -1, -1, -1,  					// db
				true, 0, 0.3, 0.8, 0.15, 					// accelerometer UPDATED
				speed, acceleration, dB,
				true, 0, 0.65, gyroscope);					// gyroscope

		array[1] = new Activity("talking", false, -1, -1, -1, -1,
						true, 25, 30, 50, 2, // edited these drastically due to sensor data collection
						false, -1, -1, -1, -1, 
						speed, acceleration, dB,
						false, -1, -1, -1);
		
		array[2] = new Activity("shouting", false, -1, -1, -1, -1,
						true, 50, 60, 75, 2, 
						false, -1, -1, -1, -1, 
						speed, acceleration, dB,
						false, -1, -1, -1);
		
		array[3] = new Activity("walking", true, 0.3, 2.7, 5, 1, 
				false, -1, -1, -1, -1, 
				true, 1.3, 2.3, 8, 2, // UPDATED
				speed, acceleration, dB,
				true, 0.3, 3.5, gyroscope);  // confirmed by second set of data
											// changed due to confusion in units (didn't mul by 9.8)
		
		array[4] = new Activity("jogging", true, 4.5, 105.5, 7, 0.7, 
				false, -1, -1, -1, -1, 
				true, 12, 100, 22, 4, 		// put in ridiculous values.. so it'll never go here.
				speed, acceleration, dB,  // UPDATED 2/16 taking out jogging
				true, 2, 8.5, gyroscope);
		
		array[5] = new Activity("running", true, 4.5, 7, 13, 5, 
				false, -1, -1, -1, -1, 
				true, 12, 15, 23, 5, // acceleration
				speed, acceleration, dB, // UPDATED 2/13 12:12PM
				true, 2, 13, gyroscope);
		
		array[6] = new Activity("biking", true, -1, -1, -1, -1, 
				false, -1, -1, -1, -1, 
				true, 0, 0, -1, -1, 
				speed, acceleration, dB,
				false, -1, -1, -1); // NEED TO COLLECT DATA FOR THIS STILL
		
		array[7] = new Activity("driving", true, 0, 40, 110, 25, 
				false, -1, -1, -1, -1, 
				true, 0.25, 0.8, 2, 0.5, 
				speed, acceleration, dB,
				true, 0, 1, gyroscope);
		
		Arrays.sort(array);
		
		return array;
	}
	
	public static String testClassify(double speed, double acceleration, double dB, double gyroscope)
	{
		Activity[] array = new Activity[NUM_OF_ACTIVITIES];
		
		/*
		 * creates new activities which contain a probability that the user is now doing it
		 * 
		 * Format of information (constructor): 
		 * 
		 * Activity(String name, boolean speedDependent, double minSpeed, double avgSpeed,
			double maxSpeed, double speedDev, boolean noiseDependent, double minDb, double avgDb,
			double maxDb, double noiseDev, boolean accelDependent, double minAcc, double avgAcc,
			double maxAcc, double accDev, double speed, double acceleration,
			double dB, boolean gyroDependent, double minGyro, double maxGyro, double gyroscope)
		 */
		
		array[0] = new Activity("sitting", true, 0, 0, 0.5, 0.1, // speed
						false, -1, -1, -1, -1,  					// db
						true, 0, 0.3, 0.8, 0.15, 					// accelerometer UPDATED
						speed, acceleration, dB,
						true, 0, 0.65, gyroscope);					// gyroscope
		
		array[1] = new Activity("talking", false, -1, -1, -1, -1,
						true, 25, 30, 50, 2, // edited these drastically due to sensor data collection
						false, -1, -1, -1, -1, 
						speed, acceleration, dB,
						false, -1, -1, -1);
		
		array[2] = new Activity("shouting", false, -1, -1, -1, -1,
						true, 50, 60, 75, 2, 
						false, -1, -1, -1, -1, 
						speed, acceleration, dB,
						false, -1, -1, -1);
		
		array[3] = new Activity("walking", true, 0.3, 2.7, 5, 1, 
				false, -1, -1, -1, -1, 
				true, 1.3, 2.3, 8, 2, // UPDATED
				speed, acceleration, dB,
				true, 0.3, 3.5, gyroscope);  // confirmed by second set of data
											// changed due to confusion in units (didn't mul by 9.8)
		
		array[4] = new Activity("jogging", true, 4.5, 105.5, 7, 0.7, 
				false, -1, -1, -1, -1, 
				true, 12, 100, 22, 4, 		
				speed, acceleration, dB,  // UPDATED 2/16 taking out jogging
				true, 2, 8.5, gyroscope);

		array[5] = new Activity("running", true, 4.5, 7, 13, 5, 
				false, -1, -1, -1, -1, 
				true, 12, 15, 23, 5, 
				speed, acceleration, dB, // UPDATED 2/13 12:12PM
				true, 2, 13, gyroscope);
		
		array[6] = new Activity("biking", true, -1, -1, -1, -1, 
				false, -1, -1, -1, -1, 
				true, 0, 0, -1, -1, 
				speed, acceleration, dB,
				false, -1, -1, -1); // NEED TO COLLECT DATA FOR THIS STILL
	
		array[7] = new Activity("driving", true, 0, 40, 110, 25, 
				false, -1, -1, -1, -1, 
				true, 0.25, 0.8, 2, 0.5, 
				speed, acceleration, dB,
				true, 0, 1, gyroscope);
		
		Arrays.sort(array);
		
		return array[0].toString();
	}
}
/*
 * distFrom(double lat1, double lng1, double lat2, double lng2)
 * 
 * Params: lat1, lng1 - initial coordinates
 * 			lat2, lng2 - ending coordinates
 * Returns: distance between both points in meters
 */
/*	private static double distFrom(double lat1, double lng1, double lat2, double lng2) {
	double earthRadius = 3958.75;
    double dLat = Math.toRadians(lat2-lat1);
    double dLng = Math.toRadians(lng2-lng1);
    double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
               Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
               Math.sin(dLng/2) * Math.sin(dLng/2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    double dist = earthRadius * c;

    int meterConversion = 1609;

    return new Double(dist * meterConversion).doubleValue();
} // ends distFrom */

/*
 * getSpeed(double distance, double timeStamp1, double timeStamp2)
 * Params: distance in meters
 * 			timeStamp1 in seconds
 * 			timeStamp2 in seconds
 * Returns: speed in km/hr ??? double check units of timeStamps
 */
/*	private static double getSpeed(double distance, double timeStamp1, double timeStamp2) {
	// converts seconds to hours 
	double hoursEllapsed = (timeStamp2 - timeStamp1) / (60 * 60);
	
	return distance / (1000 * (hoursEllapsed));
} // ends getSpeed */

/*
 * movement(double speed) 
 * 
 * Determines how fast the user is moving and groups it 
 * Params: speed of the user
 * 
 * Returns: 0 - little to no movement
 * 			1 - slow walking
 * 			2 - walking to slow jog
 * 			3 - jog to running
 * 			4 - running to on wheels
 * 			5 - on wheels to driving
 */

/*private static int movement(double speed) {
	double spd = Math.abs(speed);
	if (spd < 1) // moving < 1km/hr or .6 mph 
	  return 0;
	else if (spd < 5) // moving < 5km/hr or 3 mph 
		return 1;
	else if (spd < 10) // moving < 10km/hr or 6 mph (10' mile time) 
		return 2;
	else if (spd < 20) // moving < 29km/hr or 12 mph (5' mile time) 
		return 3;
	else if (spd < 30) // moving < 30km/hr or 18 mph 
		return 4;
	else // moving > 18 mph
		return 5;
} */