
::: {.cell .markdown}

## Set up the adaptive video experiment

:::



::: {.cell .markdown}

Now, we're going to install software and set up the materials we need specifically to transfer adaptive video across this network! You will do this by opening SSH sessions to each of the hosts in the topology, and running commands to set them up as needed.

Make sure you have the SSH commands ready for each of the hosts.

:::


::: {.cell .markdown}

### Prepare the server

First, we will set up the "juliet" host as an adaptive video server. Open an SSH session on "juliet", and run the commands in this section there.

:::


::: {.cell .markdown}
At the server, we will set up an HTTP server which will serve the video files to the client.

First, install the Apache HTTP server:

:::



::: {.cell .markdown}
```bash
sudo apt update  
sudo apt install -y apache2  
```
:::


::: {.cell .markdown}

Then, download the video segments and put them in the web server directory. This step will take some time - while it is running, you can open another tab and move on to configuration of the other hosts.

:::


::: {.cell .markdown}
```bash
wget https://nyu.box.com/shared/static/d6btpwf5lqmkqh53b52ynhmfthh2qtby.tgz -O media.tgz
sudo tar -v -xzf media.tgz -C /var/www/html/
```
:::


::: {.cell .markdown}
The web server directory now contains 4-second segments of the "open" video clip [Big Buck Bunny](https://peach.blender.org/about/), encoded at different quality levels. The Big Buck Bunny DASH dataset is from:

> Stefan Lederer, Christopher Müller, and Christian Timmerer. 2012. Dynamic adaptive streaming over HTTP dataset. In Proceedings of the 3rd Multimedia Systems Conference (MMSys '12). Association for Computing Machinery, New York, NY, USA, 89–94. DOI:https://doi.org/10.1145/2155555.2155570

:::



::: {.cell .markdown}

### Prepare the router

Next, we will set up the router. Open an SSH session on "router", and run the commands in this section there.

:::


::: {.cell .markdown}

At the router, we will *emulate* different network conditions, to see how each DASH policy performs. 

We will experiment with both a constant data rate, and a variable data rate like that experienced by a mobile user. For the mobile user, we'll use some network traces collected in the New York City metro area. With these traces, the data rate experienced by the DASH client in our experiment will mimic the experience of traveling around NYC on bus, subway, and ferry.

The NYC traces are shared from the following paper:

> Lifan Mei, Runchen Hu, Houwei Cao, Yong Liu, Zifa Han, Feng Li & Jin Li. (2019, March). Realtime Mobile Bandwidth Prediction using LSTM Neural Networks. In International Conference on Passive and Active Network Measurement. Springer.

To download the traces, on the "router" node run:

:::



::: {.cell .markdown}
```bash
git clone https://github.com/NYU-METS/Main nyc-traces
```
:::


::: {.cell .markdown}

To extract the trace files from their compressed archive, we will need to install an appropriate utility:

:::


::: {.cell .markdown}
```bash
sudo apt update
sudo apt install -y unrar-free
```
:::


::: {.cell .markdown}

Then, run

:::


::: {.cell .markdown}
```bash
unrar nyc-traces/Dataset/Dataset_1.rar
```
:::

::: {.cell .markdown}
We will also download a couple of utility scripts to help us set a constant data rate or vary the data rate on the network. On the "router" node, run

:::


::: {.cell .markdown}
```bash
wget https://raw.githubusercontent.com/teaching-on-testbeds/adaptive-video/main/rate-vary.sh -O ~/rate-vary.sh
```
:::


::: {.cell .markdown}
and
:::

::: {.cell .markdown}
```bash
wget https://raw.githubusercontent.com/teaching-on-testbeds/adaptive-video/main/rate-set.sh -O ~/rate-set.sh
```
:::


::: {.cell .markdown}

### Prepare the client

Finally, we need to prepare the "romeo" host as a video client. Open an SSH session on "romeo", and run the commands in this section there.

:::


::: {.cell .markdown}

Download the AStream DASH video client:

:::



::: {.cell .markdown}
```bash
git clone https://github.com/pari685/AStream
```
:::




::: {.cell .markdown}

We must install Python2 to run the DASH video client, and we will also install the video encoding utility `ffmpeg` so that we can reconstruct the video later:

:::



::: {.cell .markdown}
```bash
sudo apt update
sudo apt install -y python2 ffmpeg
```
:::



::: {.cell .markdown}

Now we are ready to run our experiments! We will run three experiments: one with a constant bit rate, one with a constant bit rate and an interruption in middle, and one with a varying bit rate using the NYC traces.

:::
