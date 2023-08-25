::: {.cell .markdown}
### Define FABRIC configuration for adaptive video experiment
:::

::: {.cell .code}
```python
slice_name="adaptive-video-" + fablib.get_bastion_username()

node_conf = [
 {'name': "romeo",   'cores': 2, 'ram': 4, 'disk': 10, 'image': 'default_ubuntu_20', 'packages': ['net-tools', 'iperf3', 'moreutils']}, 
 {'name': "juliet",  'cores': 2, 'ram': 4, 'disk': 10, 'image': 'default_ubuntu_20', 'packages': ['net-tools', 'iperf3', 'moreutils']}, 
 {'name': "router",  'cores': 2, 'ram': 4, 'disk': 10, 'image': 'default_ubuntu_20', 'packages': ['net-tools']}
]
net_conf = [
 {"name": "net_r_", "subnet": "10.10.1.0/24", "nodes": [{"name": "romeo",  "addr": "10.10.1.100"}, {"name": "router", "addr": "10.10.1.10"}]},
 {"name": "net_j_", "subnet": "10.10.2.0/24", "nodes": [{"name": "juliet", "addr": "10.10.2.100"}, {"name": "router", "addr": "10.10.2.10"}]},
]
route_conf = [
 {"addr": "10.10.1.0/24", "gw": "10.10.2.10", "nodes": ["juliet"]}, 
 {"addr": "10.10.2.0/24", "gw": "10.10.1.10", "nodes": ["romeo"]}
]
exp_conf = {'cores': sum([ n['cores'] for n in node_conf]), 'nic': sum([len(n['nodes']) for n in net_conf]) }
```
:::
