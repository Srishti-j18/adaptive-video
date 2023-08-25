::: {.cell .markdown}
## Reserve resources on FABRIC

In this section, we'll reserve and configure resources on the FABRIC testbed.
:::

::: {.cell .markdown}
### Configure environment
:::

::: {.cell .code}
``` python
from fabrictestbed_extensions.fablib.fablib import FablibManager as fablib_manager
fablib = fablib_manager() 
conf = fablib.show_config()
```
:::

::: {.cell .markdown}
### Define FABRIC configuration for adaptive video experiment
:::

::: {.cell .code}
``` python
slice_name="adaptive-video-" + fablib.get_bastion_username()

node_conf = [
 {'name': "romeo",   'cores': 2, 'ram': 4, 'disk': 10, 'image': 'default_ubuntu_20', 'packages': ['net-tools', 'iperf3', 'moreutils']}, 
 {'name': "juliet",  'cores': 2, 'ram': 4, 'disk': 10, 'image': 'default_ubuntu_20', 'packages': ['net-tools', 'iperf3', 'moreutils']}, 
 {'name': "router",  'cores': 2, 'ram': 4, 'disk': 10, 'image': 'default_ubuntu_20', 'packages': ['net-tools']}
]
net_conf = [
 {"name": "net_r", "subnet": "10.10.1.0/24", "nodes": [{"name": "romeo",  "addr": "10.10.1.100"}, {"name": "router", "addr": "10.10.1.10"}]},
 {"name": "net_j", "subnet": "10.10.2.0/24", "nodes": [{"name": "juliet", "addr": "10.10.2.100"}, {"name": "router", "addr": "10.10.2.10"}]},
]
route_conf = [
 {"addr": "10.10.1.0/24", "gw": "10.10.2.10", "nodes": ["juliet"]}, 
 {"addr": "10.10.2.0/24", "gw": "10.10.1.10", "nodes": ["romeo"]}
]
exp_conf = {'cores': sum([ n['cores'] for n in node_conf]), 'nic': sum([len(n['nodes']) for n in net_conf]) }
```
:::

::: {.cell .markdown}
### Reserve resources

Now, we are ready to reserve resources!
:::

::: {.cell .markdown}
First, make sure you don't already have a slice with this name:
:::

::: {.cell .code}
``` python
try:
    slice = fablib.get_slice(slice_name)
    print("You already have a slice by this name!")
    print("If you previously reserved resources, skip to the 'log in to resources' section.")
except:
    print("You don't have a slice named %s yet." % slice_name)
    print("Continue to the next step to make one.")
    slice = fablib.new_slice(name=slice_name)
```
:::

::: {.cell .markdown}
We will select a random site that has sufficient resources for our experiment:
:::

::: {.cell .code}
``` python
while True:
    site_name = fablib.get_random_site()
    if ( (fablib.resources.get_core_available(site_name) > 1.2*exp_conf['cores']) and
        (fablib.resources.get_component_available(site_name, 'SharedNIC-ConnectX-6') > 1.2**exp_conf['nic']) ):
        break

fablib.show_site(site_name)
```
:::

::: {.cell .markdown}
Then we will add hosts and network segments:
:::

::: {.cell .code}
``` python
# this cell sets up the nodes
for n in node_conf:
    slice.add_node(name=n['name'], site=site_name, 
                   cores=n['cores'], 
                   ram=n['ram'], 
                   disk=n['disk'], 
                   image=n['image'])
```
:::

::: {.cell .code}
``` python
# this cell sets up the network segments
for n in net_conf:
    ifaces = [slice.get_node(node["name"]).add_component(model="NIC_Basic", 
                                                 name=n["name"]).get_interfaces()[0] for node in n['nodes'] ]
    slice.add_l2network(name=n["name"], type='L2Bridge', interfaces=ifaces)
```
:::

::: {.cell .markdown}
The following cell submits our request to the FABRIC site. The output of this cell will update automatically as the status of our request changes.

-   While it is being prepared, the "State" of the slice will appear as "Configuring".
-   When it is ready, the "State" of the slice will change to "StableOK".

You may prefer to walk away and come back in a few minutes (for simple slices) or a few tens of minutes (for more complicated slices with many resources).
:::

::: {.cell .code}
``` python
slice.submit()
```
:::

::: {.cell .code}
``` python
slice.get_state()
slice.wait_ssh(progress=True)
```
:::

::: {.cell .markdown}
### Configure resources

Next, we will configure the resources so they are ready to use.
:::

::: {.cell .code}
``` python
slice = fablib.get_slice(name=slice_name)
```
:::

::: {.cell .code}
``` python
# install packages
# this will take a while and will run in background while you do other steps
for n in node_conf:
    if len(n['packages']):
        node = slice.get_node(n['name'])
        pkg = " ".join(n['packages'])
        node.execute_thread("sudo apt update; sudo apt -y install %s" % pkg)
```
:::

::: {.cell .code}
``` python
# bring interfaces up and either assign an address (if there is one) or flush address
from ipaddress import ip_address, IPv4Address, IPv4Network

for net in net_conf:
    for n in net['nodes']:
        if_name = n['name'] + '-' + net['name'] + '-p1'
        iface = slice.get_interface(if_name)
        iface.ip_link_up()
        if n['addr']:
            iface.ip_addr_add(addr=n['addr'], subnet=IPv4Network(net['subnet']))
        else:
            iface.get_node().execute("sudo ip addr flush dev %s"  % iface.get_device_name())
```
:::

::: {.cell .code}
``` python
# prepare a "hosts" file that has names and addresses of every node
hosts_txt = [ "%s\t%s" % ( n['addr'], n['name'] ) for net in net_conf  for n in net['nodes'] if type(n) is dict and n['addr']]
for n in slice.get_nodes():
    for h in hosts_txt:
        n.execute("echo %s | sudo tee -a /etc/hosts" % h)
```
:::

::: {.cell .code}
``` python
# enable IPv4 forwarding on all nodes
for n in slice.get_nodes():
    n.execute("sudo sysctl -w net.ipv4.ip_forward=1")
```
:::

::: {.cell .code}
``` python
# set up static routes
for rt in route_conf:
    for n in rt['nodes']:
        slice.get_node(name=n).ip_route_add(subnet=IPv4Network(rt['addr']), gateway=rt['gw'])
```
:::

::: {.cell .code}
``` python
# enable nodes to access IPv4-only resources, such as Github,
# even if the control interface is IPv6-only
from ipaddress import ip_address, IPv6Address
for node in slice.get_nodes():
    if type(ip_address(node.get_management_ip())) is IPv6Address:
        node.execute('echo "DNS=2a00:1098:2c::1" | sudo tee -a /etc/systemd/resolved.conf')
        node.execute('sudo service systemd-resolved restart')
        node.execute('echo "127.0.0.1 $(hostname -s)" | sudo tee -a /etc/hosts')
```
:::

::: {.cell .markdown}
### Draw the network topology
:::

::: {.cell .markdown}
The following cell will draw the network topology, for your reference. The interface name and addresses of each experiment interface will be shown on the drawing.
:::

::: {.cell .code}
``` python
l2_nets = [(n.get_name(), {'color': 'lavender'}) for n in slice.get_l2networks() ]
l3_nets = [(n.get_name(), {'color': 'pink'}) for n in slice.get_l3networks() ]
hosts   =   [(n.get_name(), {'color': 'lightblue'}) for n in slice.get_nodes()]
nodes = l2_nets + l3_nets + hosts
ifaces = [iface.toDict() for iface in slice.get_interfaces()]
edges = [(iface['network'], iface['node'], 
          {'label': iface['physical_dev'] + '\n' + iface['ip_addr'] + '\n' + iface['mac']}) for iface in ifaces]
```
:::

::: {.cell .code}
``` python
import networkx as nx
import matplotlib.pyplot as plt
plt.figure(figsize=(len(nodes),len(nodes)))
G = nx.Graph()
G.add_nodes_from(nodes)
G.add_edges_from(edges)
pos = nx.spring_layout(G)
nx.draw(G, pos, node_shape='s',  
        node_color=[n[1]['color'] for n in nodes], 
        node_size=[len(n[0])*400 for n in nodes],  
        with_labels=True);
nx.draw_networkx_edge_labels(G,pos,
                             edge_labels=nx.get_edge_attributes(G,'label'),
                             font_color='gray',  font_size=8, rotate=False);
```
:::

::: {.cell .markdown}
### Log into resources
:::

::: {.cell .markdown}
Now, we are finally ready to log in to our resources over SSH! Run the following cells, and observe the table output - you will see an SSH command for each of the resources in your topology.
:::

::: {.cell .code}
``` python
import pandas as pd
pd.set_option('display.max_colwidth', None)
slice_info = [{'Name': n.get_name(), 'SSH command': n.get_ssh_command()} for n in slice.get_nodes()]
pd.DataFrame(slice_info).set_index('Name')
```
:::

::: {.cell .markdown}
Now, you can open an SSH session on any of the resources as follows:

-   in Jupyter, from the menu bar, use File \> New \> Terminal to open a new terminal.
-   copy an SSH command from the table, and paste it into the terminal. (Note that each SSH command is a single line, even if the display wraps the text to a second line! When you copy and paste it, paste it all together.)

You can repeat this process (open several terminals) to start a session on each resource. Each terminal session will have a tab in the Jupyter environment, so that you can easily switch between them.
:::
