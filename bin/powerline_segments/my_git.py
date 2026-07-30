"""
A custom git segment for https://github.com/b-ryan/powerline-shell.

Wraps the built-in git segment to suppress it when the current directory is a
gitignored subdirectory of the $HOME dotfiles repo. Because the whole home
directory is a single git repo with an allowlist-based .gitignore, the stock
git segment otherwise shows the dotfiles branch (e.g. "main") in every
non-tracked directory under $HOME, such as ~/Documents.

The segment is left untouched for any other repo nested under an ignored path
(e.g. ~/projects/foo, which reports its own toplevel), so those branches still
show as normal.
"""
import os
import subprocess
from powerline_shell.segments.git import Segment as GitSegment


def in_ignored_homedir_subdir():
    """True iff cwd is an ignored path within the $HOME dotfiles repo."""
    home = os.path.realpath(os.path.expanduser("~"))
    try:
        toplevel = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            stderr=subprocess.DEVNULL,
        ).decode().strip()
    except (subprocess.CalledProcessError, OSError):
        return False  # not in a repo, or git unavailable
    if os.path.realpath(toplevel) != home:
        return False  # a different repo (e.g. ~/projects/foo) — leave alone
    return subprocess.call(
        ["git", "check-ignore", "-q", "."],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    ) == 0


class Segment(GitSegment):
    def run(self):
        if in_ignored_homedir_subdir():
            self.stats, self.branch = None, None
            return
        super().run()
