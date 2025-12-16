#!/usr/bin/env python3
"""
A helper script for AeroSpace with subcommands that enable navigation more like
what I have in i3. See the --help text for details.

To avoid needing to install dependencies, this script only uses Python standard
library packages available under Python 3.9.6, the version installed on macOS
Sequoia 15.5 (24F74).
"""
import argparse
import functools
import logging
import os
import subprocess
from dataclasses import dataclass


logger = logging.getLogger(__name__)
logging.basicConfig(
    format='[%(levelname)s] %(funcName)s - %(message)s',
    level=getattr(logging, os.environ.get('AEROSPACE_SCRIPT_LOG_LEVEL', 'DEBUG')),
)


def get_parser():
    parser = argparse.ArgumentParser()

    # global flags
    parser.add_argument('-d', '--dry-run', action='store_true')

    ## subparsers
    subparsers = parser.add_subparsers(required=True)

    ## subcommand: toggle
    parser_toggle = subparsers.add_parser('toggle', help='''
        Given a list of two or more workspace names, navigate between them
        intuitively, cycling focus through the listed workspaces when one of
        them is focused and otherwise finding the first reasonable one to open.
    ''')
    parser_toggle.set_defaults(handler=main_toggle)
    parser_toggle.add_argument(
        '-m', '--move', action='store_true',
        help='Move the focused container to the given workspace.',
    )
    parser_toggle.add_argument(
        'workspaces', type=str, nargs='+', help='Workspace numbers to toggle.'
    )

    ## subcommand: go
    parser_go = subparsers.add_parser('go', help='''
        Given a direction -- 'prev' or 'next' -- go to the previous or next
        workspace that has open windows, wrapping around if we're at the first
        or last workspace.
    ''')
    parser_go.set_defaults(handler=main_go)
    parser_go.add_argument('direction', choices=['prev', 'next'])
    parser_go.add_argument(
        '-m', '--move', action='store_true',
        help='Move the focused container to the given workspace.',
    )

    return parser


@dataclass
class AeroSpaceWorkspaceInfo:
    name: str
    is_focused: bool
    is_visible: bool


class AeroSpace:
    """
    Wrapper for the `aerospace` CLI.
    """
    def __init__(self, aerospace_cmd="aerospace"):
        self.aerospace_cmd = aerospace_cmd

    def _aerospace(self, args, capture_output=False, **kwargs):
        proc = subprocess.run(
            [self.aerospace_cmd, *args],
            capture_output=capture_output,
            text=capture_output,
            # check=True,
            **kwargs,
        )
        return proc

    def go_to_workspace(self, workspace):
        return self._aerospace(["workspace", workspace], check=True)

    def move_node_to_workspace(self, workspace, follow=True):
        flags = []
        if follow:
            flags.append("--focus-follows-window")

        return self._aerospace(
            ["move-node-to-workspace", *flags, workspace],
            check=True,
        )

    # required format for generating AeroSpaceWorkspaceInfo entries
    WORKSPACE_INFO_FORMAT = '%{workspace}|%{workspace-is-focused}|%{workspace-is-visible}'

    @classmethod
    def _parse_workspace_info(cls, output: str):
        """
        Parse the output of an aerospace CLI command invoked with
        WORKSPACE_INFO_FORMAT passed as its --format argument.

        We do this rather than using aerospace's --json flag because the JSON
        output doesn't provide all the information that we want.
        """
        return [
            cls._new_workspace_info(*line.split('|'))
            for line in output.splitlines()
        ]

    @staticmethod
    def _new_workspace_info(workspace: str, is_focused: str, is_visible: str) -> AeroSpaceWorkspaceInfo:
        return AeroSpaceWorkspaceInfo(
            workspace,
            is_focused == 'true',
            is_visible == 'true',
        )

    def _get_workspace_info(self, cmd: list[str]) -> list[AeroSpaceWorkspaceInfo]:
        """
        Invoke aerospace with the given subcommand, passing the --format flag
        with WORKSPACE_INFO_FORMAT and parsing the result into a list of
        AeroSpaceWorkspaceInfo objects.
        """
        proc = self._aerospace([*cmd, "--format", self.WORKSPACE_INFO_FORMAT], capture_output=True)

        output: str = proc.stdout
        return self._parse_workspace_info(output)

    def get_focused_workspace(self) -> AeroSpaceWorkspaceInfo:
        if ws := self._get_workspace_info(["list-workspaces", "--focused"]):
            return ws[0]
        return None

    def get_all_workspaces(self) -> list[AeroSpaceWorkspaceInfo]:
        """
        Get the list of all workspaces, including persistent workspaces that may
        not have open windows.
        """
        return self._get_workspace_info(["list-workspaces", "--all"])

    def get_true_active_workspaces(self) -> list[AeroSpaceWorkspaceInfo]:
        """
        Get the list of workspaces containing windows. Note that this may or may
        not include the currently focused workspace. (To ensure the focused
        workspace is included, use get_active_workspaces() instead.)
        """
        # Note here that we use list-windows, not list-workspaces. This ensures
        # we only get workspaces that actually have open windows assigned to
        # them. However, this also won't include the focused workspace if it
        # has no open windows.
        return self._get_workspace_info(["list-windows", "--all"])

    def get_active_workspaces(self) -> list[AeroSpaceWorkspaceInfo]:
        """
        Get the list of active workspaces, including the currently focused
        workspace.
        """
        workspaces = self.get_true_active_workspaces()
        if focused_ws := self.get_focused_workspace():
            return [focused_ws] + workspaces
        return workspaces


def unique_workspaces(workspaces: list[AeroSpaceWorkspaceInfo]) -> list[AeroSpaceWorkspaceInfo]:
    workspaces = sorted(workspaces, key=lambda ws: ws.name)
    return functools.reduce(
        lambda L, ws: L + ([] if L and L[-1].name == ws.name else [ws]),
        workspaces, []
    )


@dataclass
class WorkspaceStates:
    focused: str
    workspaces: set[str]
    visible: set[str]


def summarize_workspaces(ws_info: list[AeroSpaceWorkspaceInfo]) -> WorkspaceStates:
    """
    Summarize current workspace states for ease of navigation.
    """
    focused: str = None
    workspaces: set[str] = set()
    visible: set(str) = set()

    for ws in ws_info:
        workspaces.add(ws.name)
        if ws.is_focused:
            focused = ws.name
        if ws.is_visible:
            visible.add(ws.name)

    return WorkspaceStates(focused, workspaces, visible)


def get_target_workspace(
    # TODO: take a WorkspaceStates instance here
    # states: WorkspaceStates,
    focused: str,
    opened: set[str],
    visible: set[str],
    targets: list[str]
):
    """
    Find the target workspace to switch to based on the current state of open
    and visible workspaces. The workspaces are all identified based on their
    workspace name.

    :param focused: The names of the currently focused workspace.
    :param opened: The names of open workspaces.
    :param visible: The names of visible workspaces.
    :param targets: The target workspaces.
    :return: The workspace to jump to.

    The workspace to switch to is selected based on the following algorithm:

    - If the focused workspace is a target, cycle to the next target in the list
      after the focused workspace.
    - If the focused workspace isn't a target, go to the first visible target in
      the list.
    - If no targets are visible, go to the first open target in the list.
    - If no targets are open, go to the first target in the list.

    When the focused workspace isn't a target and we only have one target,
    go to the target.
    >>> get_target_workspace(-1, opened=[-1], visible=[-1], targets=[1])
    1

    When the focused workspace is a target, go to the next target in the list.
    >>> get_target_workspace(1, opened=[1, 2], visible=[1], targets=[1, 2])
    2
    >>> get_target_workspace(2, opened=[1, 2], visible=[2], targets=[1, 2])
    1

    When the focused workspace is not a target and none of the targets are
    visible, we should go to the first open target in the list.
    >>> get_target_workspace(-1, opened=[2], visible=[-1], targets=[1, 2])
    2

    When the focused workspace is a target and there's another target that isn't
    open, we should open that other target workspace.
    >>> get_target_workspace(2, opened=[2], visible=[2], targets=[1, 2])
    1
    >>> get_target_workspace(1, opened=[1], visible=[1], targets=[1, 2])
    2

    When the focused workspace is not a target and multiple targets are open, we
    should go to any visible target before going to other targets.
    >>> get_target_workspace(-1, opened=[-1, 1, 2], visible=[-1, 2], targets=[1, 2, 3])
    2
    """
    # TODO: support i3-style workspace number prefixes

    if len(targets) <= 0:
        logger.debug('No workspaces given - staying on focused workspace %s',
                     focused)
        return focused

    if len(targets) == 1:
        logger.debug('Only one workspace given - going to it: %s', targets[0])
        return targets[0]

    if focused in targets:
        logger.debug('Focused workspace is a target - going to next target')
        target_index = targets.index(focused) + 1
        target_index %= len(targets)
        return targets[target_index]

    # Here we identify which workspace to switch to.
    logger.debug("Focused workspace isn't a target - going to first open or "
                 "visible target")

    # This loop finds the first visible or open workspace in the targets list.
    # If a target is visible, we go to that one immediately. If a target is
    # open, we save the first open target and go to that one.
    first_open = None
    for ws in targets:
        if ws in visible:
            logger.debug('Found visible target %s - going there', ws)
            return ws
        if ws in opened and first_open is None:
            logger.debug('Found open target %s', ws)
            first_open = ws

    if first_open is not None:
        return first_open

    logger.debug('No targets are open - going to the first')
    return targets[0]


def main_toggle(args):
    """Entrypoint for the 'toggle' subcommand."""
    targets = args.workspaces
    assert targets, "expected at least one target workspace"

    aerospace = AeroSpace()
    workspaces = aerospace.get_active_workspaces()
    workspaces = unique_workspaces(workspaces)
    state = summarize_workspaces(workspaces)

    logging.debug('Focused workspace: %s', state.focused)
    logging.debug('Open workspaces: %s', sorted(state.workspaces))
    logging.debug('Visible workspaces: %s', sorted(state.visible))

    target = get_target_workspace(state.focused, state.workspaces, state.visible, targets)
    logging.info('Going to workspace %s', target)

    if args.dry_run:
        logging.info('Dry run - exiting')
        return

    if args.move:
        logging.info('Moving node to target workspace')
        aerospace.move_node_to_workspace(target)
    else:
        aerospace.go_to_workspace(target)


def main_go(args):
    """Entrypoint for the 'go' subcommand."""
    direction = args.direction
    if direction not in ('next', 'prev'):
        raise ValueError(f"invalid direction: {direction}")

    aerospace = AeroSpace()
    workspaces = aerospace.get_active_workspaces()
    workspaces = unique_workspaces(workspaces)
    state = summarize_workspaces(workspaces)

    # the target list is the full list of workspaces sorted by name
    target_workspaces = sorted(state.workspaces, reverse=direction == 'prev')

    target = get_target_workspace(state.focused, state.workspaces, state.visible, target_workspaces)
    logging.info('Going to workspace %s', target)
    if args.dry_run:
        logging.info('Dry run - exiting')
        return

    if args.move:
        logging.info('Moving node to target workspace')
        aerospace.move_node_to_workspace(target)
    else:
        aerospace.go_to_workspace(target)



def main():
    """Main script entrypoint."""
    args = get_parser().parse_args()

    args.handler(args)


if __name__ == '__main__':
    main()
