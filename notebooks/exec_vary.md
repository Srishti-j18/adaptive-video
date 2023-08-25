## Execute experiment with varying bit rate (mobile user)

Finally, you can try to experience adaptive video as a mobile user!


Repeat the experiment, but instead of setting a constant data rate on the router, you can let it play back a "trace" file with e.g. 


```bash
bash rate-vary.sh ~/Dataset_1/Dataset/Ferry/Ferry5.csv 0.1
```

where the first argument is the path to a trace file, and the second argument is a scaling factor greater than 0 but less than 1. (The smaller the scaling factor, the lower the network quality while still preserving the trace dynamics.)


The following figure shows the "dynamics" (throughput in Mbps against time) for each of the traces:

![](https://witestlab.poly.edu/blog/content/images/2022/04/nyc-traces.png)

For some traces, the throughput is always more than enough to steam the video at the highest quality level. For the traces where the throughput is *not* sufficient to stream continuously at the highest quality level, a good decision policy should still be able to smooth over the variation in network quality and deliver high quality video without rebuffering.

While playing back a trace on the "router", on the client ("romeo"), start the DASH player with the "basic" adaptation policy:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d
```

Leave this running for a while. Then, stop the video client on "romeo" with Ctrl+C.

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

Then, you can repeat the data analysis steps as before.