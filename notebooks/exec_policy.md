## Compare adaptive video policies 

For this section, you will need an SSH session on the "router" node and one on the "romeo" node.

As in the previous experiment, in this experiment we will use a constant bit rate, with a brief interruption. However, we will compare the way two video adaptation policies react to this interruption - we'll compare a *rate based policy* (`basic`) and a *buffer based policy* (`netflix`) under identical settings (similar "high" network rate, "low" data rate, similar duration of the "high" data rate before the interruption, and and similar duration of the "interruption").


#### Rate-based vs. buffer-based policies

The basic rate adaptation policy (`basic`) chooses a video rate based on the observed download rate. It keeps track of the average download time for recent segments, and calculates a running average. 

If the download rate exceeds the current video rate by some threshold, it may increase the video rate. If the download rate is lower than the current video rate, it decreases the video rate to ensure smooth playback. 

You can see the source code for the `basic` policy here:   [basic_dash2.py](../AStream/dist/client/adaptation/basic_dash2.py)

The buffer-based policy (`netflix`) adapts the video rate based on the current buffer occupancy, rather than the current download rate. When there are many segments already buffered, it can increase the video rate; if the buffer occupancy is low and the client is at risk of rebuffering, it must decrease the video rate.

You can see the source code for the `netflix` policy here:   [netflix_dash.py](../AStream/dist/client/adaptation/netflix_dash.py). This policy is based on the paper:

> Te-Yuan Huang, Ramesh Johari, and Nick McKeown. 2013. Downton abbey without the hiccups: buffer-based rate adaptation for HTTP video streaming. In Proceedings of the 2013 ACM SIGCOMM workshop on Future human-centric multimedia networking (FhMN '13). Association for Computing Machinery, New York, NY, USA, 9–14. https://doi.org/10.1145/2491172.2491179

The policy defines two buffer occupancy thresholds: reservoir (defaults to 10%) and cushion (defaults to 90%). If the buffer occupancy is below the reservoir threshold, it selects the minimum video rate to fill the buffer quickly. If the buffer is within the reservoir and cushion range, it selects a video rate using a rate map function that maps buffer occupancy to video rate according to some increasing function. If the buffer occupancy exceeds the cushion threshold, it selects the maximum video rate.

The behavior of each policy is parameterized by the settings defined in the code base at: [config_dash.py](../AStream/dist/client/config_dash.py). 

Key factors defined here for the rate based ("basic") policy include:

* `BASIC_THRESHOLD` - the maximum number of segments to store in the buffer in the rate based ("basic") policy.
* `BASIC_UPPER_THRESHOLD` - to avoid oscillations, in the rate based ("basic") policy, the video rate increases or decreases only if it is different from the download rate by at least this factor.
* `BASIC_DELTA_COUNT` - the number of segments' download rate to include in the moving average of network download rate. The smaller this number, the more reactive the client is to (potentially transient!) changes in network rate.


Key factors defined here for the buffer based ("netflix") policy include:

* `NETFLIX_RESERVOIR` - the value of the "reservoir" described above, as a fraction of total buffer size.
* `NETFLIX_CUSHION` - the value of the "cushion" described above, as a fraction of total buffer size.
* `NETFLIX_BUFFER_SIZE` - the maximum number of segments to store in the buffer in the buffer based ("netflix") policy.
* `NETFLIX_INITIAL_BUFFER` and `NETFLIX_INITIAL_FACTOR` - these define the behavior of the policy in the initial stage, which is a bit different than the approach described above.

#### Execute the experiment for the rate based policy

On the "router", we will configure the following "sequence" of network rates - 

* 1000 Kbits/second for 100 seconds
* 350 Kbits/second for another 75 seconds
* 2000 Kbits/second for another 125 seconds

and while this is ongoing, we will run a DASH client with the rate based policy. After 300 seconds, we will stop the DASH client.

To realize this sequence of network rates, on the router, run

```bash
bash rate-set.sh 1000Kbit
echo "Start the DASH client"
sleep 100
bash rate-set.sh 350Kbit
sleep 75
bash rate-set.sh 2000Kbit
sleep 125
echo "Stop the DASH client"
```

On the client ("romeo"), immediately start the DASH player with the "basic" adaptation policy:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://juliet/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d
```

Let the DASH player run for 300 seconds, then stop the video client on "romeo" with Ctrl+C.

Copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_last.csv` with


```bash
cp $(ls -t1  ~/ASTREAM_LOGS/DASH_BUFFER_LOG_*  | head -n 1 ) ~/ASTREAM_LOGS/DASH_BUFFER_LOG-last.csv
```

Also reconstruct the video that was delivered to the client. Use

```bash
suffix=$(ls -lt | grep "TEMP_" | head -n 1 | cut -f2 -d"_")
cd ~/TEMP_$suffix
rm -f ~/BigBuckBunny.mp4 # if it exists
cat BigBuckBunny_4s_init.mp4 $(ls -vx BigBuckBunny_*.m4s) > BigBuckBunny_tmp.mp4
ffmpeg -i  BigBuckBunny_tmp.mp4 -c copy ~/BigBuckBunny.mp4
```

to combine the video segments into a `BigBuckBunny.mp4` file in your home directory.


Repeat the data analysis steps as before. Save the figures and the reconstructed video for the rate based policy, so that after completing the experiment in the next section with the buffer based policy, you can compare their behavior.


### Execute the experiment for the buffer based policy

We will now repeat the same experiment for the buffer based policy. 

On the router, run

```bash
bash rate-set.sh 1000Kbit
echo "Start the DASH client"
sleep 100
bash rate-set.sh 350Kbit
sleep 75
bash rate-set.sh 2000Kbit
sleep 125
echo "Stop the DASH client"
```

Then, on the client ("romeo"), start the DASH player with the "netflix" adaptation policy:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://juliet/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'netflix' -d
```

Let the DASH player run for 300 seconds, then stop the video client on "romeo" with Ctrl+C.

Copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_last.csv` with


```bash
cp $(ls -t1  ~/ASTREAM_LOGS/DASH_BUFFER_LOG_*  | head -n 1 ) ~/ASTREAM_LOGS/DASH_BUFFER_LOG-last.csv
```

Also reconstruct the video that was delivered to the client. Use

```bash
suffix=$(ls -lt | grep "TEMP_" | head -n 1 | cut -f2 -d"_")
cd ~/TEMP_$suffix
rm -f ~/BigBuckBunny.mp4 # if it exists
cat BigBuckBunny_4s_init.mp4 $(ls -vx BigBuckBunny_*.m4s) > BigBuckBunny_tmp.mp4
ffmpeg -i  BigBuckBunny_tmp.mp4 -c copy ~/BigBuckBunny.mp4
```

to combine the video segments into a `BigBuckBunny.mp4` file in your home directory.

Repeat the data analysis steps as before. Save the figures and the reconstructed video for the buffer based policy, for comparison with the rate based policy in the previous section.












