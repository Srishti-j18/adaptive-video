## Execute constant bit rate experiment with interruption

For this section, you will need an SSH session on the "router" node and one on the "romeo" node.

In the experiment with constant bit rate, you may not have experienced any rebuffering. 

To see how the video client works when there is a temporary interruption in the network, try repeating this experiment, but during the video session, reduce the network data rate to a very low value in middle of the session. 


On the "router", set a constant bit rate of 1000 Kbits/second with

```bash
bash rate-set.sh 1000Kbit
```

Then, on the client ("romeo"), start the DASH player with the "basic" adaptation policy:

```bash
python2 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d
```

Leave this running for a while. Then, on the "router", reduce the network data rate to 50 Kbits/second:

```
bash rate-set.sh 50Kbit
```

After some time has elapsed, restore the original data rate.

```bash
bash rate-set.sh 1000Kbit
```

Then, after a little while longer, stop the video client on "romeo" with Ctrl+C.

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