---
title:  Crosswalk Project, 2013-2017
order: 6
image: crosswalk-logo.png
---

Intel has long been a believer in Web Technologies, as shown in the large number of contributions to the Chromium Browser, the active role in W3C standardization and its commitment to Chromebooks. In 2013 Intel launced an open source, cross-platform web runtime project called Crosswalk [Crosswalk](https://github.com/crosswalk-project/crosswalk), based on the Chromium browser and Blink engine. Blink had just been forked from WebKit and was still in its infancy, but Intel believed that it would be the future of web rendering and wanted to be part of it.

Cross-platform application development at the time was mostly done using web technologies and frameworks like [node-webkit](https://nwjs.io/) (another project by Intel) for desktop and [Phonegap/Cordova](https://cordova.apache.org/) for mobile, as well as Intel's own tool called Intel XDK (the rebranding of an acquisition that was later discontinued). Tizen, a joint project by Samsung and Intel that I had previosuly worked on, also relied on web technologies for its 3rd party application development. All these projects used different web runtimes and the idea of Crosswalk was to provide a single platform for Windows, Linux, Android and Tizen, based on modern web standards. 

The desktop flavor never quite picked up, but the mobile runtime on Android was moderately successful. At peak the runtime was used by 14000 Android applications with a few millions combined downloads, which is not a lot by any standard but still remarkable considering that there was almost no marketing. Some popular frameworks used the project, for example [Ionic](https://ionicframework.com/), [Appgyver](https://www.appgyver.com/) and [Construct](https://www.construct.net/en), as well as Intel's own XDK. The [Wikpedia page for Crosswalk](https://en.wikipedia.org/wiki/Crosswalk_Project) lists all of the downstream projects.

Eventually the project stopped making sense for Intel and was terminated. One reason was that Android's platform Webview started to get better, making it more viable for application development. Also, the so-called [Progressive Web Apps](https://en.wikipedia.org/wiki/Progressive_web_app) were becoming popular and there was less need for packaged web apps, which is also why [Phonegap](https://cordova.apache.org/announcements/2020/08/14/goodbye-phonegap.html) and the [Intel XDK](https://community.intel.com/t5/Software-Archive/RETIRED-Intel-XDK/td-p/1075483) were discontinued a few years after.

## What I did

I was the program manager for Crosswalk for the duration of the project, from 2013 to 2017. My primary responsibility was making plans and monitoring them, reporting, aligning with the rest of the company and working on process development. The team was around 20 people including QA, distributed between the US, Europe and China.

One of the first things I had to do was move our issue tracking from Github to Jira, because github issues couldn't meet the requirements posed by Intel's processes. The developers weren't happy about this so to sweeten the pill I took it upon myself to implement Github hooks to update Jira automatically based on the status of pull requests (my commit is still visible [here](https://github.com/crosswalk-project/crosswalk-github-webhooks/commit/7700ef5540746445163c2f765d1c96e387639d8e)). Today there are plugins to do it, but at the time those that existed didn't work very well.  

Because the project wasn't big and the team knew what to do, I had time to get involved in "developer outreach", meaning that I interacted with users on our mailing list, conducted surveys about what feature were most needed and presented the project at meetups and conferences. Here is a video from Phonegap Days in Amsterdam:

[Phonegap Days](https://www.youtube.com/watch?v=s_3gUHwg4ms#embed)

## What I learned

Despite the questionable business value, Crosswalk was a great experience for me and I learned a lot from it. I met some of the best engineers I have ever worked with, and I still work with some of them today. I was able to get hands-on, learned about modern web technologies and saw what a strong technical team with good product sense can do. I was exposed to the Chrome release cycle and release channels, which we adopted for Crosswalk and I still consider the best release process I have seen.
