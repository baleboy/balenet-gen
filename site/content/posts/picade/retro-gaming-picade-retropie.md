---
title: Retro gaming with Picade, Raspberry Pi 4 and Retropie
date:  2022-10-10
topics: gaming, tech
---

## Introduction

Ever since I first installed MAME on my computer back in 2006, I've been on a on-and-off quest to recreate the arcade games of my childhood (mainly the 80s) as faithfully as possible.

A couple of years ago I discovered and bought the Picade, which is a small replica of a classic arcade cabinet built with modern components, complete with screen, joystick and buttons. Lately I picked it up again and went through a new installation, and decided to document the experience.

There is nothing new here: everything I'm writing could be found out by reading the relevant projects' documentation and a couple of hours of googling, but if I ever go through this process again it will be useful to have it all in one place.

Here are the requirements that my ideal emulation system should satisfy:

- Allow me to play the arcade games that I used to play in the eighties
- Recreate the experience as faithfully as possible
- Allow me to cheat so that I can finally play the games to the end
- Present the games in an easy-to-use, nice-to-look-at library

## Setting up the Picade

The Picade doesn't come with a computing unit which you need to buy separately. Although at the time the Raspberry pi 3 was recommended, I thought that a Raspberry Pi4 would have more performance and since it was said to work I went for that. However at the time the recommended Linux distro, Retropie, didn't have support for RPI4, so I installed another emulator-oriented distro called Lakka which worked well enough. But I was left with the feeling that Retropie would be a better choice, which was confirmed recently when seeing a Retropie-based system at a friend's,  and since RPi4 is now supported, I decided to do a fresh install.

![IMG_3052 (kopio).jpg](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/3f2a4858-ca72-4ef9-aacc-2b34b5ed4866/98e10610-84c6-4d79-8c46-3a18080d8766)

## Retropie installation

Retropie is built on a collection of components that sometimes overlap. Because of this, configuration is spread across a multitude of different UIs and scripts that can make things a bit complicated.

First of all I made a backup copy of the current image, which was after all working pretty OK. I googled "back up a raspberry Pi SD card" and followed the instructions in the first link I found: [https://howchoo.com/g/nmexndnlmdb/how-to-back-up-a-raspberry-pi-on-windows](https://howchoo.com/g/nmexndnlmdb/how-to-back-up-a-raspberry-pi-on-windows)

Installation of Retropie is pretty well documented. I then went on to follow the instructions at the end of this page from Pimoroni: [https://learn.pimoroni.com/article/assembling-your-picade](https://learn.pimoroni.com/article/assembling-your-picade) and used the Raspberry Pi Imager: [https://www.raspberrypi.com/software/](https://www.raspberrypi.com/software/)

This installed Retropie 4.8, March 2022

Retropie is a Linux distribution customised for retro gaming on a Raspberry Pi. It bundles together several projects into one preconfigured experience.

The user interface is provided by Emulation Station, that is launched right after boot. ES lets you manage your collection of ROMs and launch various emulators. The emulators themselves are implemented behind the Libretro API and are managed (launched and configured) by the RetroArch project. ES talks to Retroarch via the Runcommand script.

This all works great, but the experience is not very consistent. For example the configuration is launched from a"Retropie" menu within  ES, and depending on what you are configuring it may launch a console-based GUI or the RetroArch GUI, which look different and handle controls differently.

![IMG_3053 (kopio).jpg](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/3f2a4858-ca72-4ef9-aacc-2b34b5ed4866/8cbc7cb5-de0d-4821-9b9c-7d1af6313f28)

## Enabling networking and SSH

In order to proceed with the rest of the configuration, network connectivity is needed. The best way to configure it is with a USB keyboard attached to the RPi, since the Picade's control won't work out of the box. Luckily I discovered that the Apple Magic Keyboard can be used as a regular USB keyboard, so I was able to proceed without the need for an extra keyboard.

After first boot you are shown the welcome screen of Emulation Station, asking to configure a controller. The Picade's joystick and button don't work yet, so we need to attach a USB keyboard and press F4 to enter the command line. From here we can run 'sudo raspi-config' to start the Raspbian configuration GUI. First we need to choose the WiFi region from "localisation" and then configure the WLAN SSID and password. This is also a good time to enable the SSH server, also from the Raspian UI, to be able to connect remotely later on (username: pi, password: raspberry)

Note: I read from [https://retropie.org.uk/docs/SSH/](https://retropie.org.uk/docs/SSH/) that one way to enable SSH in retropie is to edit the boot partition in the SD card from a regular computer via an SD card reader and add an empty file named "ssh". This and an ethernet connection would have been a way to configure the Picade remotely via SSH without a USB keyboard. However it didn't work for me, although I later discovered that the SD image had somehow gotten corrupted so maybe there was some other  issue.

Another thing to note is that I had to re-flash the SD twice during this process, and each time I had slightly different results even though the image was the same. For example, in one case the screen would go black as soon as I connected anything via USB, but this didn't happen again after re-flashing the SD.

## Configuring the Picade's controls

The Picade's joystick and buttons are connected to the RPi with a special breakout board called "Picade X-Hat" that needs some special setup. The installation is again described in this page:

[Assembling your 8" or 10" Picade with PICO-8](https://learn.pimoroni.com/article/assembling-your-picade)

The control configuration procedure is started by long-pressing any button on the Picade. ES lets you configure many buttons and controls (e.g. analog stick) needed for the console emulators, but they have no place in the picade. You can skip those by long-pressing any button.

After a few iterations, I ended up with the following button assignment:

![IMG_3035 (kopio).jpg](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/3f2a4858-ca72-4ef9-aacc-2b34b5ed4866/30c6c02d-a1ea-45b8-8268-e732ca8928be)

The "hot-key" is used to access some special functions and configurations while playing a game. For example "Hotkey + Start" exits the current game. The hotkey is handled by RetroArch and needs to be configured in its GUI, but it's easier to test it with some games, so let's get them installed first!

As the Picade documentation recommends, this is also a good time to decrease the default volume level, since it is pretty loud by default. This is done by pressing "Start" to bring up the ES menu. The audio device needs to be `PCM` and driver `Alsa`. Note that the `Audio` menu in the `Retropie` section of emulation station doesn't do anything since it is used to manage the onboard audio which is disabled when using the Picade. I found this annoying and figured out that it can be removed by deleting or renaming the file `/RetroPie/retropiemenu/audiosettings.rp`

## Getting some games

With the basics set up, the next step was to try some games. First of all, I needed to decide what emulator to use. There are several emulators for arcade games, but the two main choices are MAME and FinalBurn Neo. MAME focuses on accuracy of emulation, FB on performance and playability. Since a good playing experience is more important for me than fidelity of emulation, I went with FB Neo.

Games are copyrighted and you shouldn't download them, but in practice everyone does it and as long as you don't sell or redistribute them I guess it's OK. Googling "FB Neo ROMS" will lead you to the right place, another good source is the "ROM megathread" from Reddit:

[/r/Roms Megathread](https://r-roms.github.io/)

Eventually I downloaded the full 7000+ ROM set (17GB!) for FB Neo and was faced with the interesting challenge of choosing which ones to install. Transferring all of them would be possible, but picking the right ones from the ES UI would be a pain, plus some are really bad and not worth the disk space.

I resorted to "best of classic arcade games" lists such as this:

[https://www.boredpanda.com/best-arcade-games/](https://www.boredpanda.com/best-arcade-games/?utm_source=google&utm_medium=organic&utm_campaign=organic)

The list I came up with is a mix of historically relevant (Space Invaders), top-rated (Cadillacs and Dinosaurs) and nostalgia-infused (Bubble Bobble, Shinobi, Street Fighter) games. You can find it [here](https://github.com/baleboy/picade-configs/blob/master/emulationstation/gamelist.xml) (in XML!).

ROMs are saved in the `RetroPie/roms/arcade` folder that is not specific to any emulator, but the default seems to be FB Neo. I transferred them one by one via SSH, but there is a neat way to do it by plugging a USB stick in the Retropie as described here:

[https://retropie.org.uk/docs/Transferring-Roms/](https://retropie.org.uk/docs/Transferring-Roms/)

Choosing the correct ROM file is not trivial. Games used to have a lot of variants (e.g. US, Europe or Japan) and the ROMs for each of these are almost identical, so ROM "packagers" typically distribute them as one main ROM file and small variant files that include only the delta, referencing back to the main one. This is done to save disk space, but the result is that if you only want to play any one variant, you need two ROMs and both will appear in your game list, which is annoying. The alternative are the self-contained "merged" ROMs, but they take more space.

In my case I didn't care about variants and wanted to play the main game only, so split or merged didn't make any difference. The tricky part was to find the correct file. Typically this is the one with the name of the game with no additional letters at the end, e.g. `bublbobl.zip` (main) as opposed to `bublboblr.zip` (Japan).

Mapping a game's title to the ROM filename is also not trivial because names are shortened, usually it's pretty obvious but for the hard ones I used the search engine at:

[https://wowroms.com](https://wowroms.com)

Of all the games in my list, only Paperboy wasn't supported by FBNeo. To work around that, I downloaded the MAME ROM for Paperboy and selected MAME as the emulator from the Runcommand menu the first time I lunched this ROM.

## Configuring Retroarch

Retroarch manages everything about a running game, and it has a lot of tweaks and options that are configured through the Retroarch GUI. The GUI can be started from the `Retropie` menu in EmulationStation, or from within the game with `Hotkey +X`. By default you need to remember to save manually but there is an option to do so automatically on exit. Settings can be global, per "core" (emulator) or per ROM.

### Hotkey mapping

Retropie's documentation lists the following hotkeys:

![Näyttökuva 2022-11-6 kello 11.25.00.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/3f2a4858-ca72-4ef9-aacc-2b34b5ed4866/91293ed5-a91d-4502-a8ca-73f0a03adc64)

All of them are useful and worked out of the box, except for the Save and Load that I had to configure to the RS and LS. `Save` and `Load` let you save your progress in the game, and the data is saved in "state slots". You can move to another save slot by pressing Hotkey and left or right.

The other Hotkey that I found useful is `Pause` which I assigned to `Hotkey + Y`.

### Shaders

One thing you may notice is that the games look sharp and pixelated, more than they used to in their original form and in your memory. The reason for that is that the originals played on CRT monitors and where not designed for today's LCDs. Designers took advantage of the limitations and artefacts of CRT monitors to make the low pixel count less impactful. Of course the good people who developed the emulators thought of a way around that. Enter: shaders.

Shaders are little programs executed for each pixel of the image, used to achieve "post-processing" effects. Retroarch supports shaders and Retropie comes with several pre-defined shaders. Some of them recreate the scan lines, blur and even curvature of CRT monitors, without virtually any impact on performance, even on the RPi's somewhat limited GPU.

As usual, the Retropie documentation explains this better than I ever could:

[Shaders and Smoothing - RetroPie Docs](https://retropie.org.uk/docs/Shaders-and-Smoothing/)

One thing that I found particularly impressive is that some of the vertical-scrolling games (so-called vertical games) were played on a TV screen rotated by 90 degrees. For those games, the shaders will also be rotated automatically and the scanlines will be vertical!

Shaders are configured from the RetroArch GUI, which can be launched either from within the game (`Hotkey + X`) or from the Retropie menu in ES. Shaders can be per-game, per-core (i.e. emulator) or global. I chose the `zfast-crt` shader and configured it to be global. (global presets)

### Latency

With graphics more or less sorted out, the next difference you will notice compared to the original games is that the controls are not as responsive. Partly this is because of the hardware (the switch-based joystick and buttons that come with the Picade are not as robust and quick as in the original arcades) and partly it's because of latency introduced by the different software layers, drivers etc.

See the Retropie documentation for a thorough discussion about latency:

[Input Lag - RetroPie Docs](https://retropie.org.uk/docs/Input-Lag/)

It's basically a choice between low input latency and smooth framerate. Typically, to avoid glitches graphics engines use an amount of buffers to draw the next frames off-screen before they are displayed, but this means that an action from the player may take two or three frames before its effect is displayed. On the contrary, drawing and showing frames in the next frame after the player's action means that you have less time to draw it and may end up with an incomplete frame. Since the games in question are mainly 2D with low resolution, I had a hunch the RPi4 should able to handle them without too much buffering and that low latency can be prioritized.

Retroarch gives a lot of control on the way the content is displayed, but different tweaks have different effects on each game. Since Bubble Bobble is the game I always go back to, and since higher latency has a very visible effect on the gameplay, I focused my experiment on that.

After some trial and error I came up with the following settings:

![IMG_3051 (kopio).jpg](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/3f2a4858-ca72-4ef9-aacc-2b34b5ed4866/e724f7c0-5c1f-46cb-8e1e-fda8946dd83b)

In the above, I changed the default values for Max swap chain images, Hard GPU Sync, Run-ahead. Frame delay is often quoted but I thought since I have automatic frame delay I wouldn't need to touch it (turned out to be true). See this article for more about automatic frame delay:

[RetroArch’s new automatic frame delay setting makes low input lag easier](https://www.pcgamesn.com/emulation/retroarch-input-lag-automatic-frame-delay)

I couldn't pinpoint one setting that would have a bigger impact than the others, all of them somehow contributed in what looked like the best responsiveness. I didn't play around with Polling behaviour or Game mode (which requires the installation of a dedicated daemon) as I was pretty happy with the results I got.

I also set the `CPU governor` to `performance` in the Runcommand options accessed from the main configuration menu.

To see how much the latency optimizations were affecting the frame rate, I enabled the FPS counter in retroarch from the `notifications` menu. Bubble Bobble ran at a consistent 60 FPS without issue.

### Game overrides

Even for the same emulator, the same latency settings may not work for all the games in the same way. For example for Striker 1945, a game from 1997 that I assume has tougher system requirements, the settings described above resulted in 37 FPS and a glitchy look whereas in this case triple buffering an no GPU sync give much smoother frame rate and no visible gameplay impact. For cases such as these, settings can be saved as "game overrides" from the "Overrides" menu in the Retroarch GUI.

Game overrides can be useful also for customised control schemes or shaders.

## Configuring EmulationStation

With the games installed and working well, the remaining tweaks are about the look and feel of the user interface of the system itself, which is managed by EmulationStation.

### Scraping

There is one more neat thing to do once you have some games in the system: adding some metadata, like thumbnails, descriptions and ratings, to make your list more lively. This is done via "scrapers", little scripts that go through your game list and download the needed info from dedicated websites such as "TheGamesDB.net". Scrapers are a feature of ES and documented in the Retropie docs here:

[Scraper - RetroPie Docs](https://retropie.org.uk/docs/Scraper/)

Scrapers are launched from ES's pop-up menu (opened with the "start" key) and obviously require an internet connection. Scraping works really well and makes your games list look much better.

### Themes

The ES UI can be styled with a number of themes that can be downloaded from the "ES Themes" item in the Retropie menu.

I chose the "Pixel-metadata" theme because its retro look is consistent with the games I'm playing. I wish that there was a way to enable shaders also for the ES UI, so as not to break the illusion of using an old-school CRT monitor, but this is not supported at the moment, although it seems I'm not the only one who thought about it:

[Using Shaders on Emulation Station Menu](https://retropie.org.uk/forum/topic/19113/using-shaders-on-emulation-station-menu)

### Runcommand and Splash screens

By default, when a game is launched Retropie shows a text window with some information related to the RunCommand script. Pressing a button while the window is visible opens the RunCommand menu to configure the launch options for the game, for example the default emulator, which was useful to configure the MAME ROM for Paperboy.

Special cases aside, the window looks quite ugly and is best removed, which can be done from the RunCommand  configuration entry in the Retropie menu in ES. There is also an option to display the game's "cover" as a splash screen, which I think is pretty neat.

## Adding a second controller

The Picade has only one controller, but it's possible to add more by plugging one or more gamepads in the USB ports of the Raspberry Pi. Retropie supports most controllers, wired and wireless, out of the box. I used a PS4 Dualshock plugged via USB and it was recognised flawlessly. However by default the controller gets mapped to Player 1. To direct it to Player 2 I had to enter the Retroarch configuration, and under "controls" set the Player 1 controls to "none" and player 2 to "Gamepad". This is because the Picade's controls are mapped to the keyboard and not a gamepad.

To be honest the Dualshock is a much better controller than the Picade's, and if this was about comfort I would use that. In retrospect, a Raspberry with plugged-in USB controllers and an external display might be a better choice than the Picade, especially if one wants to play also 8-bit console games. This may become my next project/time&money sink.

## Conclusions

Here is the result in action!

[Picade video](https://www.youtube.com/watch?v=aR743f-DuGk#embed)

All in all I'm very happy with my Picade setup, but I have to admit that the experience is still not the same as playing the original arcade games. Also, after the initial novelty of playing those old arcade games without limits, I haven't touched the picade in months. 

It is very easy to mess up the configuration while trying out different things, so it's a good idea to make a backup of the image and/or the configuration files. One advantage of running on Linux is that you can use all the usual Linux tools to manage your system. For example I installed git with apt and backed up my config files to Github: [https://github.com/baleboy/picade-configs](https://github.com/baleboy/picade-configs)

For an even more faithful experience, I discovered the [MiSTer FPGA](https://www.retrorgb.com/mister.html) project. This recreates the arcade machines in FPGA rather than emulating them, and the results are apparently really good. I'm not sure if I'll ever get around to building one, but it's definitely on my list.
