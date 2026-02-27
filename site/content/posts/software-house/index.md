---
title: I fulfilled my childhood dream of owning a software house
date: 2026-2-27
topics: hobbies, devlog
---

Since the day I first put my hands on a computer, I dreamed of one day starting a software house with my best friend and base it in the home where I grew up. It was a naive dream and I shelved it as soon as I entered the grown-up world of careers and corporations, but somehow it always lingered.

Back then there was no internet and software was sold in shrink-wrapped boxes that contained thick manuals. At the time it was not unthinkable to have a two-to-four person company making software for a specific purpose. Then complexity and market grew, and software became the product of massive corporations. My ambitions changed as well: I wanted to do something “big”, travel the world and have a career at one of those very corporations. By the time I entered the job market, being independent mostly meant making websites, which I looked down on.

The situation has changed, and between software-as-a-service, AI assisted coding and the ability to reach customers directly via the internet, being independent is a very viable path - so viable that everyone is doing it and the real challenge is standing out.

But now that I’m about to publish my first app to the app store, I decided that it’s time to dust up that dream! The path to register a company and use it to publish on the App Store was surprisingly complex, and not for the reasons you would expect (i.e. a country's bureaucracy). I used Claude through the whole process and it was a great help - I don't think I could have done it otherwise.

Here is what I had to do. Note that this is somewhat specific to Finland where I reside.
## Picking a name

First of all I needed a name and a visual identity, so I bounced some ideas with Claude. I knew that I wanted a retro look evoking the IT industry of the 80s (think early Apple and my beloved ZX Spectrum), and that the name had to include my moniker “Bale”. On this last one I considered more clever alternatives, like crossbows (“balestra” in Italian) and whales (“balena”), but none of them worked. Claude suggested “haybale” which I considered for a while, but decided to drop. “Balesoft” was the simplest and clearer, but the domain was taken. To my surprise however, [baleware.com](http://baleware.com/) was free so I snagged it!

I then asked Claude to come up with some design alternatives, giving it the “rainbow” pattern used both by Apple and Sinclair and that never fails to pull the nostalgic strings of my heart. Everyone's first comment is "why did you use the LGBTQ+ flag" which wasn't my intention but I don't mind.

![Baleware logo](baleware.png)
## Registering a _toiminimi_

A toiminimi (literally "business name") is a sole proprietorship, the simplest business structure in Finland. You don't need starting capital, and you're personally liable for everything. It's ideal for a solo indie developer running a side business.
### How to do it

1. Go to [ytj.fi](https://www.ytj.fi/en/), the Finnish Business Information System.
2. Choose "Establish a new business" → "Yksityinen elinkeinonharjoittaja" (private trader).
3. Fill in the form. You'll need your business name, industry description (e.g. "ohjelmistokehitys" - software development), a business address, and contact details.
4. Pay €75 online.
5. Wait 1–3 business days.

That's it. You get a Y-tunnus (Finnish business ID) and you're officially in business. Claude helped me a lot with navigating the options and the whole thing took me about 15 minutes of form-filling plus a couple of days of waiting. Coming from Italy, it always amazes me how little bureaucracy is needed to get things done here in Finland.
### Things to know

**Reporting obligations are minimal.** If you make no money, you just confirm zero income on your annual tax return (Veroilmoitus 5) in the spring via vero.fi. No monthly filings, no quarterly reports.

**VAT registration is optional** if your annual turnover stays below €15,000. App Store revenue from consumers is handled by Apple anyway, so this is unlikely to matter early on.

When you register a toiminimi, the company's contact details are public and you'll expose yourself to telemarketers, specifically pension companies like Ilmarinen. They are not so bad - in fact the Ilmarinen person was quite helpful and didn't push the sale at all. Again, it helped that I knew what to say since I had sparred with Claude before the call.

**YEL pension insurance** may or may not apply to you.  YEL is based on your estimated work input (what you'd pay someone else to do your work), not actual profit. If you're employed full-time elsewhere and this is a genuine side project with modest hours, your YEL work income likely falls below the mandatory threshold (~€9,000/year). Describe your situation honestly and they'll tell you where you stand.

I wondered whether I should register a toiminimi or a proper limited company (osake yhtio or Oy). My conclusion was that for a side project, toiminimi is the right choice. An Oy gives you better tax optimisation at higher income levels (flat 20% corporate tax, dividend strategies), but adds real overhead - bookkeeping, financial statements, and more.  I can always upgrade later if the money justifies it (fat chance).

Last but not least, your employer will most likely want to know about your side hustle, to ensure that it doesn't interfere with your regular job, and that you don't use company resources (including intellectual property) to do it. Also, you are generally not allowed to compete with your employer. Most companies have a process for this and it's quite straightforward, I got my approval in a couple of days. This might seem like overkill, but it doesn't cost anything and it protects you from future troubles.

## Getting a D-U-N-S number

Apple requires organisations to have a D-U-N-S number from Dun & Bradstreet (D&B). It's a universal business identifier that Apple uses to verify your company exists. Getting this number and making Apple accept it was the hardest part of this process and took me almost a month.

### Requesting the number

You can request a D-U-N-S number through [Apple's dedicated lookup tool](https://developer.apple.com/enroll/duns-lookup/) or directly from D&B. In my case, D&B had already created a record for Baleware automatically from the Finnish national registry. They confirmed this with a case resolution email containing my D-U-N-S number.

### The problem: an incomplete profile

When I tried to convert my Apple Developer account, Apple replied that they couldn't determine my legal entity type because my D&B profile was incomplete. D&B said the case was resolved. Apple said it wasn't. Welcome to the support loop.

The issue was that D&B had created a DUNS record in their global system, but the legal entity type field (sole proprietorship) wasn't populated in a way that Apple could read. And D&B's Finnish portal couldn't even find my company when I searched by Y-tunnus.

### What I tried (in roughly this order)

1. **Replied to Apple** explaining D&B said everything was resolved. Apple said to fix it with D&B.
2. **Searched D&B's Finnish portal** by Y-tunnus — zero results.
3. **Contacted D&B support** — got redirected between Nordic support, global support, and automated portals that all pointed back to "check the trade register."
4. **Emailed various D&B addresses** (customerhelp@dnb.com, Nordic support lines) — mixed results.
5. **Found D&B's global profile update form** — this was the breakthrough. The form already had my data including "Legal Status: Proprietorship." I submitted it as-is to trigger a sync.
6. **Asked Apple to verify directly** from the Finnish Trade Register (ytj.fi) and offered to provide a kaupparekisteriote (trade register extract from PRH).

The D&B customer support is horrible and the whole company and idea behind it should die. It reminded me of notaries, a concept dating back to ancient Egypt. They have no place in today's world, shame on Apple for supporting this scam.
### What Apple eventually asked for

After the D&B back-and-forth, Apple requested three documents:

1. **Government-issued photo ID** -  my Italian passport worked fine, even though the business is in Finland.
2. **Proof of ownership** - a kaupparekisteriote (trade register extract) from PRH, which lists you as the business owner.
3. **Certificate of registration** - the same kaupparekisteriote covers this too.

You can order the kaupparekisteriote from [prh.fi](https://www.prh.fi/) for a few euros. It's a PDF that serves as both your registration certificate and proof of ownership.

The whole D-U-N-S saga took about three weeks of back-and-forth emails. The toiminimi registration took three days. Finnish bureaucracy 1, Apple 0.
## Part 3: Converting your Apple Developer account

Once Apple accepted my documents, the actual account conversion was straightforward. A few things to note:

- Your Team ID stays the same.
- Bundle IDs, provisioning profiles, certificates, and TestFlight builds all carry over.
- The seller name on the App Store changes to your company name.
- You may need to sign out and back into your Apple account in Xcode to refresh the team info.
- The fee stays at $99/year - same as an individual account.

If you haven't published to the App Store yet, you're in the cleanest possible position - nothing to transfer, no user-facing changes to worry about.

Finally, the Baleware identity appeared in XCode!

![Xcode signature](xcode.png)

## Was it worth it?

Yes. The toiminimi gives me a clean separation between personal and business activities, a proper entity for invoicing and contracts, and apps published under "Baleware" instead of my name. The Finnish bureaucracy was genuinely easy. The international bureaucracy between Apple and D&B was the real challenge - not technically difficult, just slow and opaque.