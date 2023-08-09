## Execute Constant Bit Rate Experiment with Interruption and Policy Comparison 

For this section, you will need an SSH session on the "router" node and one on the "romeo" node.

This section involves conducting a constant bit rate experiment with interruptions while comparing two adaptation policies: "Basic" and "Netflix." Both policies will be tested under identical bandwidth settings and time durations to facilitate a clear comparison.

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

to find these. We will copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_basic.csv` with


```bash
cp $(ls -t1  ~/ASTREAM_LOGS/DASH_BUFFER_LOG_*  | head -n 1 ) ~/ASTREAM_LOGS/DASH_BUFFER_LOG-basic.csv
```

With these steps completed, you now have the log file for the "basic" policy experiment. Similarly, we will proceed with the experiment for the "Netflix" policy.



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

to find these. We will copy the file associated with _this_ experiment to `~/ASTREAM_LOGS/DASH_BUFFER_LOG_netflix.csv` with


```bash
cp $(ls -t1  ~/ASTREAM_LOGS/DASH_BUFFER_LOG_*  | head -n 1 ) ~/ASTREAM_LOGS/DASH_BUFFER_LOG-netflix.csv
```

You can now proceed to analyze the data obtained from the experiments for the "Basic" and "Netflix" adaptation policies. By comparing the video rate graphs generated from these experiments, you will be able to observe the differences between the two policies.

Run the provided [data analysis for the policies](data_analysis_fabric_policy.ipynb) to visualize and compare the video rate graphs for both policies.