# Synthetic fixtures only

Every CSV in synthetic/ contains data_class=synthetic and explicit synthetic source/approval markers. There is one hidden test style with two test variants. Names, prices, stock, configuration and option/source references are test values, not VK7SPORTS business facts or approvals.

example.invalid URLs are intentionally non-resolving placeholders; no network requests are made. Tests use isolated temporary copies. The local file-presence test writes labelled text, not a real product photo.

Expected output under ../expected/ is generated only with --allow-synthetic. It demonstrates native encoding and three product rows, with a JSON report containing three remote-media warnings. Never import these files to a business database. Normal validation rejects fixtures without the explicit flag.
