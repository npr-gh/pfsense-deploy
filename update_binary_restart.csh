#!/bin/tcsh 
echo "Upgrade pfsense -C";
pfSense-upgrade -c;
echo "Upgrade packages -Y";
pkg upgrade -y;
echo "Upgrade Wireguard";
pkg upgrade -fy pfSense-pkg-WireGuard;
echo "Restarting PHP-fpm";
/etc/rc.php-fpm_restart;
echo "Restarting webUI";
/etc/rc.restart_webgui;
echo "Restarting captive portal (if used for wireless)";
/etc/rc.captiveportal_configure;