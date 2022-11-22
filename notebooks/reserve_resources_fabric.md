::: {.cell .markdown}

## Reserve resources on FABRIC

:::

::: {.cell .markdown}

For this experiment, we will use three virtual machines, connected in a linear topology: a client, a router, and a server. In this section, you will reserve and configure these resources on FABRIC.

:::


::: {.cell .markdown}

### Load your FABRIC configuration

:::


::: {.cell .markdown}

The following instructions assume you have already configured your JupyterHub environment in a previous session, including creating the `fabric_rc` and `ssh_config` files. If you haven't, you should do that first - it's a prerequisite for this experiment.

:::


::: {.cell .markdown}

Load your FABRIC configuration options, then check to make sure the configuration looks correct:

:::

::: {.cell .code}
```python
import os
os.environ['FABRIC_RC_FILE']=os.environ['HOME']+'/work/fabric_config/fabric_rc'
os.environ['FABRIC_BASTION_SSH_CONFIG_FILE']=os.environ['HOME']+'/work/fabric_config/ssh_config'

from fabrictestbed_extensions.fablib.fablib import FablibManager as fablib_manager
fablib = fablib_manager()                     
fablib.show_config()
```
:::



::: {.cell .markdown}
Make sure the private key file you will use to access resources has the appropriate permissions:

:::

::: {.cell .code}

```python
os.environ['FABRIC_SLICE_PRIVATE_KEY_FILE'] = fablib.get_default_slice_private_key_file()
:::

::: {.cell .code}
```python
%%bash 
chmod 0600 "$FABRIC_SLICE_PRIVATE_KEY_FILE"
```
:::


::: {.cell .markdown}

### Prepare a slice for this experiment

:::


::: {.cell .markdown}

If everything looks good, let's set up a slice! We'll name our slice for this experiment using a combination of your username and the name `adaptive_video`:

:::


::: {.cell .code}

```python
SLICENAME=fablib.get_bastion_username() + "_adaptive_video"
```
:::


::: {.cell .markdown}

If you already have the resources for this experiment (for example: you ran this part of the notebook previously, and are now returning to pick off where you left off), you don't need to reserve resources again. If the following cell tells you that you already have resources, you can just skip ahead to the part of the experiment where you left off last.

:::


::: {.cell .code}
```python
try:
    fablib.get_slice(SLICENAME)
    print("You already have a slice named %s.\nYou should skip the 'Reserve resources in your slice' section." % SLICENAME)
    slice = fablib.get_slice(name=SLICENAME)
except:
    print("You don't have any active slice named %s.\nKeep going to set one up!" % SLICENAME)
```
:::


::: {.cell .markdown}

### Reserve resources in your slice

:::

::: {.cell .markdown}

If you don't already have a slice with the resources for this experiment, you'll reserve one now!  First, you'll select a FABRIC site on which to run your experiment. 

The following cell will select a random FABRIC site. Check the output of this cell and make sure the selected site has sufficient resources - for this experiment, your selected site should have at least:

* 3 cores (1 per VM)
* 12 GB RAM (4 GB per VM)
* 30 GB disk space (10 GB per VM)

Re-run the cell to select a new random site until you find one with available resources.

:::


::: {.cell .code}
```python
import random
SITE = random.choice(fablib.get_site_names())
print(f"{fablib.show_site(SITE)}")
```
:::


::: {.cell .markdown}

Once you have selected a site, you can reserve resources at that site. The following cell will set up your resource request and then submit it to FABRIC.

The output of the cell will update automatically as your slice status changes. It may take a while (5-10 minutes) before this process is complete and the "Slice State" changes to "StableOK".

:::

::: {.cell .code}
```python
slice = fablib.new_slice(name=SLICENAME)

nodes = {'romeo': None, 'juliet': None, 'router': None}
for key,val in nodes.items():
    nodes[key] = slice.add_node(name=key,  site=SITE, cores=1, ram=4, disk=10, image='default_ubuntu_20')

iface_net_r = [
    nodes['romeo'].add_component(model="NIC_Basic", name="if_romeo").get_interfaces()[0],
    nodes['router'].add_component(model="NIC_Basic", name="if_router_r").get_interfaces()[0]
]
slice.add_l2network(name='net_r', type='L2Bridge', interfaces=iface_net_r)

iface_net_j = [
    nodes['juliet'].add_component(model="NIC_Basic", name="if_juliet").get_interfaces()[0],
    nodes['router'].add_component(model="NIC_Basic", name="if_router_j").get_interfaces()[0]
]
slice.add_l2network(name='net_j', type='L2Bridge', interfaces=iface_net_j)

slice.submit()
```
:::


::: {.cell .markdown}

When it is done, verify that the slice status is "StableOK":

:::


::: {.cell .code}

```python
print(f"{slice}")
```
:::

::: {.cell .markdown}

### Configure your slice

:::

::: {.cell .markdown}

Before we start our experiment, we need to configure the resources and the network on this slice.
:::


::: {.cell .markdown}

We'll install some software on the end hosts. This cell may take another 10 minutes, and no output will appear until it is finished running:

:::


::: {.cell .code}
```python
slice.get_node("romeo").execute("sudo apt update; sudo apt -y install net-tools iperf3 moreutils")
slice.get_node("juliet").execute("sudo apt update; sudo apt -y install net-tools iperf3 moreutils")
slice.get_node("router").execute("sudo apt update; sudo apt -y install net-tools")

```
:::






::: {.cell .markdown}


Next, we will set up networking.

:::


::: {.cell .markdown}

The following cell will make sure that the FABRIC nodes can reach targets on the Internet (e.g. to retrieve files or software), even if the FABRIC nodes connect to the Internet through IPv6 and the targetes on the Internet are IPv4 only, by using [nat64](https://nat64.net/).

:::


::: {.cell .code}
```python
for node in ["romeo", "juliet", "router"]:
    slice.get_node(node).execute("sudo sed -i '1s/^/nameserver 2a01:4f9:c010:3f02::1\n/' /etc/resolv.conf")
    slice.get_node(node).execute('echo "127.0.0.1 $(hostname -s)" | sudo tee -a /etc/hosts')
```
:::


::: {.cell .code}
```python
# configure an IP address on every experiment interface
from ipaddress import IPv4Address, IPv4Network
slice.get_interface("romeo-if_romeo-p1").ip_addr_add(IPv4Address('192.168.0.2'), IPv4Network('192.168.0.0/24'))
slice.get_interface("router-if_router_r-p1").ip_addr_add(IPv4Address('192.168.0.1'), IPv4Network('192.168.0.0/24'))
slice.get_interface("router-if_router_j-p1").ip_addr_add(IPv4Address('192.168.1.1'), IPv4Network('192.168.1.0/24'))
slice.get_interface("juliet-if_juliet-p1").ip_addr_add(IPv4Address('192.168.1.2'), IPv4Network('192.168.1.0/24'))

# bring all the interfaces up
slice.get_interface("romeo-if_romeo-p1").ip_link_up()
slice.get_interface("router-if_router_r-p1").ip_link_up()
slice.get_interface("router-if_router_j-p1").ip_link_up()
slice.get_interface("juliet-if_juliet-p1").ip_link_up()

# enable IP forwarding on router
slice.get_node("router").execute("sudo sysctl -w net.ipv4.ip_forward=1")

# add a route on each host to reach the other host via router
slice.get_node("romeo").ip_route_add(IPv4Network('192.168.1.0/24'), IPv4Address('192.168.0.1'))
slice.get_node("juliet").ip_route_add(IPv4Network('192.168.0.0/24'), IPv4Address('192.168.1.1'))
```
:::

::: {.cell .markdown}

To validate this setup, we will run a `ping` test from "romeo" to "juliet". The following cell _must_ return `True`.
:::


::: {.cell .code}
```python
slice.get_node("romeo").ping_test('192.168.0.2')
```
:::


::: {.cell .markdown}

### Get login details for your slice

:::



::: {.cell .markdown}

Now we can get the SSH command to log in to each host in the slice.

:::


::: {.cell .code}

```python
for node in slice.get_nodes():
    print(f"{node.get_name()}: {node.get_ssh_command()} -F {os.environ['FABRIC_BASTION_SSH_CONFIG_FILE']}")
```
:::


::: {.cell .markdown}

To open an SSH session on any host, use File > New > Terminal. Copy the SSH command from the output of the cell above to this terminal session, and use it to log in to the remote host.

:::
