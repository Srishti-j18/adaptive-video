::: {.cell .markdown}


## Exercises

After you have run the experiment, answer the following questions:

* Question 1
* Question 2


:::

::: {.cell .markdown}
## Exercises

After you have run the experiment, answer the following questions:

-   In constant bit rate experiment, did you observe any buffering in
    any of the DASH policies? Explain.
-   In constant bit rate with interruptions experiment, did you see any
    buffering in basic, netflix and sara policies? Explain with the
    screenshots from your analysis. Also comment on how well each policy
    recovers from the buffering and which policy is most resilient to
    interruptions.
-   In varying bit rate experiment, which of the DASH policy has better
    average video rate? Justify using the screenshots.

The following questions requires you to modify certain parameters in
each of the experiment:

-   What happens when you increase the network capacity from 1Mbps to
    4Mbps in constant bit rate experiment?

Go to the client node rome and change the current directory to edit the
config_dash.py file by running the following commands:

``` bash
cd ~/AStream/dist/client
nano config_dash.py
```

Under the SARA section, change ALPHA_BUFFER_COUNT to 10 and
BETA_BUFFER_COUNT to 15 and Ctrl+X, \'Y\' for Yes and \'Enter\' to save
the changes and exit the file. Now perform the constant bit rate using
SARA policy.

Note: Revert the configuration changes back to initial
settings(ALPHA_BUFFER_COUNT = 5 and BETA_BUFFER_COUNT = 10) by editing
config_dash.py file after analysing the logs.

-   Observe and explain how changing the buffer thresholds effects
    different metrics such as average video rate and number of bitrate
    switching events?

Perform varying bit rate experiment with scaling factor of 0.25 for each
DASH policy. On router node, run:

``` bash
bash rate-vary.sh ~/Dataset_1/Dataset/Ferry/Ferry5.csv 0.25
```

-   What differences do you see in terms of different metrics by
    changing the scaling factor from 0.1 to 0.25 for each DASH policy?
:::

::: {.cell .code}
``` python
```
:::
