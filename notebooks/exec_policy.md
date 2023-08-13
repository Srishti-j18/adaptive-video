## Execute Constant Bit Rate Experiment with Interruption and Policy Comparison 

For this section, you will need an SSH session on the "router" node and one on the "romeo" node.
This section involves conducting a constant bit rate experiment with interruptions while comparing two adaptation policies: "Basic" and "Netflix." Both policies will be tested under identical bandwidth settings and time durations to facilitate a clear comparison.


Imagine you're watching your favorite online video, and you want it to play smoothly without any pauses, right..? Several policies aim to minimize interruptions and ensure seamless playback. In this experiment, we will execute two policies and observe the differences between them.

#### Basic Policy (Rate Based):

The basic policy for rate adaptation focuses on adjusting the streaming bitrate based on the observed download time and network conditions. It aims to strike a balance between higher video quality and smooth playback.

##### How it Works:
It keeps track of the average download time for recent segments and calculates a running download rate based on recent segment sizes.
If the download rate exceeds a certain threshold (defined as a factor times the current bitrate), it considers increasing the bitrate.
If the download rate is significantly lower than the current bitrate, it decreases the bitrate to ensure smooth playback.
The policy prefers small adjustments to the bitrate based on the observed network conditions.

##### What to Expect:
When running the experiment with the basic policy, you can expect the bitrate to adjust modestly based on the network's ability to download segments. If the network quality is consistently good, the bitrate may gradually increase. If there are fluctuations in network speed, the policy will make careful adjustments to avoid playback disruptions.


#### Netflix Policy (Buffer-Based):

The Netflix policy, inspired by a buffer-based approach, adapts the streaming bitrate based on 
the current buffer occupancy. It aims to maintain a stable buffer while providing the best possible video quality.

Reservoir: Imagine you have a water tank that supplies water to your house. The "reservoir" in this context is like the water level at the bottom of the tank. It's the minimum amount of water that needs to be there at all times to ensure a steady and uninterrupted water supply. If the reservoir is too low, you might experience water interruptions.
Similarly, in video streaming, the reservoir is the minimum amount of video content that must be stored in the buffer to ensure a smooth playback experience. It's like having a small reserve of video data to prevent any pauses or disruptions if there are temporary changes in network conditions.

Cushion: Think of a cushion on a couch. It's a soft layer that provides comfort and support. The "cushion" in this context is like an extra layer of video content stored in the buffer above the reservoir level. It's there to give extra protection against sudden changes. Just as a cushion absorbs some impact, this cushion of video content absorbs any fluctuations in network performance.
In video streaming, the cushion is an additional amount of video data stored in the buffer beyond the reservoir level. It's like having a padding of video content that helps maintain a consistent and uninterrupted playback experience, even when there are brief variations in network speed.

So, in summary:
Reservoir: The minimum amount of video content needed in the buffer for steady playback.
Cushion: Extra video content above the reservoir level to absorb fluctuations and ensure uninterrupted viewing.
These concepts work together to create a buffer-based adaptation approach that aims to provide a seamless video streaming experience regardless of minor changes in network conditions.

##### How it Works:
The policy defines different buffer occupancy thresholds: default reservoir (10%) and cushion (90%).
If the buffer is below the reservoir threshold, it selects the minimum bitrate to fill the buffer quickly.
If the buffer is within the reservoir and cushion range, it uses a linear function to adjust the bitrate based on the rate map, aiming for a smooth streaming experience.
If the buffer exceeds the cushion threshold, it selects the maximum bitrate to utilize the available buffer space efficiently.

##### What to Expect:
Running the experiment with the Netflix policy, you can expect the policy to focus on maintaining a stable buffer. As the buffer fills up, the policy will gradually increase the bitrate to improve video quality. If the buffer is near total capacity, the policy may reduce the bitrate to avoid buffer underflow.

##### Summary:
In summary, the basic policy focuses on adapting the bitrate based on observed download rates to ensure a balance between smooth playback and video quality. The Netflix policy, on the other hand, takes a buffer-based approach, adjusting the bitrate to manage buffer occupancy while delivering the best viewing experience.



Let's get started!

### 1. Execute the experiment for the Basic Policy:

On the "router", set a constant bit rate of 5000 Kbits/second with 

```bash
bash rate-set.sh 5000Kbit
```

Then, on the client ("romeo"), start the DASH player with the "basic" adaptation policy and start the timer along with:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d
```

 Let the DASH player run for 25 seconds. After this duration, on the "router" node, reduce the network data rate to 350 Kbits/second:

```
bash rate-set.sh 350Kbit
```
Allow the DASH player to run for the entire duration of 300 seconds.
When the timer reaches 300 seconds, stop the video client on the "romeo" node by pressing Ctrl+C.

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



### 2. Execute the experiment for the Netflix Policy:

On the "router", set a constant bit rate of 5000 Kbits/second with 

```bash
bash rate-set.sh 5000Kbit
```

Then, on the client ("romeo"), start the DASH player with the "Netflix" adaptation policy and start the timer along with:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'netflix' -d
```

 Let the DASH player run for 25 seconds. After this duration, on the "router" node, reduce the network data rate to 350 Kbits/second:

```
bash rate-set.sh 350Kbit
```
Allow the DASH player to run for the entire duration of 300 seconds.
When the timer reaches 300 seconds, stop the video client on the "romeo" node by pressing Ctrl+C.

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
