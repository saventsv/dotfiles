#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <stdatomic.h>
#include <string.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <X11/X.h>

/* ==================== Global Constant Definitions ==================== */

#define MAX_WORKSPACES 9
#define MAX_CHORD 4
#define CLEANMASK(mask) (mask & ~(LockMask | numlockmask))  

/* ==================== Global Constant Definitions ==================== */
// We use a variable for numlock because its mask varies by system (usually Mod2Mask)
extern unsigned int numlockmask; 


/* ==================== Struct Definitions ==================== */

// Basic Hierarchy WindowManager -> Workspace -> Client

typedef enum
{
  TILED,
  FLOATING,
  SCRATCHPAD
} ClientType;

typedef enum
{
  RIGHT,
  LEFT,
  UP,
  DOWN
} Direction;

typedef struct Client
{
  Window window;
  int x, y, width, height;
  // Note that a client can either be floating or a scratchpad but not both
  ClientType type;
  int is_visible;
  // Linked list
  struct Client *next_client;
} Client;

typedef struct
{
  Client *master_client;
  Client *master_floating;
  Client *focused;
  Client *last_focused;
  // To check if active do NULL check
  int n_clients;
  int n_floating;
  int id;
} Workspace;

typedef struct 
{
  int current_workspace;
  Workspace workspaces[MAX_WORKSPACES];
  int key_state;
  // To make sure that focus follows mouse does not do any weird things
  int is_occupied;
  int running;
} WindowManager;


// Argument for shell commands and startup commands
typedef union 
{
  int i;
  const char *c;
  const void *v;
  Direction d;
} Arg;

// Keybinds and Key Chords

typedef struct 
{
  unsigned int mod;
  KeySym key;
  // Function pointer for callbacks
  void (*func)(Display *dpy, const Arg *arg);
  const Arg arg;
} Keybinding;

typedef struct 
{
  KeySym key;
  void (*func)(Display *dpy, const Arg *arg);
  const Arg arg;
} Chord;

// Productivity

typedef struct
{
  const char *name;
  const char *cmd;
  const char *class;
} Scratchpad;

typedef struct {
  int left, right, top, bottom;
} Strut;

Strut global_strut = {0};

/* ==================== User Accessible Function Declarations ==================== */

void focus(Display *dpy, const Arg *arg);

void move_window(Display *dpy, const Arg *arg);

void spawn(Display *dpy, const Arg *arg);

void activate_chord(Display *dpy, const Arg *arg);

void close_window(Display *dpy, const Arg *arg);

void focus_workspace(Display *dpy, const Arg *arg);

void move_window_workspace(Display *dpy, const Arg *arg);

void toggle_scratchpad(Display *dpy, const Arg *arg);

void quit(Display *dpy, const Arg *arg);

/* ==================== Global Variable Definitions ==================== */

WindowManager WM;


/* ==================== Function Definitions ==================== */

// Include user config file
#include "config.h"

int total_scratchpads = sizeof(scratchpads) / sizeof(Scratchpad);
int bar_height = 0;

unsigned long active_px;
unsigned long inactive_px;
unsigned long chord_px;

/* MISC */


void quit(Display *dpy, const Arg *arg)
{
  WM.running = 0;
}

unsigned int numlockmask = 0;

void setup_numlockmask(Display *dpy) {
  XModifierKeymap *modmap;
  KeyCode numlock_code = XKeysymToKeycode(dpy, XK_Num_Lock);
  modmap = XGetModifierMapping(dpy);

  // X11 has 8 modifiers: Shift, Lock, Control, and Mod1 through Mod5
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < modmap->max_keypermod; j++) {
      if (modmap->modifiermap[i * modmap->max_keypermod + j] == numlock_code) {
        numlockmask = (1 << i);
      }
    }
  }
  XFreeModifiermap(modmap);
}


int is_valid_client(Workspace *ws, Client *target_client)
{
  Client *client;

  for(client = ws -> master_client; client; client = client -> next_client)
    if(client == target_client)
      return 1;

  for(client = ws -> master_floating; client; client = client -> next_client)
    if(client == target_client)
      return 1;

  return 0;
}

void set_focus(Display *dpy, Workspace *ws, Client *client)
{

  if(!client || !is_valid_client(ws, client))
    return;

  // If is not a floating or scratchpad window

  ws -> last_focused = ws -> focused;
  ws -> focused = client;

  XSetInputFocus(
      dpy,
      client -> window,
      RevertToPointerRoot,
      CurrentTime
      );
}

void ensure_focus(Display *dpy, Workspace *ws)
{

  if(ws -> focused && is_valid_client(ws, ws -> focused))
    return;

  if(ws -> last_focused && is_valid_client(ws, ws -> last_focused))
  {
    set_focus(dpy, ws, ws -> last_focused);
    return;
  }

  if(ws -> master_client && is_valid_client(ws, ws -> master_client))
  {
    set_focus(dpy, ws, ws -> master_client);
    return;
  }

  if(ws -> master_floating && is_valid_client(ws, ws -> master_floating))
  {
    set_focus(dpy, ws, ws -> master_floating);
    return;
  }

}

unsigned long get_color(Display *dpy, const char *color_name) {
  Colormap cmap = DefaultColormap(dpy, DefaultScreen(dpy));
  XColor color;
  XAllocNamedColor(dpy, cmap, color_name, &color, &color);
  return color.pixel;
}

void cache_borders(Display *dpy)
{
  active_px = get_color(dpy, color_active);
  inactive_px = get_color(dpy, color_inactive);
  chord_px = get_color(dpy, color_chord);
}

void update_borders(Display *dpy) {
  Workspace *ws = &WM.workspaces[WM.current_workspace];

  Client *client = ws -> master_client;

  while(client)
  {
    if(client == ws -> focused && ws -> focused -> type == TILED)
    {
      if(WM.key_state == 0)
      {
        if(client -> window)
          XSetWindowBorder(dpy, client -> window, active_px);
      }
      else
      {
        if(client -> window)
          XSetWindowBorder(dpy, client -> window, chord_px);
      }
    }
    else
    {
      if(client -> window)
        XSetWindowBorder(dpy, client -> window, inactive_px);
    }
    client = client -> next_client;
  }

  client = ws -> master_floating;

  if(!client)
    return;
  while(client)
  {
    if(client == ws -> focused && ws -> focused -> type != TILED)
    {
      if(WM.key_state == 0)
      {
        if(client -> window)
          XSetWindowBorder(dpy, client -> window, active_px);
      }
      else
      {
        if(client -> window)
          XSetWindowBorder(dpy, client -> window, chord_px);
      }
    }
    else
    {
      if(client -> window)
        XSetWindowBorder(dpy, client -> window, inactive_px);
    }
    client = client -> next_client;
  }
}

// Function that Handles finding the height of a bar to allow for tile to accomodate the windows
void update_bar_height(Display *dpy)
{
  Atom strut_atom = XInternAtom(dpy, "_NET_WM_STRUT_PARTIAL", False);
  Atom type;
  int format;
  unsigned long nitems, bytes_after;
  unsigned char *data = NULL;

  bar_height = 0;

  Window root = DefaultRootWindow(dpy);
  Window parent, *children;
  unsigned int nchildren;

  if (!XQueryTree(dpy, root, &root, &parent, &children, &nchildren))
    return;

  for (unsigned int i = 0; i < nchildren; i++) 
  {
    if (XGetWindowProperty(dpy, children[i], strut_atom,
          0, 12, False, XA_CARDINAL,
          &type, &format, &nitems, &bytes_after,
          &data) == Success && data) 
    {

      long *strut = (long *)data;

      if (nitems >= 3 && strut[2] > bar_height) 
      {
        bar_height = strut[2];
      }

      XFree(data);
    }
  }

  if (children) XFree(children);
}

void update_current_desktop(Display *dpy)
{
  Atom net_current = XInternAtom(dpy, "_NET_CURRENT_DESKTOP", False);

  unsigned long current = WM.current_workspace;

  unsigned long num = MAX_WORKSPACES;

  XChangeProperty(
      dpy, 
      DefaultRootWindow(dpy), 
      net_current, 
      XA_CARDINAL, 
      32, 
      PropModeReplace, 
      (unsigned char *)&current, 
      1
      );
}

void set_number_of_desktops(Display *dpy) 
{
  Atom net_number = XInternAtom(dpy, "_NET_NUMBER_OF_DESKTOPS", False);

  unsigned long num = MAX_WORKSPACES;

  XChangeProperty(
      dpy,
      DefaultRootWindow(dpy),
      net_number,
      XA_CARDINAL,
      32,
      PropModeReplace,
      (unsigned char *)&num,
      1
      );
}

void set_supported_atoms(Display *dpy)
{
  Atom net_supported = XInternAtom(dpy, "_NET_SUPPORTED", False);

  Atom atoms[] = {
    XInternAtom(dpy, "_NET_CURRENT_DESKTOP", False),
    XInternAtom(dpy, "_NET_NUMBER_OF_DESKTOPS", False),
  };

  XChangeProperty(
      dpy, 
      DefaultRootWindow(dpy), 
      net_supported, 
      XA_ATOM, 
      32, 
      PropModeReplace, 
      (unsigned char *)atoms, 
      2
      );
}

int is_dock(Display *dpy, Window w)
{
  Atom type_atom = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE", False);
  Atom dock_atom = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE_DOCK", False);

  Atom actual_type;
  int format;
  unsigned long nitems, bytes_after;
  unsigned char *data = NULL;

  if (XGetWindowProperty(
        dpy, w, type_atom,
        0, 32, False, XA_ATOM,
        &actual_type, &format,
        &nitems, &bytes_after,
        &data) == Success && data)
  {
    Atom *atoms = (Atom *)data;

    for (unsigned long i = 0; i < nitems; i++)
    {
      if (atoms[i] == dock_atom)
      {
        XFree(data);
        return 1;
      }
    }

    XFree(data);
  }

  return 0;
}

void set_desktop_names(Display *dpy)
{
  Atom net_names = XInternAtom(dpy, "_NET_DESKTOP_NAMES", False);
  Atom utf8 = XInternAtom(dpy, "UTF8_STRING", False);

  const char *names[MAX_WORKSPACES] = {
    "1","2","3","4","5","6","7","8","9"
  };

  // Build null-separated string list
  char buffer[256] = {0};
  int offset = 0;

  for (int i = 0; i < MAX_WORKSPACES; i++)
  {
    int len = strlen(names[i]);
    memcpy(buffer + offset, names[i], len);
    offset += len + 1; // include null terminator
  }

  XChangeProperty(
      dpy,
      DefaultRootWindow(dpy),
      net_names,
      utf8,
      8,
      PropModeReplace,
      (unsigned char *)buffer,
      offset
      );
}

void init_wm()
{
  for(int i = 0; i < MAX_WORKSPACES; i++)
  {
    WM.workspaces[i].master_client = NULL;
    // -1 means no windows
    WM.workspaces[i].focused = NULL;
    WM.workspaces[i].last_focused = NULL;
    WM.workspaces[i].n_clients = 0;
    WM.workspaces[i].n_floating = 0;
    WM.workspaces[i].id = i;
  }
  WM.current_workspace = 0;
  WM.running = 1;
}

int has_proto(Display *dpy, Window w, Atom protocol) {
  Atom *protocols;
  int n, found = 0;

  if (XGetWMProtocols(dpy, w, &protocols, &n)) {
    while (!found && n--)
      found = protocols[n] == protocol;
    XFree(protocols);
  }
  return found;
}

int is_scratchpad(Display *dpy, Client *client)
{
  XClassHint class_hint = {0};

  if(!XGetClassHint(dpy, client -> window, &class_hint))
    return 0;

  int result = 0;

  for(int i = 0; i < total_scratchpads; i++)
  {
    if(
        scratchpads[i].class && 
        class_hint.res_class && 
        strcmp(class_hint.res_class, scratchpads[i].class) == 0
      )
    {
      result = 1;
      break;
    }
  }

  if(class_hint.res_name) XFree(class_hint.res_name);
  if(class_hint.res_class) XFree(class_hint.res_class);

  return result;
}

int is_visible(Display *dpy, Window w)
{
  XWindowAttributes attr;
  if(!XGetWindowAttributes(dpy, w, &attr))
    return 0;

  return (attr.map_state == IsViewable);
}

Client *find_scratchpad(Display *dpy, int index)
{
  if(index < 0 || index >= total_scratchpads)
    return NULL;

  Workspace *ws = &WM.workspaces[WM.current_workspace];
  Client *client = ws -> master_floating;

  while(client)
  {
    XClassHint class_hint = {0};

    if(XGetClassHint(dpy, client->window, &class_hint))
    {
      if(class_hint.res_class &&
          strcmp(class_hint.res_class, scratchpads[index].class) == 0)
      {
        if(class_hint.res_name) XFree(class_hint.res_name);
        if(class_hint.res_class) XFree(class_hint.res_class);
        return client;
      }

      if(class_hint.res_name) XFree(class_hint.res_name);
      if(class_hint.res_class) XFree(class_hint.res_class);
    }

    client = client -> next_client;
  }

  return NULL;
}



/* Windows */

void tile_scratchpad(Display *dpy)
{

  Workspace *ws = &WM.workspaces[WM.current_workspace];
  int screen = DefaultScreen(dpy);
  int screen_width = DisplayWidth(dpy, screen);
  int screen_height = DisplayHeight(dpy, screen);

  int pad_width = screen_width * scratchpad_width;
  int pad_height = screen_height * scratchpad_height;
  int pad_x = (screen_width - pad_width) / 2;
  int pad_y = (screen_height - pad_height) / 2;

  // NULL check
  if(!ws -> master_floating)
    return;
  Client *client = ws -> master_floating;

  while(client)
  {
    XMoveResizeWindow(
        dpy, 
        client -> window, 
        pad_x, 
        pad_y, 
        pad_width - (gaps * 2) - (border_width * 2), 
        pad_height - (gaps * 2) - (border_width * 2)
        );
    XRaiseWindow(dpy, client -> window);

    client -> x = pad_x;
    client -> y = pad_y;
    client -> width = pad_width;
    client -> height = pad_height;

    XSetWindowBorderWidth(dpy, client -> window, border_width);

    if(client == ws -> focused)
      XSetWindowBorder(dpy, client -> window, active_px);
    else
      XSetWindowBorder(dpy, client -> window, inactive_px);
    client = client -> next_client;
  }

}

void tile(Display *dpy)
{

  WM.is_occupied = 1;

  Workspace *ws = &WM.workspaces[WM.current_workspace];
  if(!ws -> master_client) return;

  update_bar_height(dpy);

  // Needed Declarations
  int screen = DefaultScreen(dpy);
  int screen_width = DisplayWidth(dpy, screen);
  int screen_height = DisplayHeight(dpy, screen) - bar_height;


  // MASTER_RATIO from conifig file
  int master_width = ws -> n_clients > 1 ? screen_width * master_ratio: screen_width ;
  int master_height = screen_height;
  int stack_width = screen_width - master_width;
  int stack_x = master_width;

  int offset_y = bar_height;


  Client *client = ws -> master_client;

  int i = 0;
  while(client) 
  {
    // If Master
    if (i == 0) 
    {
      XSetWindowBorderWidth(dpy, client -> window, border_width);
      if(client == ws -> focused)
        XSetWindowBorder(dpy, client -> window, active_px);
      else
        XSetWindowBorder(dpy, client -> window, inactive_px);
      XMoveResizeWindow(
          dpy, 
          client -> window, 
          0 + gaps, 
          offset_y + gaps, 
          master_width - (gaps * 2) - (border_width * 2), 
          master_height - (gaps * 2) - (border_width * 2)
          );
      client -> x = 0;
      client -> y = 0;
      client -> width = master_width;
      client -> height = master_height;
    }
    else
    {
      int stack_count = ws -> n_clients - 1;
      if(stack_count <= 0)
      {
        client = client -> next_client;
        i++;
        continue;
      }
      int stack_height = screen_height / stack_count;
      int stack_y = stack_height * (i - 1);

      XSetWindowBorderWidth(dpy, client -> window, border_width);

      if(client == ws -> focused)
        XSetWindowBorder(dpy, client -> window, active_px);
      else
        XSetWindowBorder(dpy, client -> window, inactive_px);

      XMoveResizeWindow(
          dpy, 
          client -> window, 
          stack_x + gaps, 
          stack_y + gaps + offset_y, 
          stack_width - (gaps * 2) - (border_width * 2), 
          stack_height - (gaps * 2) - (border_width * 2)
          );
      client -> x = stack_x;
      client -> y = stack_y;
      client -> width = stack_width;
      client -> height = stack_height;
    }
    client = client -> next_client;
    i++;
  }
  WM.is_occupied = 0;
}

Client *find_prev_client(Workspace *ws, Client *client)
{
  Client *prev_client = NULL;
  Client *curr_client = ws -> master_client;

  while(curr_client)
  {
    if (curr_client == client)
      return prev_client;

    prev_client = curr_client;
    curr_client = curr_client -> next_client;
  }

  return NULL;
}

Client *find_prev_floating(Workspace *ws, Client *client)
{
  Client *prev_client = NULL;
  Client *curr_client = ws -> master_floating;

  while(curr_client)
  {
    if (curr_client == client)
      return prev_client;

    prev_client = curr_client;
    curr_client = curr_client -> next_client;
  }

  return NULL;
}

Client *find_last_client(Workspace *ws)
{
  Client *last_client = ws -> master_client;

  if(!last_client) return NULL;

  while(last_client -> next_client)
  {
    last_client = last_client -> next_client;
  }

  return last_client;
}

Client *find_last_floating(Workspace *ws)
{
  Client *last_client = ws -> master_floating;

  if(!last_client) return NULL;

  while(last_client -> next_client)
    last_client = last_client -> next_client;

  return last_client;
}

void focus(Display *dpy, const Arg *arg) 
{
  Workspace *ws = &WM.workspaces[WM.current_workspace];
  Client *client = ws -> master_client;
  Client *new_focus = NULL;
  // i will be used as a index
  int i = 0;

  if(!arg) return;
  if(ws -> n_clients < 2) return;

  switch(arg -> d)
  {

    case LEFT:
      {
        while(client)
        {
          if(client == ws -> focused)
          {
            if(i > 0)
            {
              new_focus = ws -> master_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
            else 
            {
              new_focus = ws -> master_client -> next_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
          }
          i++;
          client = client -> next_client;
        }
        break;
      }
    case RIGHT:
      {
        while(client)
        {
          if(client == ws -> focused)
          {
            if(i == 0)
            {
              if(ws -> last_focused && is_valid_client(ws, ws -> last_focused) && ws -> last_focused != ws -> master_client)
              {
                if(ws -> last_focused && is_valid_client(ws, ws -> last_focused))
                  new_focus = ws -> last_focused;
              }
              else
                new_focus = ws -> master_client -> next_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
            else
            {
              new_focus = ws -> master_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
          }
          i++;
          client = client -> next_client;
        }
        break;
      }
    case UP:
      {
        while(client)
        {
          if(client == ws -> focused)
          {
            if(i == 0)
            {
              Client *last_client = find_last_client(ws);
              new_focus = last_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
            else if (i == 1)
            {
              new_focus = ws -> master_client;
              set_focus(dpy, ws, new_focus);
              break;
            } 
            else
            {
              Client *prev_client = find_prev_client(ws, client);
              new_focus = prev_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
          }
          i++;
          client = client -> next_client;
        }
        break;
      }
    case DOWN:
      {
        while(client)
        {
          if(client == ws -> focused)
          {
            if(client -> next_client == NULL)
            {
              new_focus = ws -> master_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
            else
            {
              new_focus = ws -> focused -> next_client;
              set_focus(dpy, ws, new_focus);
              break;
            }
          }
          i++;
          client = client -> next_client;
        }
        break;
      }
  }
}

void focus_workspace(Display *dpy, const Arg *arg)
{
  WM.is_occupied = 1;

  // NULL check and check if in range for workspaces
  if (!arg || arg -> i < 0 || arg -> i >= MAX_WORKSPACES || arg -> i == WM.current_workspace)
    return;

  Workspace *old_ws = &WM.workspaces[WM.current_workspace]; 


  Client *client = old_ws -> master_client;

  while(client)
  {
    XUnmapWindow(dpy, client -> window);

    if(client -> type != TILED)
      client -> is_visible = 0;
    client = client -> next_client;
  }

  WM.current_workspace = arg -> i;

  Workspace *ws = &WM.workspaces[WM.current_workspace]; 

  client = ws -> master_client;

  while(client)
  {
    if(client -> type != SCRATCHPAD || client -> is_visible)
      XMapWindow(dpy, client -> window);
    client = client -> next_client;
  }

  if(ws -> focused)
    set_focus(dpy, ws, ws -> focused);
  else
    XSetInputFocus(dpy, DefaultRootWindow(dpy), RevertToPointerRoot, CurrentTime);

  update_current_desktop(dpy);

  tile(dpy);
  update_borders(dpy);

  WM.is_occupied = 0;
}

void move_window_workspace(Display *dpy, const Arg *arg)
{

  // Range and NULL Check
  if (!arg || arg -> i < 0 || arg -> i >= MAX_WORKSPACES || arg -> i == WM.current_workspace)
    return;

  Workspace *curr_ws = &WM.workspaces[WM.current_workspace];
  Workspace *new_ws = &WM.workspaces[arg -> i];
  Client *client = NULL;


  // Check if There is a Window to Move
  if(!curr_ws -> focused) 
    return;

  client = curr_ws -> focused;

  Client *prev_client = NULL;

  if(client -> type == TILED)
    prev_client = find_prev_client(curr_ws, client);
  else
    prev_client = find_prev_floating(curr_ws, client);

  if(client -> type == TILED)
  {
    if(client == curr_ws -> master_client)
      curr_ws -> master_client = client -> next_client;
    else
      prev_client -> next_client = client -> next_client;

    if(!new_ws -> master_client)
      new_ws -> master_client = client;
    else
    {
      Client *last_client = find_last_client(new_ws);
      last_client -> next_client = client;
      client -> next_client = NULL;
    }

    set_focus(dpy, new_ws, client);
  }
  else
  {
    if(client == curr_ws -> master_floating)
      curr_ws -> master_floating = client -> next_client;
    else
      prev_client -> next_client = client -> next_client;

    if(!new_ws -> master_floating)
      new_ws -> master_floating = client;
    else
    {
      Client *last_client = find_last_floating(new_ws);
      last_client -> next_client = client;
      client -> next_client = NULL;
    }

  }

  if(client -> type == TILED)
  {
    curr_ws -> n_clients--;
    new_ws -> n_clients++;
  }
  else
  {
    curr_ws -> n_floating--;
    new_ws -> n_floating++;
  }

  if(curr_ws -> focused == client) curr_ws -> focused = NULL;
  if(curr_ws -> last_focused == client) curr_ws -> last_focused = NULL;

  focus_workspace(dpy, arg);
  tile_scratchpad(dpy);
  tile(dpy);
  set_focus(dpy, new_ws, client);
  update_borders(dpy);
}


void swap_next_client(Client *client)
{

  Workspace *ws = &WM.workspaces[WM.current_workspace];

  // NULL check 
  if(!client || !client -> next_client) return;

  Client *next_client = client -> next_client;
  Client *prev_client = find_prev_client(ws, client);

  client -> next_client = next_client -> next_client;
  next_client -> next_client = client;

  if(prev_client)
    prev_client -> next_client = next_client;
  else 
    ws -> master_client = next_client;
}

void swap_with_prev(Client *client)
{
  Workspace *ws = &WM.workspaces[WM.current_workspace];
  Client *prev_client = find_prev_client(ws, client);
  if(!prev_client)
    return;
  swap_next_client(prev_client);
}

void move_window(Display *dpy, const Arg *arg)
{
  // Needed Declarations
  Workspace *ws = &WM.workspaces[WM.current_workspace];
  Client *client = ws -> focused;
  Client *new_focus = NULL;

  if(client -> type != TILED)
    return;

  // NULL and range check
  if(!arg) return;

  switch(arg -> d)
  {

    case LEFT:
      {
        // If trying to move master client left don't do anything
        if (!client || client == ws -> master_client) break;

        Client *prev_client = find_prev_client(ws, client);
        Client *master = ws -> master_client;

        if(!prev_client) break;

        if(prev_client == master)
        {
          master -> next_client = client -> next_client;
          client -> next_client = master;
          ws -> master_client = client;
        }
        else
        {
          Client *tmp = master -> next_client;

          prev_client -> next_client = master;
          master -> next_client = client -> next_client;
          client -> next_client = tmp;
          ws -> master_client = client;
        }

        new_focus = ws -> master_client;

        set_focus(dpy, ws, new_focus);
        tile(dpy);
        update_borders(dpy);
        break;
      }
    case RIGHT:
      {
        // If it is not master don't do anything because it is in the stack
        if(client != ws -> master_client) break;
        swap_next_client(ws -> master_client);
        new_focus = ws -> master_client -> next_client;
        set_focus(dpy, ws, new_focus);
        tile(dpy);
        update_borders(dpy);
        break;
      }
    case UP:
      {
        if(client == ws -> master_client) break;

        swap_with_prev(client);
        Client *curr_client = ws -> master_client;
        if(client == ws -> master_client)
        {
          new_focus = ws -> master_client;
          set_focus(dpy, ws, new_focus);
        }
        else
        {
          while(curr_client -> next_client != client)
            curr_client = curr_client -> next_client;
          new_focus = curr_client -> next_client;
          set_focus(dpy, ws, new_focus);
        }
        tile(dpy);
        update_borders(dpy);
        break;
      }
    case DOWN:
      {
        if(client == find_last_client(ws)) break;

        swap_next_client(client);
        new_focus = client;
        set_focus(dpy, ws, new_focus);
        tile(dpy);
        update_borders(dpy);
        break;
      }
  }
}

void close_window(Display *dpy, const Arg *arg)
{
  Workspace *ws = &WM.workspaces[WM.current_workspace];
  Client *client = ws -> focused;

  if(!client)
    return;

  Atom WM_DELETE_WINDOW = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
  Atom WM_PROTOCOLS = XInternAtom(dpy, "WM_PROTOCOLS", False);
  Atom proto = XInternAtom(dpy, "WM_DELETE_WINDOW", False);

  XEvent event = {0};

  if(has_proto(dpy, client -> window, proto))
  {
    event.xclient.type = ClientMessage;
    event.xclient.window = client -> window;
    event.xclient.message_type = WM_PROTOCOLS;
    event.xclient.format = 32;
    event.xclient.data.l[0] = WM_DELETE_WINDOW;
    event.xclient.data.l[1] = CurrentTime;
    XSendEvent(dpy, client -> window, False, NoEventMask, &event);
  } else {
    XKillClient(dpy, client -> window);
  }

  XFlush(dpy);
}


void toggle_scratchpad(Display *dpy, const Arg *arg) 
{
  if(!arg) return;

  if(arg -> i < 0 || arg -> i >= total_scratchpads)
    return;

  Workspace *ws = &WM.workspaces[WM.current_workspace];

  Client *client = find_scratchpad(dpy, arg -> i);
  Client *new_focus = ws -> master_client;

  if(client)
  {
    if(is_visible(dpy, client -> window))
    {
      XUnmapWindow(dpy, client -> window);
      client -> is_visible = 0;


      if (ws -> focused == client)
      {
        ws -> focused = NULL;
        new_focus = ws -> master_client;
      }

      if (new_focus)
        set_focus(dpy, ws, new_focus);
      else
        XSetInputFocus(dpy, DefaultRootWindow(dpy), RevertToPointerRoot, CurrentTime);
    }
    else
    {
      XMapRaised(dpy, client -> window);
      client -> is_visible = 1;
      new_focus = client;
      set_focus(dpy, ws, new_focus);
    }
  }
  else
  {
    Arg spawn_arg = {.c = scratchpads[arg -> i].cmd};
    spawn(dpy, &spawn_arg);
  }

  tile(dpy);
  tile_scratchpad(dpy);
  update_borders(dpy);
}

void handle_chord(Display *dpy, const Chord chords[], int n_chords, KeySym key) {

  for(int i = 0; i < n_chords; i++) {
    if(chords[i].key == key) {
      chords[i].func(dpy, &chords[i].arg);

      // EXIT chord mode after success
      WM.key_state = 0;
      XUngrabKeyboard(dpy, CurrentTime);
      return;
    }
  }

  // If no match, also exit
  WM.key_state = 0;
  XUngrabKeyboard(dpy, CurrentTime);
}

void activate_chord(Display *dpy, const Arg *arg) {
  WM.key_state = 1;

  if (XGrabKeyboard(dpy, DefaultRootWindow(dpy), True,
        GrabModeAsync, GrabModeAsync, CurrentTime) != GrabSuccess) {
    WM.key_state = 0; 
  }
}



void unlink_client(Display *dpy, Workspace *ws, Client *client)
{
  if(client -> type == TILED)
  {
    if(client == ws -> master_client)
      ws -> master_client = ws -> master_client -> next_client;
    else
    {
      Client *prev_client = find_prev_client(ws, client);
      if(!prev_client)
      {
        fprintf(stderr, "unlink_client: broken list");
        abort();
      }
      prev_client -> next_client = client -> next_client;
    }
  }
  else
  {
    if(client == ws -> master_floating)
      ws -> master_floating = ws -> master_floating -> next_client;
    else
    {
      Client *prev_client = find_prev_floating(ws, client);
      if(!prev_client) 
        return;
      else
        prev_client -> next_client = client -> next_client;
    }
  }
  client -> next_client = NULL;

  if(ws -> focused == client) ws -> focused = NULL;
  if(ws -> last_focused == client) ws -> last_focused = NULL;
}

void destroy_client(Display *dpy, Workspace *ws, Client *client)
{
  if(!client) return;

  Client *new_focus = NULL;
  Client *prev_client = NULL;

  if(client -> type == TILED)
    prev_client = find_prev_client(ws, client);
  else
    prev_client = find_prev_floating(ws, client);

  unlink_client(dpy, ws, client);


  if(client -> type == TILED)
  {
    if(ws -> last_focused && is_valid_client(ws, ws -> last_focused))
      new_focus = ws -> last_focused;
    else if(prev_client && is_valid_client(ws, prev_client))
      new_focus = prev_client;
    else if(ws -> master_client && is_valid_client(ws, ws -> master_client))
      new_focus = ws -> master_client;
    else if(ws -> master_floating && is_valid_client(ws, ws -> master_floating))
      new_focus = ws -> master_floating;
    else
      new_focus = NULL;
  }
  else
  {
    if(ws -> last_focused && is_valid_client(ws, ws -> last_focused))
      new_focus = ws -> last_focused;
    else if(prev_client && is_valid_client(ws, prev_client))
      new_focus = prev_client;
    else if(ws -> master_floating && is_valid_client(ws, ws -> master_floating))
      new_focus = ws -> master_floating;
    else if(ws -> master_client && is_valid_client(ws, ws -> master_client))
      new_focus = ws -> master_client;
    else
      new_focus = NULL;
  }

  if(client -> type == FLOATING || client -> type == SCRATCHPAD)
    ws -> n_floating--;
  else
    ws -> n_clients--;

  if(new_focus == client)
    new_focus = NULL;

  free(client);
  client = NULL;

  if(new_focus)
    set_focus(dpy, ws, new_focus);
  else
    XSetInputFocus(dpy, DefaultRootWindow(dpy), RevertToPointerRoot, CurrentTime);

  ensure_focus(dpy, ws);
}


/* Executing Commands */

void spawn(Display *dpy, const Arg *arg)
{
  if (!arg || !arg -> c) return;

  pid_t pid = fork();

  if (pid == 0)
  {
    setsid();
    execl("/bin/sh", "sh", "-c", arg -> c, NULL);
    perror("execl");
    exit(1);
  }
}

void run_startup(Display *dpy) 
{
  for (int i = 0; startup_commands[i] != NULL; i++) 
  {
    Arg arg = { .c = startup_commands[i] };
    spawn(dpy, &arg);
  }
}


/* ==================== Main ==================== */

int main()
{
  // Get Monitor and Events
  Display *dpy;
  XEvent event;

  // Open Display
  if(!(dpy = XOpenDisplay(0x0))) return 1;

  // Init Window Manager
  init_wm();
  setup_numlockmask(dpy);
  set_supported_atoms(dpy);
  set_number_of_desktops(dpy);
  set_desktop_names(dpy);
  update_current_desktop(dpy);
  run_startup(dpy);
  cache_borders(dpy);


  // Keybind Declarations
  unsigned int locks[] = {
    0,
    LockMask,
    numlockmask,
    LockMask | numlockmask
  };

  int n_chords = sizeof(chords) / sizeof(chords[0]);
  int n_keys = sizeof(keybindings) / sizeof(keybindings[0]);
  int n_locks = sizeof(locks) / sizeof(unsigned int);

  // Loop to have X11 pass all the keys we want to us
  for (int i = 0; i < n_keys; i++)
  {
    for(int j = 0; j < n_locks; j++) 
    {
      XGrabKey(
          dpy, 
          XKeysymToKeycode(dpy, keybindings[i].key), 
          keybindings[i].mod | locks[j], 
          DefaultRootWindow(dpy), 
          True, 
          GrabModeAsync, 
          GrabModeAsync
          );
    }
  }

  // Get Input From X11
  XSelectInput(
      dpy, 
      DefaultRootWindow(dpy), 
      SubstructureNotifyMask | SubstructureRedirectMask
      );


  while(WM.running) 
  {
    XFlush(dpy);
    XNextEvent(dpy, &event);

    switch(event.type)
    {
      // Handle KeyPresses
      case KeyPress:
        {
          // Definitions
          KeySym key = XLookupKeysym(&event.xkey, 0);
          unsigned int mods = event.xkey.state;
          unsigned int cleanmods = CLEANMASK(mods);

          // Means We Are In a Key Chord
          if(WM.key_state == 1) 
          {
            handle_chord(dpy, chords, n_chords, key);
            tile(dpy);
            update_borders(dpy);
            break;
          }

          // Call regular binds
          for(int i = 0; i < n_keys; i++)
          {
            if (keybindings[i].key == key && CLEANMASK(keybindings[i].mod) == cleanmods)
            {
              keybindings[i].func(dpy, &keybindings[i].arg);
              break;
            }
          }

          // Tile to be safe
          tile(dpy);
          update_borders(dpy);
          break;
        }


        // Called when a window is summoned
      case MapRequest:
        {

          Workspace *ws = &WM.workspaces[WM.current_workspace];

          if(is_dock(dpy, event.xmaprequest.window))
          {
            XMapWindow(dpy, event.xmaprequest.window);
            break;
          }


          // Make space for Client
          Client *client = malloc(sizeof(Client));
          Client *new_focus = NULL;

          // If malloc fails break
          if(!client)
            break;



          client -> window = event.xmaprequest.window;
          XSelectInput(dpy, client -> window, EnterWindowMask);

          client -> next_client = NULL;
          client -> x = 0;
          client -> y = 0;
          client -> width = 0;
          client -> height = 0;
          client -> type = TILED;
          client -> is_visible = 1;

          if(is_scratchpad(dpy, client))
          {
            client -> type = SCRATCHPAD;
            ws -> n_floating++;
          }
          else
            ws -> n_clients++;

          Client *current_client;

          if(client -> type == TILED)
          {
            current_client = ws -> master_client;
            if(current_client == NULL)
            {
              ws -> master_client = client;
              new_focus = client;
            }
            else
            {
              // Iterate Through Clients
              while(current_client -> next_client != NULL)
                current_client = current_client -> next_client;

              // When the Last Client is Found Set its next_client Equal to The New Client
              current_client -> next_client = client;
              new_focus = client;
            }
          } 
          else 
          {
            current_client = ws -> master_floating;

            if(current_client == NULL)
            {
              ws -> master_floating = client;
              new_focus = client;
            }
            else 
            {
              while(current_client -> next_client)
                current_client = current_client -> next_client;
              current_client -> next_client = client;
              new_focus = client;
            }
          }

          XMapWindow(dpy, client -> window);
          tile(dpy);
          tile_scratchpad(dpy);
          set_focus(dpy, ws, new_focus);
          update_borders(dpy);

          break;
        }


        // When a window requests a size
      case ConfigureRequest:
        {
          // Get the event so we have access to wanted size
          XConfigureRequestEvent *configure_event = &event.xconfigurerequest;
          XWindowChanges wc;

          wc.stack_mode = configure_event -> detail;

          Workspace *ws = &WM.workspaces[WM.current_workspace];
          Client *client = ws -> master_client;
          int managed = 0;

          while(client)
          {
            if (client -> window == configure_event -> window)
            {
              managed = 1;
              break;
            }
            client = client -> next_client;
          }

          if(!managed)
          {

            wc.x = configure_event -> x;
            wc.y = configure_event -> y;
            wc.width = configure_event -> width;
            wc.height = configure_event -> height;
            wc.border_width = configure_event -> border_width;
            wc.sibling = configure_event -> above;
            wc.stack_mode = configure_event -> detail;

            XConfigureWindow(dpy, configure_event -> window, configure_event -> value_mask, &wc);
          }

          update_borders(dpy);
          tile_scratchpad(dpy);
          tile(dpy);
          break;
        }

        // When a window closes
      case DestroyNotify:
        {
          // Definitions
          Workspace *ws = &WM.workspaces[WM.current_workspace];
          Client *client = ws -> master_client;
          Client *prev_client = NULL;

          // Find Client
          while(client)
          {
            if(client -> window == event.xdestroywindow.window)
              break;
            prev_client = client;
            client = client -> next_client;
          }

          // NULL Check
          if(!client)
          {
            client = ws -> master_floating;
            prev_client = NULL;
            while(client)
            {
              if(client -> window == event.xdestroywindow.window)
                break;
              prev_client = client;
              client = client -> next_client;
            }
          }

          if(!client)
            break;

          destroy_client(dpy, ws, client);

          tile(dpy);
          tile_scratchpad(dpy);
          update_borders(dpy);
          break;
        }

      case EnterNotify:
        {
          if(WM.is_occupied) 
            break;

          XCrossingEvent *crossing_event = &event.xcrossing;
          Workspace *ws = &WM.workspaces[WM.current_workspace];

          if(crossing_event -> mode != NotifyNormal || crossing_event -> detail == NotifyInferior)
            break;

          Client *client = ws -> master_client;

          // Loop through tiled clients
          while(client)
          {
            if(client -> window == crossing_event -> window)
              break;
            client = client -> next_client;
          }

          // Loop through floating clients
          if(!client)
          {
            client = ws -> master_floating;
            while(client)
            {
              if (client -> window == crossing_event -> window)
                break;
              client = client -> next_client;
            }
          }

          // NULL check and prevent focusing already focused clients
          if(!client || client == ws -> focused) 
            break;

          set_focus(dpy, ws, client);
          update_borders(dpy);
          break;
        }

    }
  }

}


