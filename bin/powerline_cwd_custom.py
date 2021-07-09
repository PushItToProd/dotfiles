"""
A custom cwd segment for https://github.com/b-ryan/powerline-shell, based on
cwd.py from that project. This implementation shortens long directory names by
truncating them in the middle instead of at the end - e.g. "reallylongdirname"
becomes "rea...ame" with max_dir_size set to 9.

---

Under the terms of powerline-shell's license, the following notice is required:

The MIT License (MIT)

Copyright (c) 2014 Shrey Banga and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""
import os
import sys
from powerline_shell.utils import warn, py3, BasicSegment

ELLIPSIS = u'\u2026'


def replace_home_dir(cwd):
    home = os.path.realpath(os.getenv('HOME'))
    if cwd.startswith(home):
        return '~' + cwd[len(home):]
    return cwd


def split_path_into_names(cwd):
    names = cwd.split(os.sep)

    if names[0] == '':
        names = names[1:]

    if not names[0]:
        return ['/']

    return names


def requires_special_home_display(powerline, name):
    """Returns true if the given directory name matches the home indicator and
    the chosen theme should use a special home indicator display."""
    return (name == '~' and powerline.theme.HOME_SPECIAL_DISPLAY)


def truncate(s: str, max_size: int, sep='...'):
    """
    >>> truncate("foobar", 6, sep='...')
    cwd config max_size 6 is too short - treating as 9
    'foobar'
    >>> truncate("foobar", 15, sep='...')
    'foobar'
    >>> truncate("0123456789", 9, sep='...')
    '012...789'
    """
    if max_size < 9:
        print(f"cwd config max_size {max_size} is too short - treating as 9")
        max_size = 9

    if len(s) <= max_size:
        return s

    size = (max_size - len(sep)) // 2

    return s[:size] + sep + s[-size:]


def maybe_shorten_name(powerline, name):
    """If the user has asked for each directory name to be shortened, will
    return the name up to their specified length. Otherwise returns the full
    name."""
    max_size = powerline.segment_conf("cwd", "max_dir_size")

    if not max_size:
        return name

    sep = powerline.segment_conf("cwd", "separator", ELLIPSIS)

    return truncate(name, max_size, sep)


def get_fg_bg(powerline, name, is_last_dir):
    """Returns the foreground and background color to use for the given name.
    """
    if requires_special_home_display(powerline, name):
        return (powerline.theme.HOME_FG, powerline.theme.HOME_BG,)

    if is_last_dir:
        return (powerline.theme.CWD_FG, powerline.theme.PATH_BG,)
    else:
        return (powerline.theme.PATH_FG, powerline.theme.PATH_BG,)


def add_cwd_segment(powerline):
    cwd = powerline.cwd
    if not py3:
        cwd = cwd.decode("utf-8")
    cwd = replace_home_dir(cwd)

    names = split_path_into_names(cwd)

    full_cwd = powerline.segment_conf("cwd", "full_cwd", False)
    max_depth = powerline.segment_conf("cwd", "max_depth", 5)
    if max_depth <= 0:
        warn("Ignoring cwd.max_depth option since it's not greater than 0")
    elif len(names) > max_depth:
        # https://github.com/milkbikis/powerline-shell/issues/148
        # n_before is the number is the number of directories to put before the
        # ellipsis. So if you are at ~/a/b/c/d/e and max depth is 4, it will
        # show `~ a ... d e`.
        #
        # max_depth must be greater than n_before or else you end up repeating
        # parts of the path with the way the splicing is written below.
        n_before = 2 if max_depth > 2 else max_depth - 1
        names = names[:n_before] + [ELLIPSIS] + names[n_before - max_depth:]

    if powerline.segment_conf("cwd", "mode") == "dironly":
        # The user has indicated they only want the current directory to be
        # displayed, so chop everything else off
        names = names[-1:]

    elif powerline.segment_conf("cwd", "mode") == "plain":
        joined = os.path.sep.join(names)
        powerline.append(" %s " % (joined,), powerline.theme.CWD_FG,
                         powerline.theme.PATH_BG)
        return

    for i, name in enumerate(names):
        is_last_dir = (i == len(names) - 1)
        fg, bg = get_fg_bg(powerline, name, is_last_dir)

        separator = powerline.separator_thin
        separator_fg = powerline.theme.SEPARATOR_FG
        if requires_special_home_display(powerline, name) or is_last_dir:
            separator = None
            separator_fg = None

        if not (is_last_dir and full_cwd):
            name = maybe_shorten_name(powerline, name)
        powerline.append(' %s ' % name, fg, bg, separator, separator_fg)

class Segment(BasicSegment):
    def add_to_powerline(self):
        add_cwd_segment(self.powerline)


if __name__ == '__main__':
    import doctest
    doctest.testmod()