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

A brief explanation of the key variables in this policy follows:

* **Reservoir**: Imagine you have a water tank that supplies water to your house. The "reservoir" in this context is like the water level at the bottom of the tank. It's the minimum amount of water that needs to be there at all times to ensure a steady and uninterrupted water supply. If the reservoir is too low, you might experience water interruptions. Similarly, in video streaming, the reservoir is the minimum amount of video content that must be stored in the buffer to ensure a smooth playback experience. It's like having a small reserve of video data to prevent any pauses or disruptions if there are temporary changes in network conditions.
* **Cushion**: Think of a cushion on a couch. It's a soft layer that provides comfort and support. The "cushion" in this context is like an extra layer of video content stored in the buffer above the reservoir level. It's there to give extra protection against sudden changes. Just as a cushion absorbs some impact, this cushion of video content absorbs any fluctuations in network performance. In video streaming, the cushion is an additional amount of video data stored in the buffer beyond the reservoir level. It's like having a padding of video content that helps maintain a consistent and uninterrupted playback experience, even when there are brief variations in network speed.


Let's get started!

### Execute the experiment for the rate based policy

On the "router", set a constant bit rate of 5000 Kbits/second with 

```bash
bash rate-set.sh 5000Kbit
```

Then, on the client ("romeo"), start the DASH player with the "basic" adaptation policy and start the timer along with:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d
```

 Let the DASH player run for 100 seconds. After this duration, on the "router" node, reduce the network data rate to 350 Kbits/second:

```bash
bash rate-set.sh 350Kbit
```
After  175 second, restore the original data rate.

```bash
bash rate-set.sh 5000Kbit
```

Then, after 300 second, stop the video client on "romeo" with Ctrl+C.

As before, the logs produced by the client will be located inside a directory named `ASTREAM_LOGS` in your home directory on the "romeo" node. Use 

```bash
ls ~/ASTREAM_LOGS
```

to find these. We will copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_last.csv` with


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


With these steps completed, you now have the log file for the "basic" policy experiment.You can repeat the data analysis steps as before.
Before moving the next step ,save the plotted graph of "video rate vs time" and "buffer vs time" .So that you can compare the policies better.
 Similarly, we will proceed with the experiment for the "Netflix" policy.



### Execute the experiment for the buffer based policy

On the "router", set a constant bit rate of 5000 Kbits/second with 

```bash
bash rate-set.sh 5000Kbit
```

Then, on the client ("romeo"), start the DASH player with the "netflix" adaptation policy and start the timer along with:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'netflix' -d
```

 Let the DASH player run for 100 seconds. After this duration, on the "router" node, reduce the network data rate to 350 Kbits/second:

```bash
bash rate-set.sh 350Kbit
```
After  175 second, restore the original data rate.

```bash
bash rate-set.sh 5000Kbit
```

Then, after 300 second, stop the video client on "romeo" with Ctrl+C.

As before, the logs produced by the client will be located inside a directory named `ASTREAM_LOGS` in your home directory on the "romeo" node. Use 

```bash
ls ~/ASTREAM_LOGS
```

to find these. We will copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_last.csv` with


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


You can now proceed to analyze the data obtained from the experiments for the "Basic" and "Netflix" adaptation policies. By comparing the video rate graphs and buffer graphs generated from these experiments, you will be able to observe the differences between the two policies.


### Discussions

After analyzing the video rate vs. time and buffer vs. time graphs for both the "Basic" and "Netflix" adaptation policies, along with the actual video playback, several key observations can be made.

Both policies initially start with increasing video rates as the buffer needs to be filled quickly due to being empty. However, in the rate-based policy, the video rate increases more rapidly compared to the buffer-based policy. In the rate-based policy, once the video rate reaches its maximum value, the video runs smoothly without interruption. On the other hand, in the buffer-based policy, the video rate increases, but small interruptions (not exactly buffering) occur because the video rate has not yet reached its maximum.

During the interruption phase, the differences in behavior between the two policies become more apparent. In the rate-based ("Basic") policy, there is a noticeable decrease in the video rate and buffering events. This is attributed to the policy's focus on adjusting the video rate based on the observed download rate. As the data rate decreases, the policy responds by reducing the buffer occupancy, resulting in buffering. In contrast, the buffer-based ("Netflix") policy experiences no buffering events during interruptions. This is a direct consequence of the policy's adaptation strategy, which relies on the current buffer occupancy rather than the download rate. The buffer-based policy ensures sufficient buffer to accommodate interruptions, leading to smooth and uninterrupted playback.

The buffer-based policy ("Netflix") maintains a consistently higher buffer level throughout the experiment, even during interruptions, where it decreases but not significantly. This is evident from the buffer occupancy graph, which generally remains above the buffer threshold level "reservoir".

Conversely, the rate-based policy ("Basic") exhibits fluctuations in buffer occupancy. It begins with a lower buffer level, and during interruptions, the buffer depletes rapidly, resulting in buffering events and drops in video rate.

* **Video length**:
Both policies were executed for a duration of 300 seconds, yet a notable difference exists in the effective video length delivered to the client.
In the buffer-based policy, the delivered video length is closer to the original full video length (approximately 594 seconds), indicating more stable and continuous playback.

Conversely, in the rate-based policy, the delivered video length slightly exceeds 300 seconds, highlighting that buffering events and reduced buffer size during interruptions led to incomplete video playback.













