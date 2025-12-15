# AI Usage Log

## Entry 1
Date: 12/3/25 ChatGPT

"Help me design a database schema for a real estate app with users, property listings (images, price, bedrooms, amenities), favorites, comparison selections, messages, and tour scheduling and also provide table definitions and primary/foreign keys."

We used the suggested schema structure to outline some of the tables and then adjusted the fields to match our UI elements.

AI helped us think through relationships. We learned we still had to verify constraints and choose what should be normalized vs stored as text for simplicity.

## Entry 2
Date 12/5/25 ChatGPT

“i’m getting this Flutter error when navigating after login: looking up a deactivated widget's ancestor is unsafe. this is my snippet from login_screen.dart using Navigator.pushReplacement. how do I fix it?”

We used the guidance to ensure navigation only happens after checking mounted in async flows, and moved the navigation call to a safe point after auth success. We also cleaned up context usage inside async functions.

We learned common Flutter navigation pitfalls and why BuildContext can become invalid after an async call. AI saved time by pointing us to the right concept quickly, but we still had to test multiple flows (login success/fail).

## Entry 3
Date 12/6/25 ChatGPT

“my favorites screen is showing duplicates. I store favorites in firebase with columns userId and propertyId. whats the best way to prevent duplicates and handle toggling favorites”

We added a unique constraint logic so a favorite record can’t be inserted twice, and implemented a toggle flow: if exists then delete, else insert. Updated the UI to reflect state after DB operations.

We learned practical ways to enforce data integrity (DB constraint and app logic). AI helped us think about edge cases like rapid tapping and stale UI state.

## Entry 4
Date 12/7/25 ChatGPT

“my chat ui sometimes doesnt update until i leave and reenter the screen. im using Provider. how do i ensure the message list refreshes after sending?”

We used the suggestion to update state immediately after insert and then re-fetch messages or notify listeners after DB writes. Also ensured we were not using a non-listening provider read in the widget that should rebuild.

We learned the difference between reading provider state vs listening for changes, and why UI refresh issues often come from state not being notified. AI helped narrow down likely causes fast.

## Entry 5
Date 12/12/25 ChatGPT

“using this slide template, write presentation text for: project overview, roles, key features/screens, testing, and future improvements for PropertyPulse.”

We used the output as a draft for slide text, then edited wording to match what we actually implemented and to keep bullet counts within the presentation format. No application code was generated or copied.

AI helped with clarity and presentation structure. We learned to verify every claim so we don’t overstate what the app currently does.