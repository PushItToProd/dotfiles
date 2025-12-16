# Functional Tests for `aerospace_navigate.py`

TODO: automate these.

For now, just documenting how I do these manually.

Run all these tests from a workspace that isn't 990, 995, or 999.

## `toggle` test cases

### Test case 1: navigate to first workspace in list

```sh
python aerospace_navigate.py --dry-run toggle 990 995 999
```

Expected output:

```
[DEBUG] main_toggle - Focused workspace: $CURRENT_WORKSPACE
[DEBUG] main_toggle - Open workspaces: [...]
[DEBUG] main_toggle - Visible workspaces: [$CURRENT_WORKSPACE]
[DEBUG] get_target_workspace - Focused workspace isn't a target - going to first open or visible target
[DEBUG] get_target_workspace - No targets are open - going to the first
[INFO] main_toggle - Going to workspace 990
[INFO] main_toggle - Dry run - exiting
```

### Test case 2a: navigate to second workspace in list when we're on the first

```sh
aerospace workspace 990
python aerospace_navigate.py --dry-run toggle 990 995
aerospace workspace-back-and-forth
```

Expected output:

```
[DEBUG] main_toggle - Focused workspace: 990
[DEBUG] main_toggle - Open workspaces: [..., '990']
[DEBUG] main_toggle - Visible workspaces: ['990']
[DEBUG] get_target_workspace - Focused workspace is a target - going to next target
[INFO] main_toggle - Going to workspace 995
[INFO] main_toggle - Dry run - exiting
```

### Test case 2b: navigate to second workspace in list when we're on the first

```sh
aerospace workspace 990
python aerospace_navigate.py --dry-run toggle 990 995 999
aerospace workspace-back-and-forth
```

Expected output:

```
[DEBUG] main_toggle - Focused workspace: 990
[DEBUG] main_toggle - Open workspaces: [..., '990']
[DEBUG] main_toggle - Visible workspaces: ['990']
[DEBUG] get_target_workspace - Focused workspace is a target - going to next target
[INFO] main_toggle - Going to workspace 995
[INFO] main_toggle - Dry run - exiting
```

### Test case 3a: navigate back to the first workspace when we're on the second and there are only two in the list

```sh
aerospace workspace 995
python aerospace_navigate.py --dry-run toggle 990 995
aerospace workspace-back-and-forth
```

Expected output:

```
[DEBUG] main_toggle - Focused workspace: 995
[DEBUG] main_toggle - Open workspaces: ['10', '15', '20', '25', '40', '60', '70', '80', '95', '995']
[DEBUG] main_toggle - Visible workspaces: ['995']
[DEBUG] get_target_workspace - Focused workspace is a target - going to next target
[INFO] main_toggle - Going to workspace 990
[INFO] main_toggle - Dry run - exiting
```

### Test case 3b: navigate to third workspace in list when we're on the second and there's a third target in the list

```sh
aerospace workspace 995
python aerospace_navigate.py --dry-run toggle 990 995 999
aerospace workspace-back-and-forth
```

Expected output:

```
[DEBUG] main_toggle - Focused workspace: 995
[DEBUG] main_toggle - Open workspaces: [..., '995']
[DEBUG] main_toggle - Visible workspaces: ['995']
[DEBUG] get_target_workspace - Focused workspace is a target - going to next target
[INFO] main_toggle - Going to workspace 999
[INFO] main_toggle - Dry run - exiting
```
