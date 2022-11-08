""" 

## Adaptive video

This experiment explores the tradeoff between different metrics of video quality (average rate, interruptions, and variability of rate) in an adaptive video delivery system.

It should take about 60-120 minutes to run this experiment.

Instructions for running the experiment are at: https://witestlab.poly.edu/blog/adaptive-video-reproducing/ """

#
# NOTE: This code was machine converted. An actual human would not
#       write code like this!
#

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

# Node client
node_client = request.XenVM('romeo')
node_client.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
iface0 = node_client.addInterface('interface-0', pg.IPv4Address('192.168.0.2','255.255.255.0'))

# Node router
node_router = request.XenVM('router')
node_router.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
iface1 = node_router.addInterface('interface-1', pg.IPv4Address('192.168.0.1','255.255.255.0'))
iface2 = node_router.addInterface('interface-2', pg.IPv4Address('192.168.1.1','255.255.255.0'))

# Node server
node_server = request.XenVM('juliet')
node_server.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD'
iface3 = node_server.addInterface('interface-3', pg.IPv4Address('192.168.1.2','255.255.255.0'))

# Link link-0
link_0 = request.Link('link-0')
link_0.addInterface(iface0)
link_0.addInterface(iface1)

# Link link-1
link_1 = request.Link('link-1')
link_1.addInterface(iface2)
link_1.addInterface(iface3)


# Print the generated rspec
pc.printRequestRSpec(request)

