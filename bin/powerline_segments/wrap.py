"""
A custom segment for https://github.com/b-ryan/powerline-shell, based on its
newline.py.

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
import re
import os
from powerline_shell.utils import warn, BasicSegment


def strip_control_sequences(prompt_str):
    """
    via https://stackoverflow.com/a/14693789/6417784
    """
    # 7-bit C1 ANSI sequences
    ansi_escape = re.compile(r'''
        \x1B  # ESC
        (?:   # 7-bit C1 Fe (except CSI)
            [@-Z\\-_]
        |     # or [ for CSI, followed by a control sequence
            \[
            [0-?]*  # Parameter bytes
            [ -/]*  # Intermediate bytes
            [@-~]   # Final byte
        )
    ''', re.VERBOSE)
    prompt_str = ansi_escape.sub('', prompt_str)
    prompt_str = prompt_str.replace('%{', '').replace('%}', '')
    return prompt_str


class Segment(BasicSegment):
    def add_to_powerline(self):
        if self.powerline.args.shell == "tcsh":
            warn("wrap segment not supported for tcsh")
            return

        wrap_width = self.powerline.segment_conf('wrap', 'width', 0.66)

        prompt = strip_control_sequences(self.powerline.draw())
        prompt_len = len(prompt)
        # print("prompt:")
        # print('\n'.join(f"{c}: {ord(c)}" for c in self.powerline.draw()))

        term_width = os.environ.get("TERM_COLUMNS", None)
        if not term_width:
            warn("wrap segment requires the env var TERM_COLUMNS to be set")
            return
        try:
            term_width = int(term_width)
        except:
            warn("wrap segment requires the env var TERM_COLUMNS to be a valid "
                 f"integer, but got '{term_width} instead")
            return

        if prompt_len <= term_width * wrap_width:
            return

        # print("prompt_len:", prompt_len)
        # print("term_width:", term_width)
        # print("term_width * 0.75:", term_width * 0.75)

        self.powerline.append("\n",
                              self.powerline.theme.RESET,
                              self.powerline.theme.RESET,
                              separator="")


if __name__ == '__main__':
    ps1 = os.environ.get('PS1')
    assert ps1, "PS1 must be exported"
    print("PS1 =", ps1)
    stripped_ps1 = strip_control_sequences(ps1)
    print("stripped:")
    print(stripped_ps1)
    print("length:", len(stripped_ps1))