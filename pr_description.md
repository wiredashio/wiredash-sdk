Fixes (bug id).

I initially started with the _"oopsie! something wrong. please try again!"_ UI, but then thought it's probably better to persist the feedback locally and _"eventually send"_ it in the background.
Otherwise the end users might just give up, which could potentially result in less feedback especially if they're in a situation where they don't have easy access to internet.
This is how other analytics SDKs and crash reporting systems do it as well.

* introduce `PendingFeedbackItem` & `FeedbackItem` classes for temporarily storing feedback before it's sent to server
* introduce a testable, top-level `uuidV4` field for all UUID needs
* introduce `PendingFeedbackItemStorage` that can temporarily persist feedback items and associated screenshots
* introduce a `RetryingFeedbackSubmitter` that knows how to "eventually send" a feedback item
* restructure stuff to make things testable, for example with `package:file`
* adds path_provider
* tests, test, and more tests