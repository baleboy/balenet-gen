---
title: How I finally got into vibe coding
date: 2025-11-06
topics: ai, programming
---

My experience with AI assisted coding until now was limited to Github Copilot’s autocomplete and copying and pasting code between my editor and ChatGPT. This however is how AI coding was done a year ago, nowadays the hot topic is agentic coding and its radical cousin, vibe coding. I had not really grasped agentic coding until now, but a few weeks ago at work we had a workshop with Claude Code and things started to click, so I decided to give it a try for my personal projects, namely this website.

“Agentic coding” means that the program is done by an AI agent under your direction. The agent doesn’t limit itself to writing code, it builds it, runs it, tests it and makes changes based on the results. It’s basically a loop of executing prompts, running tools and embedding the results in the next prompt. Until a short time ago the tool of choice for this approach was the Cursor IDE, but recently some terminal-based tools have appeared, first and foremost Claude Code by Anthropic and its competitor ChatGPT Codex. The fact that they are terminal-based means that you are not limited to a specific IDE and that the tool has access to all the commands in your system (prior authorization).

## Sticker shocker: first test with Claude Code

Installing Claude Code was very easy with NPM, and I was soon presented with the first choice: how to be billed. The monthly plan is insanely expensive at 200USD per month, but there is also a usage-based plan enabled by giving your anthropic API key to Claude Code which is what I picked.

My first task was to make it possible to run my generator from the command line. Since it’s written in Swift I’ve used XCode to develop it, but I couldn’t easily figure out how to install it in my executable path, so I asked Claude to give me a few options and somehow (I’ve lost the chat unfortunately) ended up selecting a solution based on Make. After some back and forth, Claude created a Makefile that was able to build the tool and install it in my /usr/local/bin folder, without ever having to open the IDE. Cool! Out of curiosity I went to check my Anthropic Console and found out that this 10 minute exercise had cost me three dollars! 

## Sippin’ rocket fuel with ChatGPT Codex

I was ready to give up at this point, but decided to give a try to OpenAI’s equivalent tool, called Codex, which I could use without extra cost since I’m already a ChatGPT Pro subscriber (at 20USD per month). Installation was again easy and the whole experience felt very similar to Claude Code. In the AI arms race, companies are one-upping each other and replicating each other’s offerings, with the exception of Apple who is way behind.

Happily I didn’t see much of a difference with Claude Code, so I continued along this path, reassured by the knowledge that my wallet was safe.

The next thing I wanted to do was take the templates out of the generator and make them editable without having to recompile. I explained it briefly and Codex did it without trouble. I had a working solution in one shot. I started to notice that completing a task takes time. The agent thinks, then edits, then thinks some more, then builds, etc. It takes several minutes to complete this cycle, which is why people tend to launch multiple agents in parallel. I think this workflow is perfect for today’s level of attention span, since I could browse the web while waiting without having to feel guilty. But is this what all this technology is giving us? The freedom to waste time on the internet? 

Anyway, at this point I was really getting into the groove, and started to come up with features just for the sake of it. I had become a power-hungry product manager! In rapid succession I asked for categorization of posts by topic, automated tests, automated publishing via FTP, more Spectrum-like look and feel… the agent did all this nearly flawlessly. The visual part is what I had the most trouble with, the CSS wasn’t always correct or doing what I had asked, and it was harder to describe what I wanted without showing pictures as I did in some previous experiments using the ChatGPT UI (later I found out that you CAN give pictures to Codex as well). But nevertheless the speed of development was breathtaking, I implemented things in a few hours that would have taken me several days otherwise. The hardest part was to restrain myself.

## Some reflections

Despite my best intentions, I quickly drifted to vibe coding. I quickly lost track of where the code was going, which made me anxious, and, most importantly, learned absolutely nothing. It felt like cheating at a videogame. So I started to accept everything the agent was doing without checking and asked for changes after testing. 

Sometimes the agent does its own thing even if you didn’t ask. For example at some point I had changed the “work” link to “projects” and after a while I realized that it had silently changed it back. Since the agent is also in charge of writing the tests, I wouldn’t trust it not to update the tests to make it look like everything is fine. This is a common complaint and another source of anxiety when developing software this way. The whole thing feels like standing on shifting sands.

## Final touches and moving to a new host

The next step was asking Codex to help me improve the search ranking of my site, which wasn’t showing up on Google when searching for my name. It suggested adding a robots.txt and a sitemap, and was happy to implement sitemap support in the generator, another of the features in my backlog that I thought about doing “some day”.

Troubleshooting was also very effective. At one point one of the fonts I used wasn’t displayed correctly on mobile, and  Codex suggested converting it to WOFF using the Python-based fonttools package. I asked it to install the tool, do the conversion and update the website, and after that everything worked.

I thought I was done, but while checking the site I noticed that some of the images were missing or corrupted. I tried publishing again but it didn’t help. Codex tried to harden the script (which uses lftp) in various ways but was unsuccessful. Finally I tried Filezilla and got the same result! I couldn’t figure out what was wrong, but I blame FTP and/or my cheapo ISP. I decided to move to a more modern way to publish the site. 

I asked Codex and it suggested Netlify and Github Pages. Since I’m already using Github, I figured that it would be the easiest and asked Codex for the steps needed, and to execute them. I also had to configure the DNS records to point to the new location. Here Codex gave me the right instructions, but I couldn’t make the site load from the new place. Here another AI came to my aid, the Github chatbot which checked the DNS record and told me exactly what I needed to do (remove the AAAA records). After a few resubmissions, everything started to work, and the site is now served via Github pages.

## Coding from anywhere!

Both Claude Code and Codex offer a web-based version, which runs the agentic session in a VM in the cloud. At first I couldn’t see the point: why would I do this from a browser when I anyway need to run the program in my local environment? But later, while I was out, I started to have ideas about the next feature and I used the Cloud version of Codex to tell it to start code it and the epiphany hit me: I could now give instructions to my agent from wherever I was, and let it work while I was doing the shopping or running errands. I’ve done this with meetings and chats for several years now, and now it has come to coding as well. Is this how work will look like a year from now?

## Conclusions

I am 100% sold on agentic coding for personal projects. I’m more hesitant about using it in a professional environment, because I would never inflict AI-generated code to my colleagues for review without first understanding it myself, and that might take as much time as writing it. I would feel more comfortable with Copilot style autocomplete. But it’s now clear to me that whatever happens to the AI hype, the software industry is going to change for good.
