cat $1 | gawk '\
       func timeToEpoch(time) {
            year=substr(time,0,4);
            month=substr(time,6,2);
            day=substr(time,9,2);
            hour=substr(time,12,2);
            minute=substr(time, 15,2);
            second=substr(time,18,2);
            return mktime(sprintf("%s %s %s %s %s %s", year, month, day, hour, minute, second), 1);
        }
        { print timeToEpoch($1) }'
