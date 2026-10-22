# Putting the app on your own iPhone

This is the only step a person has to do; everything else is automated. It takes about ten minutes the
first time and two minutes afterwards.

## What you need

- A Mac with Xcode installed (it is already on this machine).
- A USB cable and your iPhone.
- Any Apple ID. A free one is enough; it means the app stops working after seven days and you reinstall
  it with the same two clicks.

## One time only

1. **On the iPhone**: Settings → Privacy & Security → Developer Mode → turn it on → restart the phone.
   (The switch only appears after the phone has been connected to Xcode once. If you cannot see it,
   plug the phone in, open Xcode, and look again.)
2. **Plug the phone into the Mac** and tap **Trust** on the phone.
3. **In Xcode**: Settings → Accounts → add your Apple ID.

## Every time

1. In Terminal, regenerate the project and open it:

   ```
   cd ~/Projects/IBD
   xcodegen generate
   open IBDer.xcodeproj
   ```

2. In Xcode, click the **IBDer** target → **Signing & Capabilities** → tick **Automatically manage
   signing** → choose your name in **Team**.
3. At the top of the window, choose **your iPhone** as the destination (not a simulator).
4. Press **Run** (⌘R). The first time, the phone may ask you to trust the developer: Settings →
   General → VPN & Device Management → your Apple ID → Trust.
5. The app opens on the phone.

## What to look at, in order

1. The first launch asks three short pages. Skip them, or fill them in.
2. Record a toilet event. Force-quit the app and open it again: the record is still there.
3. Open the trends tab: the bar and the ring show that record.
4. Open the settings tab, then the biologic entry, set up a plan, and see the line appear on the day
   screen.
5. Turn the text size up to the largest in Settings → Accessibility → Display & Text Size.

## If something goes wrong

- **"Untrusted Developer"** → Settings → General → VPN & Device Management → Trust.
- **"Unable to install" / signing error** → the Team is empty in Signing & Capabilities.
- **The app disappears after a week** → that is the free account limit; run it again from Xcode.
- **Build fails on a bundle id conflict** → change the bundle id once in Signing & Capabilities
  (for example `org.ibder.app.<yourname>`).

## What not to do

- Do not put real health records on the phone before the backup question in issue #27 is settled.
  Use synthetic or throwaway entries for this trial.
