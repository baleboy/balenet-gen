---
title:  A Giant Robot VR walking simulator PoC
date:  2026-10-25
topics: gaming, vr, hobbies
draft: true
---

Ever since VR became accessible, I've wanted to use it to experience the thrill of being inside some of my favorite japanese giant robot cartoons from the 80s. Today I gave it a shot with the help of AI, and the result wasn't too bad.

Back in Italy in the late 70s and 80s, Japanese animations featuring giant robots started to appear. The first was "Goldrake", original name ["Grendizer"](https://en.wikipedia.org/wiki/Grendizer), followed by ["Mazinga"](https://en.wikipedia.org/wiki/Mazinger_Z), ["Jeeg"](https://en.wikipedia.org/wiki/Steel_Jeeg) and many more, some better than others. They made a lasting impression on me and to this day I think about them with nostalgia.

They were also extremely unrealistic, so the idea of a "giant robot simulator" has some challenges. In the cartoons the robots run and jump like an athlete, but translated to a videogame, especially in VR, this loses the sense of scale that you expect these machines to instill. There is one recent game about Goldrake, called ["UFO Robot Grendizer - the feast of the wolves"](https://mazinger.fandom.com/wiki/UFO_Robot_Grendizer:_The_Feast_of_the_Wolves), which is not half bad, but after a while feels like any other 3rd person game except that the character looks like a robot. On the other hand, realistic movements are slow and boring, making the gameplay awkward. I'm sidetracking a bit here, but I want to give a shoutout to [Titanfall 2](https://en.wikipedia.org/wiki/Titanfall_2) for being the game that best embodies the power fantasy of piloting a giant mech (sorry Armored Core VI but you didn't do it for me).

This was a lengthy background for my latest weekend project, which started with a question: could I make a decent 3D model of a classic giant robot using AI? Turns out that not only I can, but it's really easy and the result is pretty good. I used [meshy.ai](https://www.meshy.ai/), an AI chatbot that taskes images as input and creates 3D models. I gave it these two images of Goldrake (sorry I can't call it Grendizer):

The resulting 3D model looked better than I expected. I thought the cartoonish design of the robot wouldn't translate well in 3D, but actually the metallic reflections look good.





Next step was to add a walking animation, also easy though with less stellar results.

Next step was to see this in VR: I gave the model to Claude Code and asked it to create a Web scene showing the model at the correct scale (it's supposed to be 30 meters tall), which it did pretty well. I also asked to add typical FPS controls and a "jetpack" mechanic to let me fly on top of the robot.

The initial camera view wasn't great. Here I realized what every game developer knows, which is that you don't know if something works until you try. So I asked Claude to use different camera angles and let me cycle through them at the press of a button. 

What next? Combat, proper model with detachable parts, best environment, entering sequence... so much to do! 





