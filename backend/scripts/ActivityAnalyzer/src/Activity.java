/**
 * 
 */

/**
 * @author Kirsten Koa
 *
 */
public class Activity implements Comparable {
	
	// type of activity
	private String name;
	
	// speed requirements
	private double minSpeed;
	private double avgSpeed;
	private double maxSpeed;
	private double speedDev; // kind-of like std deviation
	private boolean speedDependent;
	
	// noise requirements
	private double minDb;
	private double avgDb;
	private double maxDb;
	private double noiseDev; 
	private boolean noiseDependent;
	
	// acceleration requirements
	private double minAcc;
	private double avgAcc;
	private double maxAcc;
	private double accDev;
	private boolean accelDependent;
	
	// gyroscope requirements
	private double minGyro;
	private double maxGyro;
	private boolean gyroDependent;
	
	// actual sensor values
	private double speed;
	private double acceleration;
	private double dB;
	private double gyroscope;
	
	
	public Activity(String name, boolean speedDependent, double minSpeed, double avgSpeed,
			double maxSpeed, double speedDev, boolean noiseDependent, double minDb, double avgDb,
			double maxDb, double noiseDev, boolean accelDependent, double minAcc, double avgAcc,
			double maxAcc, double accDev, double speed, double acceleration,
			double dB, boolean gyroDependent, double minGyro, double maxGyro, double gyroscope) {

		this.name = name;
		this.minSpeed = minSpeed;
		this.avgSpeed = avgSpeed;
		this.maxSpeed = maxSpeed;
		this.speedDev = speedDev;
		this.minDb = minDb;
		this.avgDb = avgDb;
		this.maxDb = maxDb;
		this.noiseDev = noiseDev;
		this.minAcc = minAcc;
		this.avgAcc = avgAcc;
		this.maxAcc = maxAcc;
		this.accDev = accDev;
		this.speed = speed;
		this.acceleration = acceleration;
		this.dB = dB;
		this.speedDependent = speedDependent;
		this.accelDependent = accelDependent;
		this.noiseDependent = noiseDependent;
		this.minGyro = minGyro;
		this.maxGyro = maxGyro;
		this.gyroDependent = gyroDependent;
		this.gyroscope = gyroscope;
	}

	/*
	 * Returns a value 0 to 100 representing how probable that this is the activity the user
	 * is doing according to the given data
	 * 
	 * Emphasis on speed then acceleration and noise levels with gyroscope being extra points
	 */
	
	public int getProbability() {
		int probability = 100;
		
		if (speed <= 0) // invalid GPS data
		{
			if (this.name.equals("driving") || this.name.equals("biking"))
				probability = probability - 40;
			// interprets acceleration data
			if (accelDependent && Math.abs(avgAcc - acceleration) > accDev)
			{
				if (acceleration > maxAcc || acceleration < minAcc)
				{
					// activity is not within range so it's unlikely
					probability = probability - 30;
				}
				else if (Math.abs(avgAcc - acceleration) < accDev*1.5)
				{
					probability = probability - 5;
				}
				else if (Math.abs(avgAcc - acceleration) < accDev*2)
				{
					probability = probability - 10;
				}
				else if (Math.abs(avgAcc - acceleration) < accDev*2.5)
				{
					probability = probability - 15;
				}
				else
					probability = probability - 20;
			}
			
			// interprets sound data
			if (noiseDependent && Math.abs(avgDb - dB) > noiseDev)
			{
				if (dB > maxDb || dB < minDb)
				{
					// activity is not within range so it's unlikely
					if ((this.name).equals("talking") || (this.name).equals("shouting"))
					{
						probability = 0;
					}
					
					probability = probability - 30;
				}
				else if (Math.abs(avgDb - dB) < noiseDev*1.5)
				{
					probability = probability - 5;
				}
				else if (Math.abs(avgDb - dB) < noiseDev*2)
				{
					probability = probability - 10;
				}
				else if (Math.abs(avgDb - dB) < noiseDev*2.5)
				{
					probability = probability - 15;
				}
				else
					probability = probability - 20;
			}
			
			// gives extra points if gyroscope data is within range
			if (gyroDependent)
		    {
				if (gyroscope > minGyro && gyroscope < maxGyro)
					probability = probability + 15;
				else if (gyroscope > minGyro)
					probability = probability + 10;
		    }
			
			return probability;
		} // ends if statement
		// interprets speed data

		if (speedDependent && Math.abs(avgSpeed - speed) > speedDev)
		{
			if (speed > maxSpeed || speed < minSpeed)
			{
				// activity is not within range so it's unlikely
				//probability = probability - 40;
				return 0;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*1.5)
			{
				probability = probability - 10;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*2)
			{
				probability = probability - 15;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*2.5)
			{
				probability = probability - 20;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*3)
			{
				probability = probability - 25;
			}
			else
				probability = probability - 30;
		}
		
		// interprets acceleration data
		if (accelDependent && Math.abs(avgAcc - acceleration) > accDev)
		{
			if (acceleration > maxAcc || acceleration < minAcc)
			{
				// activity is not within range so it's unlikely
				probability = probability - 30;
			}
			else if (Math.abs(avgAcc - acceleration) < accDev*1.5)
			{
				probability = probability - 5;
			}
			else if (Math.abs(avgAcc - acceleration) < accDev*2)
			{
				probability = probability - 10;
			}
			else if (Math.abs(avgAcc - acceleration) < accDev*2.5)
			{
				probability = probability - 15;
			}
			else
				probability = probability - 20;
		}
		
		// interprets sound data
		if (noiseDependent && Math.abs(avgDb - dB) > noiseDev)
		{
			if (dB > maxDb || dB < minDb)
			{
				// activity is not within range so it's unlikely
				if ((this.name).equals("talking") || (this.name).equals("shouting"))
				{
					probability = 0;
				}
				
				probability = probability - 30;
			}
			else if (Math.abs(avgDb - dB) < noiseDev*1.5)
			{
				probability = probability - 5;
			}
			else if (Math.abs(avgDb - dB) < noiseDev*2)
			{
				probability = probability - 10;
			}
			else if (Math.abs(avgDb - dB) < noiseDev*2.5)
			{
				probability = probability - 15;
			}
			else
				probability = probability - 20;
		}
		
		// gives extra points if gyroscope data is within range
		if (gyroDependent)
	    {
			if (gyroscope > minGyro && gyroscope < maxGyro)
				probability = probability + 15;
			else if (gyroscope > minGyro)
				probability = probability + 10;
	    }
		
		return probability;
	}

	@Override
	public int compareTo(Object o) {
		return ((Activity) o).getProbability() - this.getProbability();
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return name;
	}

}

/* BEFORE TAKING INTO ACCOUNT THAT GPS DOESN'T WORK INDOORS
 * 		// interprets speed data
/*		if (this.name.equals("sitting") && speed < 0)
		{
			// do nothing
		}
		else 
		if (speedDependent && Math.abs(avgSpeed - speed) > speedDev)
		{
			if (speed > maxSpeed || speed < minSpeed)
			{
				// activity is not within range so it's unlikely
				//probability = probability - 40;
				return 0;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*1.5)
			{
				probability = probability - 10;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*2)
			{
				probability = probability - 15;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*2.5)
			{
				probability = probability - 20;
			}
			else if (Math.abs(avgSpeed - speed) < speedDev*3)
			{
				probability = probability - 25;
			}
			else
				probability = probability - 30;
		}
		
		// interprets acceleration data
		if (accelDependent && Math.abs(avgAcc - acceleration) > accDev)
		{
			if (acceleration > maxAcc || acceleration < minAcc)
			{
				// activity is not within range so it's unlikely
				probability = probability - 30;
			}
			else if (Math.abs(avgAcc - acceleration) < accDev*1.5)
			{
				probability = probability - 5;
			}
			else if (Math.abs(avgAcc - acceleration) < accDev*2)
			{
				probability = probability - 10;
			}
			else if (Math.abs(avgAcc - acceleration) < accDev*2.5)
			{
				probability = probability - 15;
			}
			else
				probability = probability - 20;
		}
		
		// interprets sound data
		if (noiseDependent && Math.abs(avgDb - dB) > noiseDev)
		{
			if (dB > maxDb || dB < minDb)
			{
				// activity is not within range so it's unlikely
				if ((this.name).equals("talking") || (this.name).equals("shouting"))
				{
					probability = 0;
				}
				
				probability = probability - 30;
			}
			else if (Math.abs(avgDb - dB) < noiseDev*1.5)
			{
				probability = probability - 5;
			}
			else if (Math.abs(avgDb - dB) < noiseDev*2)
			{
				probability = probability - 10;
			}
			else if (Math.abs(avgDb - dB) < noiseDev*2.5)
			{
				probability = probability - 15;
			}
			else
				probability = probability - 20;
		}
		
		// gives extra points if gyroscope data is within range
		if (gyroDependent)
	    {
			if (gyroscope > minGyro && gyroscope < maxGyro)
				probability = probability + 15;
			else if (gyroscope > minGyro)
				probability = probability + 10;
	    }
		
		return probability; */
