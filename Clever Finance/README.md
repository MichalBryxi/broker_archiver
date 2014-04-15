Clever Finance archiver
===============

Tool goes to your account on https://rhea.tiviosoft.net/cleverfinance/

Looks for all your contracts and downloads all available attachments.
That's usually scans of contracts.

You need to fill in PHPSESSID variable directly in the script.
This can be obtained from the browser after login.

Directory structure created will be following:

- agent_1
  - client_1
    - item_1.pdf
    - item_2.pdf
  - client_2
    - ...
  - ...
- agent_2
  - client_3
    - item_3.pdf
    - ...
  - ...
- ...
