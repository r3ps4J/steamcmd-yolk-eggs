#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'ghcr.io/r3ps4j/steamcmd-yolk:root'

##
#
# Variables
# STEAM_USER, STEAM_PASS, STEAM_AUTH - Steam user setup. If a user has 2fa enabled it will most likely fail due to timeout. Leave blank for anon install.
# WINDOWS_INSTALL - if it's a windows server you want to install set to 1
# SRCDS_APPID - steam app id found here - https://developer.valvesoftware.com/wiki/Dedicated_Servers_List
# SRCDS_BETAID - beta branch of a steam app. Leave blank to install normal branch
# SRCDS_BETAPASS - password for a beta branch should one be required during private or closed testing phases.. Leave blank for no password.
# INSTALL_FLAGS - Any additional SteamCMD  flags to pass during install.. Keep in mind that steamcmd auto update process in the docker image might overwrite or ignore these when it performs update on server boot.
# AUTO_UPDATE - Adding this variable to the egg allows disabling or enabling automated updates on boot. Boolean value. 0 to disable and 1 to enable.
#
##

# Install packages. Default packages below are not required if using our existing install image thus speeding up the install process.
#apt -y update
#apt -y --no-install-recommends install curl lib32gcc-s1 ca-certificates

## just in case someone removed the defaults.
if [[ "${STEAM_USER}" == "" ]] || [[ "${STEAM_PASS}" == "" ]]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
${STEAMCMDDIR}/steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) ${INSTALL_FLAGS} validate +quit ## other flags may be needed depending on install. looking at you cs 1.6

## add below your custom commands if needed
## cleanup movies?
rm -rf /mnt/server/ShooterGame/Content/Movies

## touch log file
mkdir -p /mnt/server/ShooterGame/Saved/Logs
echo "--fresh install--" >> /mnt/server/ShooterGame/Saved/Logs/ShooterGame.log

## install end
echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"
