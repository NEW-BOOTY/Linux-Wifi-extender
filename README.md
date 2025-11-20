✅ WHAT THIS SCRIPT CAN DO (Capabilities)
This script is capable of performing the following actual, real-world technical functions on a Linux system (typically Debian/Ubuntu-based) with WiFi hardware that supports virtual AP mode:
1. Create a WiFi Access Point (AP) using a virtual interface
It configures wlan1 as a virtual AP interface.
Broadcasts a WiFi network with your chosen SSID and password.
Uses hostapd to manage authentication and radio configuration.
2. Extend an existing WiFi network
Creates a bridge (br0) between:
your physical interface (wlan0)
the virtual AP interface (wlan1)
This enables clients connected to the AP to communicate through the upstream WiFi network.
3. Build a mesh-capable layer using B.A.T.M.A.N. advanced
Loads the batman-adv kernel module.
Adds both WiFi interfaces (wlan0 and wlan1) to batman-adv.
Creates the bat0 interface to function as part of a mesh routing topology.
This allows devices running batman-adv to form a distributed, self-routing network.
4. Automatically install required dependencies
The script will install:
hostapd → WiFi AP manager
batctl → Batman-adv user tools
5. Configure and restart system services
Writes a full /etc/hostapd/hostapd.conf
Restarts the hostapd service
6. Dynamically configure IP addresses
Uses DHCP (dhclient) to get IPs for:
the bridge interface (br0)
the batman interface (bat0)
7. Provide basic logging
Writes events to:
/var/log/wifi_extender.log
8. Validate user input & ensure minimum security
Ensures SSID is not empty.
Ensures Wi-Fi password is at least 8 characters.
Requires root privileges.
🔥 WHAT THIS SCRIPT WILL DO WHEN RUN (Actual Behavior)
When executed, step-by-step, the script will:
Prompt for SSID and password.
Refuses empty SSID or weak password.
Check you're root.
Immediately exits if not.
Install missing packages (hostapd, batctl).
Load kernel module batman-adv.
Create a virtual WiFi interface wlan1 in AP mode.
Configure the AP radio settings for:
Channel 36
5GHz (hw_mode=a)
HT40- bandwidth
Generate a valid hostapd configuration file.
Restart hostapd, activating the AP.
Create a layer-2 bridge br0 and attach:
wlan0 (physical interface)
wlan1 (virtual AP interface)
Bring up br0 and obtain an IP via DHCP.
Add both WiFi interfaces to batman-adv, bringing up bat0.
Obtain IP via DHCP for bat0 (mesh interface).
Log the success message and print:
WiFi extender and mesh network system configured successfully.
📡 In Plain Terms: What This Means
Running this script will transform a Linux machine into:
A WiFi extender / repeater
It bridges a physical WiFi connection to a virtual one so you can rebroadcast the upstream WiFi network.
A mesh networking node
Using batman-adv, the device becomes part of an ad-hoc distributed mesh, able to route traffic between nodes automatically.
A dual-function AP + mesh router
Devices can:
connect to WiFi you broadcast,
access the upstream network,
participate in a mesh if other nodes are present.
⚠️ Practical Concerns / Caveats
This script will fail or behave unexpectedly if:
Your WiFi card does not support AP mode + station mode simultaneously.
Kernel modules are not compatible.
You’re on a system without Debian package management.
WiFi drivers don't support virtual interfaces.
This is not inherently unsafe, but it does require proper hardware, and misconfiguration can disrupt existing WiFi connections.
🔐 Security Notes
WPA2-PSK is enforced (strong).
The script writes logs to a predictable path — ensure permissions are correct.
The AP password validation is good but minimal (8 characters).
Bridge + mesh operations expose network surfaces — should be restricted to controlled environments.
🧭 Summary
This script:
✔ Creates a WiFi access point
✔ Bridges it to an existing WiFi network
✔ Adds both to a mesh networking protocol
✔ Installs and configures dependencies
✔ Applies hostapd, bridge, DHCP, and batman-adv networking
✔ Performs basic input validation and logging
It is a functional, real-world WiFi extender + mesh node initializer.
