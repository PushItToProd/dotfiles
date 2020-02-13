#!/usr/bin/env python3
"""
Open URL in a new tab if Firefox is open in the current workspace or
a new window if it is not.
"""
import argparse
import logging
import os
import subprocess

import i3ipc

log_level = getattr(logging, os.environ.get('I3_SCRIPT_LOG_LEVEL', 'INFO'))
logger = logging.getLogger(__name__)
logging.basicConfig(
    format='[%(levelname)s] %(funcName)s - %(message)s',
    level=log_level,
)

# control objects
i3 = i3ipc.Connection()

# global state information
focused = i3.get_tree().find_focused()
browser_is_focused = focused.window_role == 'Firefox'
browser_windows = focused.workspace().find_classed('Firefox')

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('url', help='The URL to open.')


# FIXME: currently this always opens code in (I think) the oldest
# window in the workspace. I've tried using Python's webbrowser module
# and now am using the subprocess module, but both have the same
# issue, which is bizarre since the bash implementation of this
# doesn't have this problem. I almost wonder if i3ipc is somehow
# modifying the tree state or something?
def i3_open_in_browser(url, i3=i3):
    if not browser_windows:
        logging.debug("browser isn't open in this workspace - "
                      "opening a new window")
        subprocess.run(["firefox", "-new-window", url])
        return

    if not browser_is_focused:
        logging.debug("browser isn't focused in this workspace - "
                      "focusing it first")
        # TODO: try to find the last focused window instead of always
        # focusing the first one in the list
        browser_windows[0].command('focus')

    logging.debug("browser is open and focused - opening a new tab")
    subprocess.run(["firefox", "-new-tab", url])


if __name__ == '__main__':
    args = parser.parse_args()
    logger.info('Opening url %s', args.url)
    i3_open_in_browser(args.url)
