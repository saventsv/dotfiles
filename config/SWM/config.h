/* config.h */
#include <X11/Xlib.h>

/* Appearance */

static const char *color_active = "#5e81ac";
static const char *color_chord = "#b48ead";
static const char *color_inactive = "#3b4252";
static const int gaps = 5;
static const int border_width = 2;
static const double master_ratio = 0.5;
static const double scratchpad_width = 0.8;
static const double scratchpad_height = 0.7;

static const char *startup_commands[] = {
  "feh --bg-fill /home/saven/.config/dotfiles/config/SWM/wallpaper2.png &",
  "picom --config ~/.config/dotfiles/config/picom/picom.conf --daemon",
  "polybar nord-bar &",
  NULL         
};


/* Autostart */

static const Scratchpad scratchpads[] = {
  { "keepassxc", "keepassxc --class password_scratchpad", "password_scratchpad" },
  { "kitty", "kitty --class todos_scratchpad -e nvim ~/Notes/todo/mytodos.md ", "todos_scratchpad" },
};


/* Keybindings */
#define MOD Mod4Mask
#define ALT Mod1Mask
#define SHIFT ShiftMask

static const Keybinding keybindings[] = {
  /* modifier          key            function                argument */
  { MOD,               XK_Return,     spawn,                  { .c = "kitty"}  },
  { ALT,               XK_space,      spawn,                  { .c = "rofi -show drun"}  },
  { MOD | SHIFT,       XK_s,          spawn,                  { .c = "flameshot full -p ~/Pictures" }       },

  { MOD | SHIFT,       XK_e,          quit,                   { .v = NULL }    },
  { MOD,               XK_space,      activate_chord,         { .v = NULL }    },
  { MOD,               XK_q,          close_window,           { .v = NULL }    },

  { MOD,               XK_h,          focus,                  { .d = LEFT }    },
  { MOD,               XK_l,          focus,                  { .d = RIGHT }   },
  { MOD,               XK_k,          focus,                  { .d = UP }      },
  { MOD,               XK_j,          focus,                  { .d = DOWN }    },

  { MOD | SHIFT,       XK_h,          move_window,            { .d = LEFT }    },
  { MOD | SHIFT,       XK_l,          move_window,            { .d = RIGHT }   },
  { MOD | SHIFT,       XK_k,          move_window,            { .d = UP }      },
  { MOD | SHIFT,       XK_j,          move_window,            { .d = DOWN }    },
  
  { MOD,               XK_1,          focus_workspace,        { .i = 0 }       },
  { MOD,               XK_2,          focus_workspace,        { .i = 1 }       },
  { MOD,               XK_3,          focus_workspace,        { .i = 2 }       },
  { MOD,               XK_4,          focus_workspace,        { .i = 3 }       },
  { MOD,               XK_5,          focus_workspace,        { .i = 4 }       },
  { MOD,               XK_6,          focus_workspace,        { .i = 5 }       },
  { MOD,               XK_7,          focus_workspace,        { .i = 6 }       },
  { MOD,               XK_8,          focus_workspace,        { .i = 7 }       },
  { MOD,               XK_9,          focus_workspace,        { .i = 8 }       },

  { MOD | SHIFT,       XK_1,          move_window_workspace,  { .i = 0 }       },
  { MOD | SHIFT,       XK_2,          move_window_workspace,  { .i = 1 }       },
  { MOD | SHIFT,       XK_3,          move_window_workspace,  { .i = 2 }       },
  { MOD | SHIFT,       XK_4,          move_window_workspace,  { .i = 3 }       },
  { MOD | SHIFT,       XK_5,          move_window_workspace,  { .i = 4 }       },
  { MOD | SHIFT,       XK_6,          move_window_workspace,  { .i = 5 }       },
  { MOD | SHIFT,       XK_7,          move_window_workspace,  { .i = 6 }       },
  { MOD | SHIFT,       XK_8,          move_window_workspace,  { .i = 7 }       },
  { MOD | SHIFT,       XK_9,          move_window_workspace,  { .i = 8 }       },
};

static const Chord chords[] = {
  { XK_p, toggle_scratchpad, {.i = 0} },
  { XK_t, toggle_scratchpad, {.i = 1} },
  { XK_b, spawn, { .c = "zen-browser"}  },
  { XK_q, spawn, { .c = "systemctl poweroff"}  },
  { XK_w, spawn, { .c = "systemctl reboot"}  },
};

