#!/usr/bin/env python3
"""
A helper script for AeroSpace that allows one keybinding to access and cycle
through multiple workspaces, as well as move nodes to them.

This script should be invoked with a list of two or more workspace names to
target for navigation. It will navigate between them intuitively, cycling focus
through the listed workspaces when one of them is focused and otherwise finding
the first reasonable one to open.
"""
import argparse
import logging
import os
import subprocess
from dataclasses import dataclass


logger = logging.getLogger(__name__)
logging.basicConfig(
    format='[%(levelname)s] %(funcName)s - %(message)s',
    level=getattr(logging, os.environ.get('AEROSPACE_SCRIPT_LOG_LEVEL', 'DEBUG')),
)


parser = argparse.ArgumentParser()
parser.add_argument(
    '-m', '--move', action='store_true',
    help='Move the focused container to the given workspace.',
)
parser.add_argument(
    'workspaces', type=str, nargs='+', help='Workspace numbers to toggle.'
)


@dataclass
class AeroSpaceWorkspaceInfo:
    name: str
    is_focused: bool
    is_visible: bool


class AeroSpace:
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

    def get_workspaces(self) -> list[AeroSpaceWorkspaceInfo]:
        workspace_list_format = '%{workspace}|%{workspace-is-focused}|%{workspace-is-visible}'
        proc = self._aerospace(["list-workspaces", "--all", "--format", workspace_list_format], capture_output=True)

        def _new_workspace_info(workspace, is_focused, is_visible) -> AeroSpaceWorkspaceInfo:
            return AeroSpaceWorkspaceInfo(
                workspace,
                is_focused == 'true',
                is_visible == 'true',
            )

        output: str = proc.stdout
        return [
            _new_workspace_info(*line.split('|'))
            for line in output.splitlines()
        ]


@dataclass
class WorkspaceStates:
    focused: str
    workspaces: list[str]
    visible: list[str]


def summarize_workspaces(ws_info: list[AeroSpaceWorkspaceInfo]):
    focused = None
    workspaces = []
    visible = []

    for ws in ws_info:
        workspaces.append(ws.name)
        if ws.is_focused:
            focused = ws.name
        if ws.is_visible:
            visible.append(ws.name)

    return WorkspaceStates(focused, workspaces, visible)


def get_target_workspace(
    focused: int,
    opened: list[int],
    visible: list[int],
    targets: list[int]
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
    # TODO: support workspace names too
    logger.debug(
        'get_target_workspace(focused: %s, open: %s, visible: %s, targets: %s)',
        focused, opened, visible, targets
    )

    if len(targets) <= 0:
        logger.debug('No workspaces given - staying on focused workspace %s',
                     focused)
        return focused

    if len(targets) == 0:
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


def main():
    """Main script entrypoint."""
    args = parser.parse_args()
    assert len(args.workspaces) > 0, "expected at least one target workspace"
    targets = args.workspaces

    aerospace = AeroSpace()
    workspaces = aerospace.get_workspaces()
    state = summarize_workspaces(workspaces)

    logging.debug('Focused workspace: %s', state.focused)
    logging.debug('Open workspaces: %s', state.workspaces)
    logging.debug('Visible workspaces: %s', state.visible)

    target = get_target_workspace(state.focused, state.workspaces, state.visible, targets)
    logging.info('Going to workspace %s', target)

    # if args.move:
    #     logging.info('Moving node to target workspace')
    #     aerospace.move_node_to_workspace(target)
    # else:
    #     aerospace.go_to_workspace(target)


if __name__ == '__main__':
    main()

