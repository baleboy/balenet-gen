---
title:  AI designed this app
date:  2024-04-14
topics: ai, programming
---

Lately I've been working on an [intermittent fasting app](https://github.com/baleboy/fastTrack) to learn SwiftUI. I used ChatGPT through the process to help me figure out the code, and it's been a great learning tool. But so far I haven't paid too much attention to the design, and it shows. Since recently ChatGPT added the ability to upload and generate images, I wondered if I could use this feature to create a better design for my app.

The conclusion is ChatGPT can definitely help, but doesn't produce anything that you would upload to the App Store. However its ability to understand pictures and generate code from them is astonishing.

## The test

As a first test, I uploaded the current UI of my app and asked Chat GPT to “make it better”. This is the image I submitted (like I said, not a contender for the “App design of the year” award):

![Simulator Screenshot - iPhone 15 Pro - 2024-03-16 at 11.50.46.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/19E7D80C-FEA6-455F-82A2-047A60CBEAEC_2/CBGDBvPn2QQdxEmZ8p638RU7yKKYvISmB8IoP5alzmMz/Simulator%20Screenshot%20-%20iPhone%2015%20Pro%20-%202024-03-16%20at%2011.50.46.png)

And this is what I asked:

`Me: this is a screenshot of my fasting application. Can you make it look better?`

After some generic advice on principles of UI design, ChatGPT answered with the following:

`Let's try to create a more visually appealing version of your fasting app interface. I'll design a concept image for you.`

`Here's a redesigned concept for your fasting app interface. The design is modern and clean, with a minimalistic approach and a soothing color palette to maintain focus. You can see how the important features like the current fasting status and the 'Start Fasting' button are highlighted for ease of use. The bottom tabs provide quick navigation. What do you think?`

![DALL·E 2024-03-18 09.26.52 - Design a modern and visually appealing interface for a fasting tracker mobile application. The interface should be clean and minimalistic with a color.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/5BF0D9A8-281B-4EFD-9046-CD4C622C01C0_2/W5epHik6c5HXrqJXKMrbnKjFMDHWWdzEty2mfirxflIz/DALLE%202024-03-18%2009.26.52%20-%20Design%20a%20modern%20and%20visually%20appealing%20interface%20for%20a%20fasting%20tracker%20mobile%20application.%20The%20interface%20should%20be%20clean%20and%20minimalistic%20with%20a%20color.png)

I didn't want to hurt its feelings, but this isn't very useful. The color scheme is nice, but the added UI elements make no sense especially since the text is gibberish. Also, it's not really usable for the actual development of the application. Admittedly my prompt was rather generic, but I decided to try a different approach. What if I drew the UI, and asked ChatGPT to create the code?

## Hand-drawn UI as an input

For a quick-n-dirty test, I drew the UI by hand:

![IMG_6110.jpeg](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/B8520D33-54C1-4D6C-881D-406D8BD06534_2/UMaZImSlXDzum19OamxybvuCOYEwrawDl9xYFDQbBHUz/IMG_6110.jpeg)

And then asked to recreate it in code:

Me: can you write the SwiftUI code to create a UI Like the one in this picture?

ChatGPT: Certainly! To create a SwiftUI view that resembles the sketch you've provided, which seems to be a timer with a stop button, you can use the following code as a starting point:

```swift
import SwiftUI

struct TimerView: View {
  @State private var timeRemaining = 222 // Replace with actual remaining time in seconds
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack {
      ZStack {
        Circle()
        .stroke(lineWidth: 20)
        .opacity(0.3)
        .foregroundColor(Color.gray)

        Circle()
        .trim(from: 0.0, to: CGFloat(min(self.timeRemaining, 3600)) / 3600)
        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round,   lineJoin: .round))
        .foregroundColor(Color.blue)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: timeRemaining)

        Text("(timeString(from: timeRemaining))")
        .font(.largeTitle)
        .bold()
      }
      .padding(40)

      Button(action: {
      // Stop the timer here
        self.timer.upstream.connect().cancel()
      }) {
        Text("STOP")
        .foregroundColor(.white)
        .padding()
        .background(Color.red)
        .cornerRadius(40)
      }
      .padding()
    }
    .onReceive(timer) { _ in
      if self.timeRemaining > 0 {
        self.timeRemaining -= 1
      }
    }
  }

  func timeString(from totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds / 60) % 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}

struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView()
  }
}
```
And this is what it looks like, with no changes:

![Screenshot 2024-03-17 at 10.01.08.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/31502AE0-4400-4BFD-A73C-FF07D1076E9A_2/ywlMAqs15swGnbMxoCAMcre2F9z7yh7HkVhw0k3vmZwz/Screenshot%202024-03-17%20at%2010.01.08.png)

This was better. It's pretty amazing how I went from paper to code in one step. Plus, it works! The timer runs and stops and the button changes state as expected.

This was simple, so I tried a little more complex UI with colors.

![IMG_6111.jpeg](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/1C9C7215-50F7-4916-8BA1-4CFFDF7CF441_2/Tgt6cE9dHB6bAPvrzjouJuFzpbFSAWpvT5TpBXC6c8Yz/IMG_6111.jpeg)

The result isn't perfect but it's a good starting point. Notice how ChatGPT understood my scribbling! The list of fasts wasn't updated though, but that would have been asking too much.

![Screenshot 2024-03-17 at 10.19.50.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/EF9E172E-BFAD-4D6E-A28B-7044D4FD52E5_2/bvVeRy7E1lfSDzg0F4DVixsBKRGs1opd4h9niYv64xQz/Screenshot%202024-03-17%20at%2010.19.50.png)

## Copying with pride

As a last test, I tried with a screenshot of [Zero](https://zerolongevity.com), a fasting app I like and that I am trying to emulate.

![IMG_6112.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/6A0C2F15-EC98-4122-ADFE-537B508694E1_2/fuxnVG4g60WaII6u4ztD1VXpYMofIlgOpAq18WVrTMUz/IMG_6112.png)

This is what the code generated by ChatGPT looked like. Again, a good starting point, but not quite there.

![Screenshot 2024-03-17 at 10.32.35.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/8F82EB22-B161-44CA-8EB9-6843D8217DF2_2/LmBxCfTDFGif3GVHJAgJNMESnoKs5AwiOxjQP4qE7YIz/Screenshot%202024-03-17%20at%2010.32.35.png)

## Just give me the code

Finally, I wondered what would happen if I gave ChatGPT my original SwiftUI code for the app at the beginning of this post instead of the image, and ask it to modify the code to improve the design. This was the (not too impressive given everything I've seen so far) result:

![Screenshot 2024-03-17 at 12.40.43.png](https://res.craft.do/user/full/58e85b69-1aa6-c3c8-74ac-daf2b8beae9a/doc/F2E78A5D-41A8-4FB8-89A9-A6367593C180/07EBF2C0-2CD8-44EC-B7A7-3EF888148992_2/krr3O7NRtONIsU4hLdur5TmCV5E9VdAbVjlG7WOSxxUz/Screenshot%202024-03-17%20at%2012.40.43.png)

## Conclusions

It's pretty amazing how much ChatGPT can understand from a picture, even if drawn by hand in a hurry. I think this is definitely where the software development and design tools are going, it's a bit early but it's easy to imagine that they will get better.

