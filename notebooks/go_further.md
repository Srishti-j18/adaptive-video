
::: {.cell .markdown}

## Modify the adaptive video policy

Do you think you can improve on these adaptive video policies? You can modify the parameters of the adaptive video policies, or even go further and modify the logic in the Python code. Then, you can deploy your modified version to see its effect. 


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

To modify the parameters of the adaptive video policies, open this file: [config_dash.py](../AStream/dist/client/config_dash.py). 

Key factors defined here for the rate based ("basic") policy include:

* `BASIC_THRESHOLD` - the maximum number of segments to store in the buffer in the rate based ("basic") policy.
* `BASIC_UPPER_THRESHOLD` - to avoid oscillations, in the rate based ("basic") policy, the video rate increases or decreases only if it is different from the download rate by at least this factor.
* `BASIC_DELTA_COUNT` - the number of segments' download rate to include in the moving average of network download rate. The smaller this number, the more reactive the client is to (potentially transient!) changes in network rate.


Key factors defined here for the buffer based ("netflix") policy include:

* `NETFLIX_RESERVOIR` - the value of the "reservoir" described above, as a fraction of total buffer size.
* `NETFLIX_CUSHION` - the value of the "cushion" described above, as a fraction of total buffer size.
* `NETFLIX_BUFFER_SIZE` - the maximum number of segments to store in the buffer in the buffer based ("netflix") policy.
* `NETFLIX_INITIAL_BUFFER` and `NETFLIX_INITIAL_FACTOR` - these define the behavior of the policy in the initial stage, which is a bit different than the approach described above.

Make your changes to this file. Then, run the following cell to copy it to the client ("romeo"):

:::


::: {.cell .code}
```python
slice.get_node("romeo").upload_file("../AStream/dist/client/config_dash.py", "/home/ubuntu/AStream/dist/client/config_dash.py")
```
:::

::: {.cell .markdown}

To modify the logic in the source code for the rate based ("basic") policy, open this file:  [basic_dash2.py](../AStream/dist/client/adaptation/basic_dash2.py)

Make your changes to this file. Then, run the following cell to copy it to the client ("romeo"):

:::

::: {.cell .code}
```python
slice.get_node("romeo").upload_file("../AStream/dist/client/adaptation/basic_dash2.py", "/home/ubuntu/AStream/dist/client/adaptation/basic_dash2.py")
```
:::

::: {.cell .markdown}

To modify the logic in the source code for the buffer based ("netflix") policy, open this file:  [netflix_dash.py](../AStream/dist/client/adaptation/netflix_dash.py)

Make your changes to this file. Then, run the following cell to copy it to the client ("romeo"):

:::

::: {.cell .code}
```python
slice.get_node("romeo").upload_file("../AStream/dist/client/adaptation/netflix_dash.py", "/home/ubuntu/AStream/dist/client/adaptation/netflix_dash.py")
```
:::

::: {.cell .markdown}

Then, re-run your experiment and data analysis to analyze the performance of your policy.

:::
