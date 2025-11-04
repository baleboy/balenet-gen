---
title:  Challenge accepted: write a game for the Garmin Forerunner 235
date:  2023-04-14
topics: programming, gaming, ai
---

My son got a hold of my [Garmin Forerunner 235](https://www.garmin.com/en-US/p/pn/010-03717-54) sports watch and immediately found a [FlappyBird clone](https://apps.garmin.com/en-US/apps/baff701c-a71e-4854-bf0e-5a775793a838) in the Garmin Connect app store. He wanted to make a game of his own and went as far as installing the Garmin SDK and VS Code following a [tutorial](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=video&cd=&cad=rja&uact=8&ved=2ahUKEwjp09Cblav-AhWJuosKHSbqBf8QtwJ6BAgJEAI&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D_sHBqQKpIZg&usg=AOvVaw1F1FyR10Uw1RRgL3d1Z8kV) he found on the net. That's motivation! For a while I've been looking for an excuse to get him into programming and this seemed like the perfect one, so I decided to accept the challenge.

Applications for Garmin watches are written using a programming language called [Monkey C](https://developer.garmin.com/connect-iq/monkey-c/)  similar to Javascript (I don't quite understand why they had to go invent their own and not just use Javascript or some other language). The SDK comes with a plug-in for Visual Studio Code and a simulator. The whole thing works pretty well out of the box even on Mac. [Garmin's developer site](https://developer.garmin.com/connect-iq/overview/) does a good job explaining how to get started.

This being 2023 I had to start with Chat GPT. I asked "I want to write a game for the Garmin Forerunner 235. How do I make an animation?" and got some unsatisfactory answers about using the animation API which were a) wrong and b) not useful because the animation API is not available for the FR 235 (Update: after finishing this article I tried asking the better question "please write a program for the Garmin Forerunner 235 that shows a simple 2D side-scrolling game" to ChatGPT4 and got a much better answer).

Luckily I realised that the [source code for Flappy Bird](https://github.com/Tkadla-GSG/garmin/tree/master/FlappyBird) is available, which was much more useful :) Taking that as a starting point, I was able to come up with a first basic scroller pretty quickly. Along the way I decided to test another AI tool, GitHub Copilot, and I was blown away. It was like it was reading my mind. It really [rekindled my love of coding](https://visualstudiomagazine.com/articles/2023/03/23/vs-ai.aspx?m=1&utm_source=pocket_saves).

For the graphics I used a free, web-based sprite editor called [Piskel](https://www.piskelapp.com), which worked pretty well. Here is what the design of the main character looks like in Piskel:

![Schermata 2023-04-15 alle 10.22.26.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/0cad32e4-23d7-41c2-94fb-61c4fc429381/1715a2a6-14ab-4a1f-8cdd-12b8ca99b6cc)

Following the principles of [semantic compression](https://caseymuratori.com/blog_0015), I first coded the whole game in one main function until it worked, and then refactored it in a more sensible form. Interestingly, as I added more classes I ended up running out of memory. Looking around Stack Overflow this seems to be a common problem, and one of the first advices under the "how to reduce the memory usage of my Garmin app" is "get rid of classes". Still, I didn't want to give up on my beautiful design and instead limited the number of colours for each sprite. 64K (the memory limit for apps in the FR235) should be enough for anybody!

To build, go to VS Studio commands and pick "Monkey C build for device". Deploying to device was a matter of copying the .prg file to APPS in Finder.

See the final result in the video below. The source code is [here](https://github.com/baleboy/dinorun).

[Dino Run demo](https://www.youtube.com/watch?v=0uov3UpYojE#embed)

