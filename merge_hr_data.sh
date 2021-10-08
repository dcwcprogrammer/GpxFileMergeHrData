# pre-process heart rate file
heartRates=`grep -A1 -E "<HeartRateBpm>|Time|<Id>" $1 | grep -v "HeartRateBpm|-"`

gawk -F'[<|>]' '\
    func timeToEpoch(time) {
	year=substr(time,0,4);
	month=substr(time,6,2);
	day=substr(time,9,2);
	hour=substr(time,12,2);
	minute=substr(time, 15,2);
	second=substr(time,18,2);
	return mktime(sprintf("%s %s %s %s %s %s", year, month, day, hour, minute, second), 1);
    }

    BEGIN { 
	ENVIRON["TZ"] = "UTC";
    }
    /<Id>/ {
	start = timeToEpoch($3);
    }
    /<Time>/ { 
	epoch = timeToEpoch($3);
	end = epoch;
    }
    /<Value>/ { 
	heartRateAtTime[epoch] = $3;
    }
    # Match first line of gpx file
    FNR < NR && FNR == 1 { 
	# Some heart rate data may be missing 
	# for certain timestamps so estimate
	# heartrate for unkown intermediate
	# times using linear interpolation
	lastValidDate = start
	nextValidDate = start;
	for (i=start + 1; i <= end; i++) {
	    if (!(i in heartRateAtTime)) {
		if (i >= nextValidDate) {
		    j = i + 1;
		    while (!(j in heartRateAtTime)) {
			j = j + 1;
		    }
		    nextValidDate = j;
		}
		stepSize = (heartRateAtTime[nextValidDate] - heartRateAtTime[lastValidDate]) /  (nextValidDate - lastValidDate)
		steps = i - lastValidDate;
		heartRateAtTime[i] = int(heartRateAtTime[lastValidDate] + steps * stepSize);
	    } else {
		lastValidDate = i;
		nextValidDate = i;
	    }
	}
    }
    
    # Send all lines in gpx file to stdout
    # except <extensions> which we append to
    FNR < NR && $0 !~ /<extensions>/ { 
        print $0;
    }    

    # Get epoch time from gpx file
    FNR < NR && /<time>/ { 
        epoch = timeToEpoch($3);
        if (epoch in heartRateAtTime) {
            hr = heartRateAtTime[epoch];
	} else if (epoch < start) {
            hr = heartRateAtTime[start];
        } else {
            hr = heartRateAtTime[end];
        }
    }
    
    # Add HR data
    FNR < NR && /<extensions>/ {
        print $0
        printf "%s\n%s\n%s\n", 
	      "          <gpxtpx:TrackPointExtension>",
	      sprintf("            <gpxtpx:hr>%d</gpxtpx:hr>", hr),
	      "          </gpxtpx:TrackPointExtension>";
    }' <(echo "$heartRates") $2




