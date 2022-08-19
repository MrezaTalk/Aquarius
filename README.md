# Aquarius
Aquarius is an open-source graphical Infrastructure tool specifically developed for VMware vCenter Administrators to handle batch actions 
those are not available in vCneter server and administrators have to use powercli scripts or spend much time to do actions manually.
This tool is developed with powershell and leveraging VMware powercli modules.

# Installation
In order to run application, the simplest way is to download MSI Installer from windows-installer folder and run the installer, otherwise you 
can download the Aquarius.Package.ps1 file and run in powershell, but you should consider that for running ps1 package you should have VMware vim automation SDKs 
on your system's powershell modules path or path specified in ps1 file.
After MSI installation, a shortcut of application will be created on your desktop, you can run the application by clicking on the shortcut.

## Important Note
In order to run application, since the application is written in powershell language, appropriate powershell execution policy must be set on your system to 
successful run the application.
In order to set execution policy open powershell As Administrator and run below script:

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# How to Use
After successful installation, Run the application, enter vCenter address (FQDN or IP Address), Enter your credential and click on Login button,
Depending on size of your infrastructure it takes some times to fetch ESXi servers’ information.

# Aquarius Features
## Change ESXi Password
After login to your vCenter by default you are in change ESXI password Tab, In right pane you see list of your ESXi servers and their information.
You can select one or more servers from grid view to change the password on them, As we mentioned before the main purpose of this application is to 
perform batch actions are not available in vCenter.
You have 2 options to change the password.
### Random Complex password
If you select the option to generate random complex password, The application will generate a 12-character complex password for each server including:
 - 4 random characters from 'abcdefghiklmnoprstuvwxyz'
 - 3 random characters from 'ABCDEFGHKLMNOPRSTUVWXYZ'
 - 3 random characters from '1234567890'
 - 2 random characters from '!"$%&/()?}{@#*'

For example, if you select 5 ESXi servers from grid view and click on apply while this option is selected, 5 different passwords will be generated and set on ESXi servers,
After the password is changed successfully, Grid view is updated and in front of each ESXi server you can see the newly generated password and the action result.

### Enter your desired password
If you do not want the system to generate complex password for your servers and you want set your desired password on selected servers, you need to select the option 
"Enter password", When you select this option the apply button will be disabled, now you should enter your password in Textbox and apply button won't be enable until you
enter a complex 12-character password.

## Export to CSV
When you change the password of ESXi servers, grid view that shows the list of servers will be updated and the newly password of servers and operation result will be added
to grid view. You can export the grid view to save the latest updated list of passwords by clicking on "Export" button.

## Manage SSH service
In SSH service tab you can stop, start, restart or change the startup policy of one or all of you ESXi servers.
When you open SSH service tab for the first time after login grid view (right-pane) is empty, you should click on refresh button to fetch the current status and startup
policy of your infrastructure ESXi servers. It might take from seconds to minutes depending on size of your infrastructure and number of ESXi servers being managed
by vCenter server.
Once the servers' information loaded you can see the details in grid view, as always you can select one or more servers you want to perform action on them. After selecting servers 
you can stop, start or restart SSH service on selected servers by clicking on correspond button. Also, you can change the desired startup policy and click on set policy
to apply changes on selected servers.
### Policy on/off
Policy on means the service will start automatically each time server boots and policy off means service won't start on server boot and you should start it manually.

## Manage Time Configuration
In Time Configuration tab you can stop, start and restart NTP client service, set startup policy for NTP client service and also manage NTP servers on your ESXi servers.
When you open Time Configuration tab for the first time after login the grid view (right-pane) is empty, you should click on refresh button to fetch the current status,
startup policy and list of configured NTP servers of your infrastructure ESXi servers, it might take from seconds to minutes depending on size of your infrastructure and number 
of ESXi servers being managed by vCenter server.
Once the servers' information loaded you can see the details in grid view, as always you can select one or more servers you want to perform action on them. After selecting servers 
you can stop, start or restart NTP client service on selected servers by clicking on correspond button. Also, you can change the desired startup policy and click on set policy
to apply changes on selected servers.
in addition to set service status and startup policy, in Time configuration tab you can manage NTP servers configured on your ESXi servers. enter NTP servers list (comma
separated) and click on replace or add depending your requirement. If you click on replace current configured NTP servers on selected ESXi servers will be removed and
new NTP servers will be added to the list of NTP servers of your ESXi servers, otherwise if you click on "Add" button, NTP servers you entered in textbox (comma separated)
will be added to the list of configured NTP servers for selected ESXi servers and nothing will be removed.

# Demo Video
Demo video will be uploaded to YouTube and video link will be added here soon ...

# Contribute
Feel free to share new ideas to be added in application.
You can improve code or add new features and ask for implement.


