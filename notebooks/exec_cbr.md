## Execute constant bit rate experiment

For this section, you will need an SSH session on the "router" node and one on the "romeo" node.

On the "router", set a constant bit rate of 1000 Kbits/second with

```bash
bash rate-set.sh 1000Kbit
```

(The first time you run it, you may see an error referencing a problem deleting a `qdisc`, but you can safely ignore this error.)

Note: you can specify a data rate in Kbits/second using `Kbit` or in Mbits/second using `Mbit`.

Then, on the client ("romeo"), start the DASH player with the "basic" adaptation policy:

```bash
python3 ~/AStream/dist/client/dash_client.py -m http://192.168.1.2/media/BigBuckBunny/4sec/BigBuckBunny_4s.mpd -p 'basic' -d
```

(Note: you can alternatively try `netflix` or `sara` as the DASH policy.)

Leave this running for a while. Then, you can interrupt the DASH client with Ctrl+C.

To understand the performance of the DASH policy, we can look at the logs produced by the client. These will be located inside a directory named `ASTREAM_LOGS` in your home directory on the "romeo" node. Use 

```bash
ls ~/ASTREAM_LOGS
```

to find these.

In the data analysis section, we will use these logs - specifically the one that begins with `DASH_BUFFER_LOG_` - to understand the video adaptation policy that was applied in this experiment. We will copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_last.csv` with

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