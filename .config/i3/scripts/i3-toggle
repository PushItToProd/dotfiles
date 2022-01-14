#!/usr/bin/env python3.8
"""
Toggle among a set of given workspaces.
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


def get_target_workspace(focused, open_workspaces, targets):
    """
    Find the workspace to switch to.

    - If the current workspace is a target, go to the next target.
    - If the current workspace isn't a target, go to the first open target.

    :param focused: The number of the open workspace.
    :param open_workspaces: The numbers of open workspaces.
    :param targets: The target workspaces.
    :return: The workspace to jump to.

    Current workspace isn't a target and we only have one target, so we should
    go to the target.
    >>> get_target_workspace(-1, [-1], [1])
    1

    Current workspace is a target, so go to the next target.
    >>> get_target_workspace(1, [1, 2], [1, 2])
    2
    >>> get_target_workspace(2, [1, 2], [1, 2])
    1

    Current workspace is not a target and not all targets are open, so we should
    go to the first open workspace.
    >>> get_target_workspace(-1, [2], [1, 2])
    2

    Current workspace is a target and not all targets are open, but we should
    still go to the first open workspace.
    >>> get_target_workspace(2, [2], [1, 2])
    1
    >>> get_target_workspace(1, [1], [1, 2])
    2
    """
    # TODO: support workspace names too
    logger.debug('get_target_workspace(current: %s, open: %s, targets: %s)',
                 focused, open_workspaces, targets)

    if len(targets) <= 0:
        logger.debug('No workspaces given - defaulting to current workspace %s',
                     focused)
        return focused

    if focused in targets:
        logger.debug('Current workspace is a target - going to next target')
        target_index = targets.index(focused) + 1
        target_index %= len(targets)
        return targets[target_index]

    logger.debug("Current workspace isn\'t a target - going to first open "
                 "target")
    for ws in targets:
        if ws in open_workspaces:
            logger.debug('Found open target %s - going there', ws)
            return ws

    logger.debug('No targets are open - going to the first')
    return targets[0]


def get_i3_state(i3: i3ipc.Connection):
    focused = None
    workspaces = []
    visible = []
    for ws in i3.get_workspaces():
        workspaces.append(ws.num)
        if ws.focused:
            current = ws.num
        if ws.visible:
            visible.append(ws.num)
    return focused, workspaces, visible


def main():
    """Main script entrypoint."""
    args = parser.parse_args()
    assert len(args.workspaces) > 0, "expected at least one target workspace"

    targets = args.workspaces
    i3 = i3ipc.Connection()

    focused, workspaces, visible = get_i3_state(i3)

    logging.debug('Current workspace number: %s', focused)

    logging.debug('Open workspaces: %s', workspaces)

    target = get_target_workspace(focused, workspaces, targets)
    logging.info('Going to workspace %s', target)

    if args.move:
        logging.info('Moving container to target workspace first')
        move_to(i3, target)
    go_to(i3, target)


if __name__ == '__main__':
    main()

