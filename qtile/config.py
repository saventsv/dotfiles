import os
import subprocess

from libqtile import bar, layout, qtile
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal


# ── Variables ────────────────────────────────────────────────

mod = "mod4"
alt = "mod1"
terminal = "kitty"
font = "Iosevka Term Nerd Font"

# Everforest colors
background = "#2d353b"
foreground = "#d3c6aa"
focused = "#a7c080"
unfocused = "#232a2e"
inactive = "#3d484d"
urgent = "#e67e80"

border_width = 4
gap = 10


# ── Startup ──────────────────────────────────────────────────

@lazy.function
def restart_autostart(qtile):
    qtile.spawn("picom")
    qtile.spawn("polybar")
    qtile.spawn(
        "feh --bg-fill --randomize /home/saven/Pictures/wallpapers"
    )
    qtile.spawn("dex --autostart --environment qtile")
    qtile.spawn("setxkbmap -option ctrl:nocaps")


# ── Keybindings ──────────────────────────────────────────────

keys = [
    # Applications
    Key([mod], "Return", lazy.spawn(terminal)),
    Key([alt], "space", lazy.spawn("rofi -show drun")),
    Key([mod], "m", lazy.spawn(
        "/home/saven/dotfiles/i3/system-menu.sh"
    )),

    # Close focused window
    Key([mod], "q", lazy.window.kill()),

    # Focus windows: Vim-style
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "l", lazy.layout.right()),

    # Focus windows: arrows
    Key([mod], "Left", lazy.layout.left()),
    Key([mod], "Down", lazy.layout.down()),
    Key([mod], "Up", lazy.layout.up()),
    Key([mod], "Right", lazy.layout.right()),

    # Move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),

    Key([mod, "shift"], "Left", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right()),

    # Split orientation / layout selection
    # Qtile uses different layout algorithms rather than
    # i3's explicit split tree.
    Key([mod], "s", lazy.group.setlayout("monadtall")),
    Key([mod], "f", lazy.group.setlayout("max")),
    Key([mod], "g", lazy.group.setlayout("matrix")),

    # Fullscreen and floating
    Key([mod, "shift"], "f", lazy.window.toggle_fullscreen()),
    Key([mod, "shift"], "space", lazy.window.toggle_floating()),
    Key([mod], "space", lazy.next_layout()),

    # Reload/restart Qtile
    Key([mod, "shift"], "c", lazy.reload_config()),
    Key([mod, "shift"], "r", lazy.restart()),

    # Resize mode
    KeyChord([mod], "r", [
        Key([], "h", lazy.layout.shrink()),
        Key([], "j", lazy.layout.grow_down()),
        Key([], "k", lazy.layout.grow_up()),
        Key([], "l", lazy.layout.grow()),

        Key([], "Left", lazy.layout.shrink()),
        Key([], "Down", lazy.layout.grow_down()),
        Key([], "Up", lazy.layout.grow_up()),
        Key([], "Right", lazy.layout.grow()),

        Key([], "Return", lazy.ungrab_chord()),
        Key([], "Escape", lazy.ungrab_chord()),
    ]),

    # Audio controls (PipeWire)
    Key([], "XF86AudioRaiseVolume",
        lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")),
    Key([], "XF86AudioLowerVolume",
        lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")),
    Key([], "XF86AudioMute",
        lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),

    # Brightness
    Key([], "XF86MonBrightnessUp",
        lazy.spawn("brightnessctl set +5%")),
    Key([], "XF86MonBrightnessDown",
        lazy.spawn("brightnessctl set 5%-")),
]


# ── Workspaces ───────────────────────────────────────────────

groups = [Group(str(i)) for i in range(1, 10)]
groups.append(Group("10"))

for i, group in enumerate(groups):
    key = str((i + 1) % 10)

    keys.extend([
        Key([mod], key, lazy.group[group.name].toscreen()),
        Key(
            [mod, "shift"], key,
            lazy.window.togroup(group.name, switch_group=False),
        ),
    ])


# ── Layouts ──────────────────────────────────────────────────

layouts = [
    layout.MonadTall(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
    layout.MonadWide(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
    layout.Tile(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
    layout.Columns(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
    layout.Stack(
        num_stacks=2,
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
    layout.TreeTab(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
        section_fg=foreground,
        section_bg=background,
        active_fg=background,
        active_bg=focused,
        inactive_fg=foreground,
        inactive_bg=inactive,
    ),
    layout.Matrix(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
    layout.Max(
        border_width=border_width,
        border_focus=focused,
        border_normal=unfocused,
        margin=gap,
    ),
]


# ── Floating windows ─────────────────────────────────────────

floating_layout = layout.Floating(
    border_width=border_width,
    border_focus=focused,
    border_normal=unfocused,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirm"),
        Match(wm_class="dialog"),
        Match(wm_class="download"),
        Match(wm_class="error"),
        Match(wm_class="file_progress"),
        Match(wm_class="notification"),
        Match(wm_class="splash"),
        Match(wm_class="toolbar"),
    ],
)


# ── Mouse controls ───────────────────────────────────────────

mouse = [
    Drag(
        [mod], "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]


# ── General settings ─────────────────────────────────────────

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"


# ── Screen / bar ─────────────────────────────────────────────

# Polybar is configured separately, so Qtile does not create
# a second status bar.
screens = [
    Screen(),
]


# ── Startup hooks ────────────────────────────────────────────

from libqtile import hook


@hook.subscribe.startup_once
def autostart():
    subprocess.Popen(["picom"])
    subprocess.Popen(["polybar"])
    subprocess.Popen([
        "feh", "--bg-fill", "--randomize",
        "/home/saven/Pictures/wallpapers",
    ])
    subprocess.Popen(["dex", "--autostart", "--environment", "qtile"])

@hook.subscribe.startup
def set_capslock_to_ctrl():
    subprocess.run(
        ["setxkbmap", "-option", "ctrl:nocaps"],
        check=False,
    )

