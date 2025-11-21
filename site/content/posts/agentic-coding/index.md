---
title: How I finally got into coding agents
date: 2025-11-06
topics: ai, devlog
---

My experience with AI assisted coding until now was limited to [Github Copilot’s autocomplete](/posts/garmin-game/) and [copying and pasting code between my editor and ChatGPT](/posts/ai-designed-this-app/). This however is how AI coding was done a year ago, nowadays the hot topic is agentic coding and its radical cousin, vibe coding. I had not really grasped agentic coding until now, but a few weeks ago at work we had a workshop with Claude Code and things started to click, so I decided to give it a try for my personal projects, namely this website.

“Agentic coding” means that the program is written by an AI agent under your direction. The agent doesn’t limit itself to writing code, it builds it, runs it, tests it and makes changes based on the results. It’s basically a loop of executing prompts, running tools and embedding the results in the next prompt. Until a short time ago the tool of choice for this approach was the Cursor IDE, but recently some terminal-based tools have appeared, first and foremost Claude Code by Anthropic and its competitor ChatGPT Codex. The fact that they are terminal-based means that you are not limited to a specific IDE and that the tool has access to all the commands in your system (prior authorization).

## Sticker shocker: first test with Claude Code

Installing Claude Code was very easy with NPM, and I was soon presented with the first choice: how to be billed. The monthly plan is insanely expensive at 200USD per month, but there is also a usage-based plan enabled by giving your anthropic API key to Claude Code which is what I picked (update: there is actually a 20USD plan comparable to OpenAI's, and that's what I'm using at the moment).

My first task was to make it possible to run my generator from the command line. Since it’s written in Swift I’ve used XCode to develop it, but I couldn’t easily figure out how to install it in my executable path, so I asked Claude to give me a few options and somehow (I’ve lost the chat unfortunately) ended up selecting a solution based on Make. After some back and forth, Claude created a Makefile that was able to build the tool and install it in my /usr/local/bin folder, without ever having to open the IDE. Cool! Out of curiosity I went to check my Anthropic Console and found out that this 10 minute exercise had cost me three dollars! 

## Sippin’ rocket fuel with ChatGPT Codex

I was ready to give up at this point, but decided to give a try to OpenAI’s equivalent tool, called Codex, which I could use without extra cost since I’m already a ChatGPT Pro subscriber (at 20USD per month). Installation was again easy and the whole experience felt very similar to Claude Code. In the AI arms race, companies are one-upping each other and replicating each other’s offerings, with the exception of Apple who is way behind.

Happily I didn’t see much of a difference with Claude Code, so I continued along this path, reassured by the knowledge that my wallet was safe.

The next thing I wanted to do was take the templates out of the generator and make them editable without having to recompile. I explained it briefly and Codex did it without trouble in fact I had a working solution in one shot. 

At this point I was really getting into the groove, and started to come up with features just for the sake of it. I had become a power-hungry product manager! In rapid succession I asked for categorization of posts by topic, automated tests, automated publishing via FTP, more Spectrum-like look and feel… the agent did all this nearly flawlessly. The visual part is what I had the most trouble with, the CSS wasn’t always correct or doing what I had asked, and it was harder to describe what I wanted without showing pictures as I did in some previous experiments using the ChatGPT UI (later I found out that you CAN give pictures to Codex as well). But nevertheless the speed of development was breathtaking, I implemented things in a few hours that would have taken me several days otherwise. The hardest part was to restrain myself.

## Final touches and moving to a new host

The next step was asking Codex to help me improve the search ranking of my site, which wasn’t showing up on Google when searching for my name. It suggested adding a robots.txt and a sitemap, and was happy to implement sitemap support in the generator, another of the features in my backlog that I thought about doing “some day”.

Troubleshooting was also very effective. At one point one of the fonts I used wasn’t displayed correctly on mobile, and  Codex suggested converting it to WOFF using the Python-based fonttools package. I asked it to install the tool, do the conversion and update the website, and after that everything worked.

I thought I was done, but while checking the site I noticed that some of the images were missing or corrupted. I tried publishing again but it didn’t help. Codex tried to harden the script (which uses lftp) in various ways but was unsuccessful. Finally I tried Filezilla and got the same result! I couldn’t figure out what was wrong, but I blame FTP and/or my cheapo ISP. I decided to move to a more modern way to publish the site. 

I asked Codex and it suggested Netlify and Github Pages. Since I’m already using Github, I figured that it would be the easiest and asked Codex for the steps needed, and to execute them. I also had to configure the DNS records to point to the new location. Here Codex gave me the right instructions, but I couldn’t make the site load from the new place. Here another AI came to my aid, the Github chatbot which checked the DNS record and told me exactly what I needed to do (remove the AAAA records). After a few resubmissions, everything started to work, and the site is now served via Github pages.

## Coding from anywhere!

Both Claude Code and Codex offer a web-based version, which runs the agentic session in a VM in the cloud. At first I couldn’t see the point: why would I do this from a browser when I anyway need to run the program in my local environment? But later, while I was out, I started to have ideas about the next feature and I used the Cloud version of Codex to tell it to start code it and the epiphany hit me: I could now give instructions to my agent from wherever I was, and let it work while I was doing the shopping or running errands. I’ve done this with meetings and chats for several years now, and now it has come to coding as well. But why stop there? Just give the Jira backlog to the agent and let it work while you drink pina coladas. This is why I think that OpenAI will buy Linear, you’ve heard it here first!

The next day at work I wanted to update this post but would have to wait until I got home. But wait, I fired up Codex Web, asked it how to make the publishing run from a github action, and after checking the plan told it to implement it. Within minutes I had "publish on commit" working and I could edit my site from within Github's text editor. I haven't had my mind blown like this in a very long time.

## Conclusions

It is clear to me that these tools are here to stay, and I am in awe of what they can become considering how much they have already evolved in the last couple of years. My Linkedin feed is full of skeptics and detractors, but I can only assume that they haven't given this a serious look, because I don't see how they couldn't be as enthusiastic as I am otherwise.

There are pitfalls and downsides of course. Despite my best intentions, I tended to drift into vibe coding. I quickly lost track of where the code was going, so I started to accept everything the agent was doing without checking and asked for changes after testing. But by doing this I didn't learn anythign at all, which was the main reason for developing my own generator in the first place.

Sometimes the agent does its own thing. For example at some point I had changed the “work” link to “projects” and after a while I realized that it had silently changed it back. Since the agent is also in charge of writing the tests, I wouldn’t trust it not to update the tests to make it look like everything is fine. This is a common complaint and another source of anxiety when developing software this way. Especially long contexts tend to deteriorate and give diminishing returns. The whole thing feels like standing on shifting sands after a while.

It takes a while for the agent to complete its tasks: it thinks, then edits, then thinks some more, then builds, etc. It takes several minutes to complete this cycle, which is why people tend to launch multiple agents in parallel. I think this workflow is perfect for today’s level of attention span, since I could browse the web while waiting without having to feel guilty. But is this what all this technology is giving us? The freedom to waste time on the internet? 

While I am 100% sold on agentic coding for personal projects, I’m more hesitant about using it in a professional environment. I would never inflict AI-generated code to my colleagues for review without first understanding it myself, and that might take as much time as writing it. I would feel more comfortable with Copilot style autocomplete. 

But as a manager with rusty techincal skills, I think I am the perfect audience for these tools. Giving instructions and writing clear Jira tickets suddenly becomes a useful skill! No more being ignored by rebellious devs! I feel like I trained for the past 15 years for this.

Finally, just a few days ago a [new episode of Pragmatic Programmer](https://newsletter.pragmaticengineer.com/p/beyond-vibe-coding-with-addy-osmani) came out, with an interview with Addy Osmany about AI-assisted coding. He explains many of the things I tried to write here, in a much better way.
