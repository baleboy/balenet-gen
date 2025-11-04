---
title:  Conway's law is a thing (notes on Team Topologies)
date:  2024-02-28
topics: books, management
---

I dislike it when people quote "laws", "rules" and other platitudes related to software engineering. Often they are a way to kill a discussion, or just hide the fact that you don't know what you are talking about. ["Adding people to a late project only makes it later"](https://en.wikipedia.org/wiki/Brooks's_law), ["You can't produce a baby in one month by getting nine women pregnant"](https://www.goodreads.com/quotes/172818-you-can-t-produce-a-baby-in-one-month-by-getting), ["the Pareto principle"](https://en.wikipedia.org/wiki/Pareto_principle) have all been thrown at me at times that I found unhelpful. In the worst case, the discussion turns into a pissing contest about who knows more of these rules.

I had a similar reaction a while ago when someone brought up [Conway's law](https://en.wikipedia.org/wiki/Conway%27s_law): "Organizations design systems that mirror their own communication structure". The context was that we had an internal engine that had to be turned into an SDK, while at the same time supporting the development of applications that were already using it. There was no "engine team", but people with experience with the engine were scattered in different SDK and application teams. The theory was that by putting all the engine experts into one team that provided a service to the other teams, we would have achieved better results. I resisted, partly because the change would have been too disruptive and we had challenging commitments to meet, but also because I was afraid that we would end up spending our time debating priorities for the engine instead of making progress. I also tend to prefer "feature teams" that work together to deliver something directly to a customer, although I must admit that I have seen very few successful applications of this principle (see further below).

The result however was that the "engine" never really became an independent component, which made it a lot harder to make it a separate product. Had I arranged the teams as it was suggested from day 1, we would probably have ended with a much better separation between the components. However we would also have amassed months of delay.

It turns out that not only Conway's Law is true, but someone wrote a whole book about the topic. Enter "[Team Topologies](https://teamtopologies.com)", aka TT.

Team topologies is basically a 200 pages treatment of Conway's law. The main takeaways are:

- The way you organize your team will match the software architecture of your product. This means that the people deciding the organization need to be experts in software architectures as well
- There are four main types of teams: stream aligned, complicated subsystem, enabling, platform
- There are also different types of team interactions: collaboration, X as a service, facilitating
- The size of a team should be such that the cognitive load for the team is no more than they can handle (i.e. a team shouldn't be responsible for too many things)
- Optimize your teams and communication for maximum flow, i.e. teams need to be able to ship without waiting on anybody else

My "engine" case above is an example of the tension between a "collaboration" model optimized for flow, and a "X as a service" model. X as a service requires very good product management (i.e. prioritization) and leads to slower innovation, which is exactly the thing I was worried about. The technique of arranging the team to force the desired architecture is called "reverse Conway maneuvre".

"Optimizing for flow" means that teams need to be able to ship their feature without waiting on anybody else. If you need testing, design, database, CI and so forth, the people who can do that need to be part of the team. This is great, but quickly falls apart when your software is divided in components with different technologies, e.g. a kernel module, a graphics engine and a UI. In this case people can't move easily from one task to another that doesn't match their specialization, and soon you have bottlenecks.

That's why TT introduces the concept of "Complicated Subsystem Team", another way to say that "you can't always optimize for flow". In my experience this is a very commmon type of team.

This is not to say that it's not possible to organize a multi-technology team for maximum flow. For example at Nokia, in the [development of the N9](https://www.balenet.com/work/nokia-n9/), things really started to click when we created "vertical teams" focusing on three main use cases: camera, phone calls and browser. The key thing is that there needs to be enough work for all the components.

TT is a good book, but as far as I'm concerned it suffers from the same problems that I have seen in other books, first and foremost the revered "[Accelerate](https://www.amazon.com/Accelerate-Software-Performing-Technology-Organizations/dp/1942788339)". First of all, it is clearly written thinking about web applications. I recognize that this represents 80% of the software built today, but for someone who has mainly worked on client-side, low level technologies like me, it is difficult to relate. What does "deploying" the Linux kernel even mean?

Secondly, it lacks concrete examples. Even its case studies are high-level, and they only describe the path to success, without mentioning the practical difficulties in implementing the solution. I would really like to know how someone implemented fast cycle time using Github in a real project, or how they collected the metrics to measure said cycle time, but that's for me to figure out. And as everyone knows, the devil is in the details.

But in conclusion yes, Conway's law is real and you can (and probably should) use it to your advantage.

