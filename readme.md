
# Mass deployment 

Configure an SSH key to each pfSense for mass script updates.
Copy and edit the example csv: 

```
cp firewalls.csv.example firewalls.csv 
nano firewalls.csv
```

Add the following single line to the Advanced Features-> User Parameters instead of the standard settings (has to be done manually once on each firewall). Replace the '7' with your major zabbix agent version: 
 
```bash
Include=/usr/local/etc/zabbix7/zabbix_agentd.conf.d/*.conf
```

Add the target IP, port, and set the public key in ~/.ssh/authorized_keys for the admin user on each pfSense. 
Make a backup of your configurations before doing script-wise modification of firewalls. A separate backup script is provided, run it using: 

```
./backup_config_all.sh -f firewalls.csv -k ~/.ssh/pfsense.key.priv 
```

Then run: 

```
./deploy_all.sh -f firewalls.csv -k ~/.ssh/pfsense.key.priv -s deploy.sh
```

Note: When using mass deployment: As the configuration is now stored in user_params.cfg instead of in pfSense itself, it will be wiped in an update. 
Whenever updating all pfSense: Re-run the deployment once. 

## Alternative scripts 

Other scripts can be deployed the same way as long as they follow the same parameter syntax. 
Following additional script tools exist in this repository: 

### update_pkg.sh 

Updates firewall and restarts web services. 

## Development note: 

If user-driven parameters are added to pfSense then they should also be copied into user_params.cfg in this directory.