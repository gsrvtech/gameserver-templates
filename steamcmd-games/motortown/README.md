# MotorTown

## Author & Contributers

| Name | Github Profile | Buy me a Coffee |
| ------------- |-------------|-------------|
| gOOvER | https://github.com/gOOvER |[Buy me a Coffee](https://donate.goover.dev) | |

## Game infos
- Steam Shop Link: [https://store.steampowered.com/app/1369670/Motor_Town_Behind_The_Wheel/](https://store.steampowered.com/app/1369670/Motor_Town_Behind_The_Wheel/)
- SteamDB Link: [https://steamdb.info/app/1369670/)](https://steamdb.info/app/1369670/
  
## PLEASE NOTE !!!!!

If you have Steam Guard enabled you will need to provide the code via command line. To do so follow these steps:

Once the Pterodactyl install console shows
```
Enter the current code from your Steam Guard Mobile Authenticator app
Two-factor code:
```

Then run the following commands: 
1. `docker ps` (to get your container id) 
2. `docker attach <container id>` (replace `<container id>` with the id from the previous command)

Once you have attached to the container you can then type the code and press enter. You should then see `OK` and installation will continue.

## Proton or Wine?
The repo contains a Proton and a Wine Egg.

**You should use the Proton egg**. However, there are systems on which Proton does not run. These should then use the Wine Egg

## Server Ports

The MotorTown server requires two ports. One as Gameport; one as QueryPort. You can use every port you want.

| Port | default |
|-------|---------|
| Game | USE, what you want |
| Query | USE, what you want |

  

## Minimum Specifications
- At least 12GB RAM (Windows Server needs lesser RAM)
- Minimum 4GB hard disk space


## Support
Support only in my Discordserver

[![Join our Discord server!](https://invidget.switchblade.xyz/raurR4vshX)](http://discord.gg/raurR4vshX)

## Homehosting

I cannot and will not provide support for servers that are hosted at home. The reason is that 99% of the errors are due to incorrect network settings and there are many different configurations.
Unfortunately, I don't have the time to debug such errors, because it takes many hours.

## Licence
This Egg is licensed under the AGPLv3 licence.
