#!/usr/bin/env python3.11
"""
A helper script for i3 that allows one keybinding to access and cycle through
multiple numbered workspaces, as well as move containers to them.

This script should be invoked with a list of two or more workspace numbers to
target for navigation. It will navigate between them intuitively, cycling focus
through the listed workspaces when one of them is focused and otherwise finding
the first reasonable one to open.

"""
import argparse
import logging
import os

import i3ipc


logger = logging.getLogger(__name__)
logging.basicConfig(
    format='[%(levelname)s] %(funcName)s - %(message)s',
    level=getattr(logging, os.environ.get('I3_SCRIPT_LOG_LEVEL', 'DEBUG')),
)


parser = argparse.ArgumentParser()
parser.add_argument(
    '-m', '--move', action='store_true',
    help='Move the focused container to the given workspace.',
)
parser.add_argument(
    'workspaces', type=int, nargs='+', help='Workspace numbers to toggle.'
)


def go_to(i3: i3ipc.Connection, workspace: int):
    """Go to the given workspace number."""
    i3.command(f"workspace number {workspace}")


def move_to(i3: i3ipc.Connection, workspace: int):
    """Move the focused container to the given workspace."""
    i3.command(f"move container to workspace number {workspace}")


def get_i3_state(i3: i3ipc.Connection):
    """
    Return a tuple with the focused workspace, a list of open workspaces, and a
    list of visible workspaces.
    """
    focused = None
    workspaces = []
    visible = []
    for ws in i3.get_workspaces():
        workspaces.append(ws.num)
        if ws.focused:
            focused = ws.num
        if ws.visible:
            visible.append(ws.num)
    return focused, workspaces, visible


def get_target_workspace(
    focused: int,
    open_workspaces: list[int],
    visible: list[int],
    targets: list[int]
):
    """
    Find the target workspace to switch to based on the current state of open
    and visible workspaces.

    :param focused: The number of the currently focused workspace.
    :param open_workspaces: The numbers of open workspaces.
    :param visible: The numbers of visible workspaces.
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
    >>> get_target_workspace(-1, [-1], [-1], [1])
    1

    When the focused workspace is a target, go to the next target in the list.
    >>> get_target_workspace(1, [1, 2], [1], [1, 2])
    2
    >>> get_target_workspace(2, [1, 2], [2], [1, 2])
    1

    When the focused workspace is not a target and none of the targets are
    visible, we should go to the first open target in the list.
    >>> get_target_workspace(-1, [2], [-1], [1, 2])
    2

    When the focused workspace is a target and there's another target that isn't
    open, we should open that other target workspace.
    >>> get_target_workspace(2, [2], [2], [1, 2])
    1
    >>> get_target_workspace(1, [1], [1], [1, 2])
    2

    When the focused workspace is not a target and multiple targets are open, we
    should go to any visible target before going to other targets.
    >>> get_target_workspace(-1, [-1, 1, 2], [-1, 2], [1, 2, 3])
    2
    """
    # TODO: support workspace names too
    logger.debug(
        'get_target_workspace(focused: %s, open: %s, visible: %s, targets: %s)',
        focused, open_workspaces, visible, targets
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
        if ws in open_workspaces and first_open is None:
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

    i3 = i3ipc.Connection()

    focused, workspaces, visible = get_i3_state(i3)
    logging.debug('Focused workspace: %s', focused)
    logging.debug('Open workspaces: %s', workspaces)
    logging.debug('Visible workspaces: %s', visible)

    target = get_target_workspace(focused, workspaces, visible, targets)
    logging.info('Going to workspace %s', target)

    if args.move:
        logging.info('Moving container to target workspace first')
        move_to(i3, target)
    go_to(i3, target)


if __name__ == '__main__':
    main()

