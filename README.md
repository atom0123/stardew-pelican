My initial attempt at creating a Pterodactyl Panel egg for Stardew Valley.

Most of this code is from https://github.com/huntercavazos/stardew-multiplayer-docker so all credit goes to them, and they are the real MVP. 

I have no experience ever making Docker containers, this was first attempt.

Current issue is when starting Docker, I get this error "s6-mkdir: warning: unable to mkdir /var/run/s6: Read-only file system" since I believe Ptero launches Docker containers as read only.
Permissions are my downfall, no clue how to fix. If anyone has ideas, all ears.


If you are trying to recreate, the install_script.sh is what you copy and paste into the install script section of creating a new egg. Ensure you use the debian installer
and entrypoint command from bash.
