::: {.cell .markdown}


## Data analysis

After each experiment run (with different variations in experiment conditions!) we can see the video that was delivered to the client, and also see how the video client made its decisions.

:::


::: {.cell .markdown}
First, run this cell to make sure your FABRIC configuration and slice configuration is loaded.
:::


::: {.cell .code}
```python
from fabrictestbed_extensions.fablib.fablib import FablibManager as fablib_manager
fablib = fablib_manager()                     

slice_name="adaptive-video-" + fablib.get_bastion_username()
slice = fablib.get_slice(name=slice_name)
```
:::



::: {.cell .markdown}

Next, the following cell will retrieve the reconstructed video file so that you can play it back inside this notebook. You may notice the video resolution *and* the apparent "sharpness" of the picture quality change as the video client "adapts" to the network:

:::

::: {.cell .code}
```python
slice.get_node("romeo").download_file("/home/fabric/work/BigBuckBunny.mp4", "/home/ubuntu/BigBuckBunny.mp4")
from IPython.display import Video
Video("/home/fabric/work/BigBuckBunny.mp4", embed=True)
```

:::

::: {.cell .markdown}

Then, you can use the log files to find out how the video client made its decisions. In the following cell, fill in the `DASH_BUFFER_LOG` log file name associated with the instance of _your_ experiment that you want to analyze.
:::


::: {.cell .code}

```python
DASH_BUFFER_LOG="DASH_BUFFER_LOG-last.csv"
slice.get_node("romeo").download_file("/home/fabric/work/DASH_BUFFER_LOG.csv", "/home/ubuntu/ASTREAM_LOGS/" + DASH_BUFFER_LOG)
```
:::

::: {.cell .markdown}

and use the following cells to create a visualization. In the first subplot, the line shows the bit rate of each segment as it is played back over time, and the colored background indicates whether the client is playing video (light cyan) or buffering (light pink).

We also visualize the buffer occupancy over time. In the second subplot, the line shows the number of segments in the buffer over time, and the colored background indicates whether the client is playing video (light cyan) or buffering (light pink). When the buffer occupancy goes to zero, the will have to stop playing in order to retrieve more data into the buffer.

:::


::: {.cell .code}

```python
import matplotlib.pyplot as plt
import pandas as pd

c = {'INITIAL_BUFFERING': 'violet', 'PLAY': 'lightcyan', 'BUFFERING': 'lightpink'}

dash = pd.read_csv("/home/fabric/work/DASH_BUFFER_LOG.csv")
dash = dash.loc[dash.CurrentPlaybackState.isin(c.keys() )]
states = pd.DataFrame({'startState': dash.CurrentPlaybackState[0:-2].values, 'startTime': dash.EpochTime[0:-2].values,
                        'endState':  dash.CurrentPlaybackState[1:-1].values, 'endTime':   dash.EpochTime[1:-1].values})
```
:::

::: {.cell .code}

```python
plt.subplot(211)

for index, s in states.iterrows():
  plt.axvspan(s['startTime'], s['endTime'],  color=c[s['startState']], alpha=1) 

plt.plot(dash[dash.Action!="Writing"].EpochTime, dash[dash.Action!="Writing"].Bitrate, 'kx:')
plt.title("Video rate (bps)");
plt.xlabel("Time (s)");

plt.subplot(212)


for index, s in states.iterrows():
  plt.axvspan(s['startTime'], s['endTime'],  color=c[s['startState']], alpha=1) 

plt.plot(dash[dash.Action!="Writing"].EpochTime, dash[dash.Action!="Writing"].CurrentBufferSize, 'kx:')
plt.title("Buffer(segments)");
plt.xlabel("Time (s)");

plt.tight_layout()
```
:::

