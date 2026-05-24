#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <memory>
#include <optional>
#include <set>
#include <string.h>
#include <string>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <X11/X.h>
#include <unordered_map>
#include <utility>
#include <vector>

extern "C"
{
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

/* ==================== Global Constant Definitions ==================== */

#define MAX_WORKSPACES 9
#define MAX_CHORD 4
#define CLEANMASK(mask) (mask & ~(LockMask | numlockmask))  
#define MASTER_IDX 0

/* ==================== Global Constant Definitions ==================== */
// We use a variable for numlock because its mask varies by system (usually Mod2Mask)
unsigned int numlockmask = 0; 

int bar_height = 0;

unsigned int locks[] = {
  0,
  LockMask,
  numlockmask,
  LockMask | numlockmask
};

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
  KeySym key;
  unsigned int mod;
  int lua_ref;
  bool is_chord_prefix;
} KeyBind;

typedef struct {
  int left, right, top, bottom;
} Strut;

Strut global_strut = {0};

class Client
{
  public:
    Window window;
    int x, y, width, height;
    // Note that a client can either be floating or a scratchpad but not both
    ClientType type;
    bool visible;

    Client(Window window)
    {
      this -> window = window;
      x = 0;
      y = 0;
      width = 0;
      height = 0;
      type = TILED;
      visible = true;
    }
};


typedef struct 
{
  float master_ratio;
  int gaps;
  int border_width;
  float scratchpad_width;
  float scratchpad_height;
  unsigned long active_px;
  unsigned long inactive_px;
  unsigned long chord_px;
  const char *color_active;
  const char *color_inactive;
  const char *color_chord;
} WMConfig;

class WindowManager;

class Workspace
{
  public:
    std::vector<std::unique_ptr<Client>> clients;
    int focused;
    int last_focused;
    int n_clients;
    int n_floating;
    int id;

    void tile(Display *dpy, const WMConfig &config)
    {

      if(this -> clients.empty()) return;

      update_bar_height(dpy);

      // Needed Declarations
      int screen = DefaultScreen(dpy);
      int screen_width = DisplayWidth(dpy, screen);
      int screen_height = DisplayHeight(dpy, screen) - bar_height;


      // MASTER_RATIO from conifig file
      int master_width = this -> n_clients - this -> n_floating > 1 ? screen_width * config.master_ratio: screen_width ;
      int master_height = screen_height;
      int stack_width = screen_width - master_width;
      int stack_x = master_width;

      int offset_y = bar_height;


      if(this -> clients.empty())
        return;

      for(int i = 0; i < this -> n_clients; i++) 
      {

        Client &client = *this -> clients[i];
        if(client.type != TILED)
        {
          int pad_width = screen_width *  config.scratchpad_width;
          int pad_height = screen_height * config.scratchpad_height;
          int pad_x = (screen_width - pad_width) / 2;
          int pad_y = (screen_height - pad_height) / 2;

          // NULL check

          XMoveResizeWindow(
              dpy, 
              client.window, 
              pad_x, 
              pad_y, 
              pad_width - (config.gaps * 2) - (config.border_width * 2), 
              pad_height - (config.gaps * 2) - (config.border_width * 2)
              );
          XRaiseWindow(dpy, client.window);

          client.x = pad_x;
          client.y = pad_y;
          client.width = pad_width;
          client.height = pad_height;

          XSetWindowBorderWidth(dpy, client.window, config.border_width);


          if(i == this -> focused)
            XSetWindowBorder(dpy, client.window, config.active_px);
          else
            XSetWindowBorder(dpy, client.window, config.inactive_px);

          continue;
        }
        // If Master
        if (i == 0) 
        {
          XSetWindowBorderWidth(dpy, client.window, config.border_width);
          if(i == this -> focused)
            XSetWindowBorder(dpy, client.window, config.active_px);
          else
            XSetWindowBorder(dpy, client.window, config.inactive_px);
          XMoveResizeWindow(
              dpy, 
              client.window, 
              0 + config.gaps, 
              offset_y + config.gaps, 
              master_width - (config.gaps * 2) - (config.border_width * 2), 
              master_height - (config.gaps * 2) - (config.border_width * 2)
              );
          client.x = 0;
          client.y = 0;
          client.width = master_width;
          client.height = master_height;
        }
        else
        {
          int stack_count = this -> n_clients - this -> n_floating - 1;
          if(stack_count <= 0)
          {
            continue;
          }
          int stack_height = screen_height / stack_count;
          int stack_y = stack_height * (i - 1);

          XSetWindowBorderWidth(dpy, client.window, config.border_width);

          if(i == this -> focused)
            XSetWindowBorder(dpy, client.window, config.active_px);
          else
            XSetWindowBorder(dpy, client.window, config.inactive_px);

          XMoveResizeWindow(
              dpy, 
              client.window, 
              stack_x + config.gaps, 
              stack_y + config.gaps + offset_y, 
              stack_width - (config.gaps * 2) - (config.border_width * 2), 
              stack_height - (config.gaps * 2) - (config.border_width * 2)
              );
          client.x = stack_x;
          client.y = stack_y;
          client.width = stack_width;
          client.height = stack_height;
        }
      }

    }

    int is_visible(Display *dpy, Window w)
    {
      XWindowAttributes attr;
      if(!XGetWindowAttributes(dpy, w, &attr))
        return 0;

      return (attr.map_state == IsViewable);
    }

    void set_focus(Display *dpy, int idx)
    {

      if(idx >= this -> n_clients || idx == -1)
        return;

      Client &client = *this -> clients[idx];

      this -> last_focused = this -> focused;
      this -> focused = idx;

      XSetInputFocus(
          dpy,
          client.window,
          RevertToPointerRoot,
          CurrentTime
          );
    }

    void focus(Display *dpy, const Arg *arg) 
    {
      if(this -> clients.empty())
        return;

      Client &client = *this -> clients[0];

      if(!arg)
        return;
      if(this -> n_clients < 2)
        return;
      if(this -> focused == -1)
        return;

      switch(arg -> d)
      {
        case LEFT:
          {
            if(this -> focused == MASTER_IDX)
              set_focus(dpy, this -> last_focused);
            else
              set_focus(dpy, MASTER_IDX);
            break;
          }
        case RIGHT:
          {
            if(this -> last_focused && this -> focused == MASTER_IDX)
              set_focus(dpy, this -> last_focused);
            else if(!this -> last_focused && this -> focused == MASTER_IDX)
              set_focus(dpy, 1);
            else
              set_focus(dpy, MASTER_IDX);
            break;
          }
        case UP:
          {
            if(this -> focused == MASTER_IDX)
              set_focus(dpy, this -> n_clients - 1);
            else
              set_focus(dpy, this -> focused -1);
            break;
          }
        case DOWN:
          {
            // If last element
            if(this -> n_clients - 1 == this -> focused)
              set_focus(dpy, MASTER_IDX);
            else
              set_focus(dpy, this -> focused + 1);
            break;
          }
      }
    }

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

    void move_window(Display *dpy, const Arg *arg)
    {


      if(this -> clients[this -> focused] -> type != TILED)
        return;

      if(this -> n_clients - this -> n_floating < 2)
        return;

      if(!arg) return;

      switch(arg -> d)
      {

        case LEFT:
          {

            if(this -> focused == MASTER_IDX)
              break;

            std::swap(this -> clients[this -> focused], this -> clients[MASTER_IDX]);

            set_focus(dpy, MASTER_IDX);
            break;
          }
        case RIGHT:
          {

            if(this -> focused > MASTER_IDX)
              break;

            if(this -> last_focused)
            {
              std::swap(this -> clients[this -> focused], this -> clients[this -> last_focused]);
              set_focus(dpy, this -> last_focused);
            }
            else
            {
              std::swap(this -> clients[this -> focused], this -> clients[1]);
              set_focus(dpy, 1);
            }

            break;
          }
        case UP:
          {

            if(this -> focused == MASTER_IDX)
              break;

            std::swap(this -> clients[this -> focused], this -> clients[this -> focused - 1]);

            set_focus(dpy, this -> focused - 1);
            break;
          }
        case DOWN:
          {

            if(this -> focused == this -> n_clients - 1)
              break;

            std::swap(this -> clients[this -> focused], this -> clients[this -> focused + 1]);

            set_focus(dpy, this -> focused + 1);
            break;
          }
      }
    }


    void destroy_client(Display *dpy, int client_idx)
    {

      Client &client = *this -> clients[client_idx];

      this -> n_clients--;
      if(client.type == FLOATING || client.type == SCRATCHPAD)
        this -> n_floating--;

      if(this -> focused == client_idx)
      {
        if(client.type != TILED)
        {
          if(this -> last_focused)
            // This is done to make sure that last_focused is not a random client or freed client
            XSetInputFocus(dpy, this -> clients[this -> last_focused] -> window, RevertToPointerRoot, CurrentTime);
        }
        else if(this -> n_clients > 1)
          set_focus(dpy, this -> focused - 1);
        else if(this -> clients[MASTER_IDX])
          set_focus(dpy, MASTER_IDX);
        else
        {
          this -> focused = -1;
          XSetInputFocus(dpy, DefaultRootWindow(dpy), RevertToPointerRoot, CurrentTime);
        }
      }

      this -> clients.erase(this -> clients.begin() + client_idx);
    }
};

class WindowManager
{
  public:
    Display *dpy;
    int current_workspace;
    Workspace workspaces[MAX_WORKSPACES];
    WMConfig config;

    // To make sure that focus follows mouse does not do any weird things
    bool is_occupied;
    bool running;
    bool in_chord;
    std::vector<KeyBind> bind_keys;
    std::vector<KeyBind> chord_keys;

    WindowManager()
    {
      current_workspace = 0;
      is_occupied = false;
      running = true;
      in_chord = false;

      for(int i = 0; i < MAX_WORKSPACES; i++)
      {
        workspaces[i].focused = -1;
        workspaces[i].last_focused = -1;
        workspaces[i].id = i;
      }
    }

    void run(Display *dpy, XEvent event)
    {
      setup_numlockmask(dpy);
      set_supported_atoms(dpy);
      set_number_of_desktops(dpy);
      set_desktop_names(dpy);
      update_current_desktop(dpy);
      cache_borders(dpy);

      // Creates a new lua interpreter 
      lua_State *L = luaL_newstate(); 
      luaL_openlibs(L);
      reload_config(L, this->dpy);

      this -> init_lua(L);
      if(luaL_dofile(L, "swm.lua") != LUA_OK)
        printf("Error: %s\n", lua_tostring(L, -1));

      lua_getglobal(L, "config");

      if(!lua_istable(L, -1))
      {
        lua_pop(L, 1);
        printf("config table is missing");
        return;
      }

      lua_getfield(L, -1, "appearance");
      config.master_ratio = get_lua_number(L, "master_ratio", 0.5);
      config.gaps = get_lua_number(L, "gaps", 5);
      config.border_width = get_lua_number(L, "border_width", 2);


      config.scratchpad_width = get_lua_number(L, "scratchpad_width", 0.8);
      config.scratchpad_height = get_lua_number(L, "scratchpad_height", 0.7);

      lua_getfield(L, -1, "colors");

      config.color_active = get_table_string(L, "active", "#ffffff");
      config.color_inactive = get_table_string(L, "inactive", "#444444");
      config.color_chord = get_table_string(L, "chord", "#00ff00");

      lua_pop(L, 1);
      lua_pop(L, 1);

      setup_numlockmask(dpy);
      grab_keys(dpy);

      // To write a lua compatible c++ function you muse have the lua_State *L in the function argument and must return a int
      // for this if you want to use other values you have to have them be global or not requre them to be passed in via function signature (it has to be the same as defined above)
      // to get passed in arguments to functions called in lua use the lua_to<type>(L, <argument number (starts at 1)>) 
      // to push results back to lua use lua_push<type>(L, <value>) 
      // the return state at the end of the functions is the number of values pushed back to lua
      // to allow the lua function to access the wanted values use lua_register(L, "<name>", <name of c++ function>) but in this case we are making a function to allow use to use things in classes


      while(this -> running) 
      {
        XFlush(dpy);
        XNextEvent(dpy, &event);

        switch(event.type)
        {
          // Handle KeyPresses
          case KeyPress:
            {
              Workspace &ws = this -> workspaces[this -> current_workspace];

              KeySym key = XLookupKeysym(&event.xkey, 0);
              unsigned int mods = CLEANMASK(event.xkey.state);

              if(this -> in_chord)
              {
                for (auto &kb : this -> chord_keys)
                {
                  if(kb.key == key)
                  {
                    lua_rawgeti(L, LUA_REGISTRYINDEX, kb.lua_ref);
                    lua_pcall(L, 0, 0, 0);
                    break;
                  }
                }
                this -> in_chord = false;
                XUngrabKeyboard(dpy, CurrentTime);
              }
              else
              {
                for (auto &kb : this -> bind_keys) {
                  if (kb.key == key && CLEANMASK(kb.mod) == mods) {

                    // prefix → enter chord mode
                    if (kb.lua_ref == -1) {
                      this -> in_chord= true;
                      this -> in_chord = true;

                      XGrabKeyboard(dpy, DefaultRootWindow(dpy), True,
                          GrabModeAsync, GrabModeAsync, CurrentTime);

                      return;
                    }

                    lua_rawgeti(L, LUA_REGISTRYINDEX, kb.lua_ref);
                    lua_pcall(L, 0, 0, 0);
                    return;
                  }
                }
              }


              ws.tile(dpy, this -> config);
              update_borders(dpy);
              break;
            }


            // Called when a window is summoned
          case MapRequest:
            {

              Workspace &ws = this -> workspaces[this -> current_workspace];

              if(is_dock(dpy, event.xmaprequest.window))
              {
                XMapWindow(dpy, event.xmaprequest.window);
                break;
              }

              // Make space for Client

              ws.clients.push_back(std::make_unique<Client>(event.xmaprequest.window));
              ws.n_clients++;

              Client &client = *ws.clients.back();

              XSelectInput(dpy, client.window, EnterWindowMask);

              int client_idx = ws.clients.size() - 1;


              XMapWindow(dpy, client.window);
              ws.tile(dpy, this -> config);
              ws.set_focus(dpy, client_idx);
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

              Workspace &ws = this -> workspaces[this -> current_workspace];

              if(ws.clients.empty())
                break;

              Client *client = nullptr;
              bool managed = false;

              for(int i = 0; i < ws.n_clients; i++)
                if(ws.clients[i] -> window == configure_event -> window)
                {
                  client = ws.clients[i].get();
                  managed = true;
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
              ws.tile(dpy, this -> config);
              break;
            }

            // When a window closes
          case DestroyNotify:
            {
              // Definitions
              Workspace &ws = this -> workspaces[this -> current_workspace];
              int client_idx = -1;

              for(int i = 0; i < ws.n_clients; i++)
                if(ws.clients[i] -> window == event.xdestroywindow.window)
                  client_idx = i;

              if(client_idx == -1)
                break;

              ws.destroy_client(dpy, client_idx);

              ws.tile(dpy, this -> config);
              update_borders(dpy);
              break;
            }

          case EnterNotify:
            {

              XCrossingEvent *crossing_event = &event.xcrossing;
              Workspace &ws = this -> workspaces[this -> current_workspace];

              if(this -> is_occupied || ws.clients.empty()) 
                break;

              if(crossing_event -> mode != NotifyNormal || crossing_event -> detail == NotifyInferior)
                break;

              Client *client = ws.clients[0].get();

              // Loop through clients
              int client_idx = -1;
              for(int i = 0; i < ws.n_clients; i++)
                if(ws.clients[i] -> window == crossing_event -> window)
                {
                  client = ws.clients[i].get();
                  client_idx = i;
                }

              // prevent focusing already focused clients
              if(client_idx == ws.focused) 
                break;

              ws.set_focus(dpy, client_idx);
              update_borders(dpy);
              break;
            }

        }
      }

      lua_close(L);
    }

    void close_window(Display *dpy)
    {

      Workspace &ws = this -> workspaces[this -> current_workspace];

      if(ws.clients.empty())
        return;

      Client &client = *ws.clients[0];


      Atom WM_DELETE_WINDOW = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
      Atom WM_PROTOCOLS = XInternAtom(dpy, "WM_PROTOCOLS", False);
      Atom proto = XInternAtom(dpy, "WM_DELETE_WINDOW", False);

      XEvent event = {0};

      if(has_proto(dpy, client.window, proto))
      {
        event.xclient.type = ClientMessage;
        event.xclient.window = client.window;
        event.xclient.message_type = WM_PROTOCOLS;
        event.xclient.format = 32;
        event.xclient.data.l[0] = WM_DELETE_WINDOW;
        event.xclient.data.l[1] = CurrentTime;
        XSendEvent(dpy, client.window, False, NoEventMask, &event);
      } else {
        XKillClient(dpy, client.window);
      }

      XFlush(dpy);
    }

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

    void focus_workspace(Display *dpy, const Arg *arg)
    {
      this -> is_occupied = true;

      // NULL check and check if in range for workspaces
      if (!arg || arg -> i < 0 || arg -> i >= MAX_WORKSPACES || arg -> i == this -> current_workspace)
        return;

      Workspace &old_ws = this -> workspaces[this -> current_workspace]; 



      for(int i = 0; i < old_ws.n_clients; i++)
      {
        Client &client = *old_ws.clients[i];
        client.visible = false;
        XUnmapWindow(dpy, client.window);
      }

      this -> current_workspace = arg -> i;

      Workspace &ws = this -> workspaces[this -> current_workspace]; 


      for(int i = 0; i < ws.n_clients; i++)
      {
        Client &client = *ws.clients[i];
        if(client.type != SCRATCHPAD || client.visible)
          XMapWindow(dpy, client.window);
      }

      if(ws.focused != -1)
        ws.set_focus(dpy, ws.focused);
      else
        XSetInputFocus(dpy, DefaultRootWindow(dpy), RevertToPointerRoot, CurrentTime);

      update_current_desktop(dpy);

      ws.tile(dpy, this -> config);
      update_borders(dpy);

      this -> is_occupied = false;
    }


  private:

    void register_function(lua_State *L, const char* name, lua_CFunction fn) {
      lua_pushlightuserdata(L, this);  // store pointer to THIS object and allows use to use the functions inside out window manager
      lua_pushcclosure(L, fn, 1);      // attach it to the function
      lua_setglobal(L, name);          // make it callable from Lua
    }

    void grab_keys(Display *dpy) 
    {
      unsigned int lock_variants[] = {
        0,
        LockMask,
        numlockmask,
        LockMask | numlockmask
      };

      int n_locks = sizeof(lock_variants) / sizeof(unsigned int);

      for (auto &kb : bind_keys) {
        for (int j = 0; j < n_locks; j++) {
          XGrabKey(
              dpy,
              XKeysymToKeycode(dpy, kb.key),
              kb.mod | locks[j],
              DefaultRootWindow(dpy),
              True,
              GrabModeAsync,
              GrabModeAsync
              );
        }
      }

      // chord keys (no modifiers)
      for (auto &kb : chord_keys) {
        XGrabKey(
            dpy,
            XKeysymToKeycode(dpy, kb.key),
            AnyModifier,
            DefaultRootWindow(dpy),
            True,
            GrabModeAsync,
            GrabModeAsync
            );
      }
    }

    void reload_config(lua_State *L, Display *dpy)
    {
      this -> bind_keys.clear();
      this -> chord_keys.clear();

      lua_close(L);
      L = luaL_newstate();
      luaL_openlibs(L);

      init_lua(L);

      lua_getglobal(L, "config");

      if(!lua_istable(L, -1))
      {
        lua_pop(L, 1);
        printf("config table is missing");
        return;
      }

      lua_getfield(L, -1, "appearance");
      config.master_ratio = get_lua_number(L, "master_ratio", 0.5);
      config.gaps = get_lua_number(L, "gaps", 5);
      config.border_width = get_lua_number(L, "border_width", 2);


      config.scratchpad_width = get_lua_number(L, "scratchpad_width", 0.8);
      config.scratchpad_height = get_lua_number(L, "scratchpad_height", 0.7);

      lua_getfield(L, -1, "colors");

      config.color_active = get_table_string(L, "active", "#ffffff");
      config.color_inactive = get_table_string(L, "inactive", "#444444");
      config.color_chord = get_table_string(L, "chord", "#00ff00");

      this -> cache_borders(dpy);

      this -> setup_numlockmask(this -> dpy);
      grab_keys(dpy);
    }

    void init_lua(lua_State *L)
    {
      lua_newtable(L);

      lua_pushnumber(L, LEFT);
      lua_setfield(L, -2, "LEFT");

      lua_pushnumber(L, RIGHT);
      lua_setfield(L, -2, "RIGHT");

      lua_pushnumber(L, UP);
      lua_setfield(L, -2, "UP");

      lua_pushnumber(L, DOWN);
      lua_setfield(L, -2, "DOWN");

      lua_setglobal(L, "Direction");

      register_function(L, "focus", lua_focus);
      register_function(L, "reload", lua_reload);
      register_function(L, "bind", lua_bind);
      register_function(L, "exec", lua_spawn);
      register_function(L, "quit", lua_quit);
      register_function(L, "close", lua_close);
      register_function(L, "chord", lua_chord);
      register_function(L, "activate_chord", lua_activate_chord);
      register_function(L, "move_workspace", lua_focus_workspace);
      register_function(L, "move_window", lua_move_window);
      register_function(L, "move_window_workspace", lua_move_window_workspace);
    }

    static int lua_reload(lua_State *L)
    {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));

      wm -> reload_config(L, wm -> dpy);
      return 0;
    }

    float get_lua_number(lua_State *L, const char *name, float default_val)
    {
      lua_getglobal(L, name);

      if(!lua_isnumber(L, -1))
      {
        lua_pop(L, 1);
        return default_val;
      }

      float val = lua_tonumber(L, -1);
      lua_pop(L, 1);
      return val;
    }

    float get_table_number(lua_State *L, const char *key, float def)
    {
      lua_getfield(L, -1, key);

      if(!lua_isnumber(L, -1))
      {
        lua_pop(L, -1);
        return def;
      }

      float val = lua_tonumber(L, -1);
      lua_pop(L, 1);
      return val;
    }

    const char* get_table_string(lua_State *L, const char *key, const char *def)
    {
      lua_getfield(L, -1, key);

      if(!lua_isstring(L, -1))
      {
        lua_pop(L, 1);
        return def;
      }

      const char *val = lua_tostring(L, -1);
      lua_pop(L, 1);
      return val;
    }

    const char* get_lua_string(lua_State *L, const char *name, const char *default_val)
    {
      lua_getglobal(L, name);

      if(!lua_isstring(L, -1))
      {
        lua_pop(L, 1);
        return default_val;
      }

      const char *val = lua_tostring(L, -1);
      lua_pop(L, 1);
      return val;
    }

    unsigned int parse_mods(lua_State *L, int index)
    {
      unsigned int mod = 0;

      lua_pushnil(L);

      while(lua_next(L, index))
      {
        const char *m = lua_tostring(L, -1);

        if(strcmp(m, "Shift") == 0) mod |= ShiftMask;
        else if(strcmp(m, "Ctrl") == 0) mod |= ControlMask;
        else if(strcmp(m, "Alt") == 0) mod |= Mod1Mask;
        else if(strcmp(m, "Mod") == 0) mod |= Mod4Mask;

        lua_pop(L, 1);
      }

      return mod;
    }

    static int lua_chord(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));

      const char *prefix_str = luaL_checkstring(L, 1);
      luaL_checktype(L, 2, LUA_TTABLE);
      luaL_checktype(L, 3, LUA_TTABLE);

      KeySym prefix = XStringToKeysym(prefix_str);
      unsigned int mod = wm->parse_mods(L, 2);

      wm -> bind_keys.push_back({prefix, mod, -1});

      lua_pushnil(L);
      while (lua_next(L, 3)) {
        const char *key_str = lua_tostring(L, -2);

        KeySym key = XStringToKeysym(key_str);

        lua_pushvalue(L, -1);
        int ref = luaL_ref(L, LUA_REGISTRYINDEX);

        wm -> chord_keys.push_back({key, 0, ref});

        lua_pop(L, 1);
      }

      return 0;
    }

    static int lua_bind(lua_State *L)
    {
      WindowManager *wm =
        (WindowManager *)lua_touserdata(L, lua_upvalueindex(1));

      const char *key_str = luaL_checkstring(L, 1);
      luaL_checktype(L, 2, LUA_TTABLE);
      luaL_checktype(L, 3, LUA_TFUNCTION);

      KeySym key = XStringToKeysym(key_str);
      unsigned int mod = wm -> parse_mods(L, 2);

      lua_pushvalue(L, 3);
      int ref = luaL_ref(L, LUA_REGISTRYINDEX);

      wm -> bind_keys.push_back({key, mod, ref});
      return 0;
    }

    static int lua_quit(lua_State *L)
    {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));

      Arg arg = {.v = NULL};
      wm -> quit(wm -> dpy, &arg);
      return 0;
    }

    static int lua_activate_chord(lua_State *L)
    {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));

      Arg arg = {.v = NULL};
      wm -> activate_chord(wm -> dpy, &arg);
      return 0;
    }

    static int lua_close(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));
      Workspace &ws = wm -> workspaces[wm -> current_workspace];

      Arg arg = {.v = NULL};

      wm -> close_window(wm -> dpy);
      return 0;
    }

    static int lua_spawn(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));

      const char *arg = luaL_checkstring(L, 1);

      Arg cmd = {.c = arg};
      wm -> spawn(wm -> dpy, &cmd);
      return 0;
    }


    static int lua_focus(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));
      Workspace &ws = wm -> workspaces[wm -> current_workspace];

      int direction = luaL_checkinteger(L, 1);
      Arg arg = {.d = static_cast<Direction>(direction)};

      ws.focus(wm -> dpy, &arg);
      return 0;
    }

    static int lua_move_window(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));
      Workspace &ws = wm -> workspaces[wm -> current_workspace];

      int direction = luaL_checkinteger(L, 1);
      Arg arg = {.d = static_cast<Direction>(direction)};

      ws.move_window(wm -> dpy, &arg);
      return 0;
    }

    static int lua_move_window_workspace(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));
      Workspace &ws = wm -> workspaces[wm -> current_workspace];

      int workspace = luaL_checkinteger(L, 1);
      Arg arg = {.i = workspace};

      wm -> move_window_workspace(wm -> dpy, &arg);
      return 0;
    }

    static int lua_focus_workspace(lua_State *L) {
      WindowManager *wm =
        (WindowManager*)lua_touserdata(L, lua_upvalueindex(1));

      int workspace = luaL_checkinteger(L, 1);
      Arg arg = {.i = workspace};

      wm -> focus_workspace(wm -> dpy, &arg);
      return 0;
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

    unsigned long get_color(Display *dpy, const char *color_name) {
      Colormap cmap = DefaultColormap(dpy, DefaultScreen(dpy));
      XColor color;
      XAllocNamedColor(dpy, cmap, color_name, &color, &color);
      return color.pixel;
    }

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

    void update_current_desktop(Display *dpy)
    {
      Atom net_current = XInternAtom(dpy, "_NET_CURRENT_DESKTOP", False);

      unsigned long current = this -> current_workspace;

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


    void cache_borders(Display *dpy)
    {
      config.active_px = get_color(dpy, config.color_active);
      config.inactive_px = get_color(dpy, config.color_inactive);
      config.chord_px = get_color(dpy, config.color_chord);
    }

    void update_borders(Display *dpy) {
      Workspace &ws = this -> workspaces[this -> current_workspace];

      for(int i = 0; i < ws.n_clients; i++)
      {
        if(i == ws.focused)
        {
          if(this -> in_chord == false)
            XSetWindowBorder(dpy, ws.clients[i] -> window, config.active_px);
          else
            XSetWindowBorder(dpy, ws.clients[i] -> window, config.chord_px);
        }
        else
          XSetWindowBorder(dpy, ws.clients[i] -> window, config.inactive_px);
      }

    }

    void quit(Display *dpy, const Arg *arg)
    {
      this -> running = 0;
    }


    void activate_chord(Display *dpy, const Arg *arg) {
      this -> in_chord = true;

      if (XGrabKeyboard(dpy, DefaultRootWindow(dpy), True,
            GrabModeAsync, GrabModeAsync, CurrentTime) != GrabSuccess) {
        this -> in_chord = false; 
      }
    }

    void move_window_workspace(Display *dpy, const Arg *arg)
    {

      // Range and NULL Check
      if (!arg || arg -> i < 0 || arg -> i >= MAX_WORKSPACES || arg -> i == this -> current_workspace)
        return;

      Workspace &curr_ws = this -> workspaces[this -> current_workspace];
      Workspace &new_ws = this -> workspaces[arg -> i];

      if(curr_ws.clients.empty()) 
        return;

      auto moved = std::move(curr_ws.clients[curr_ws.focused]);
      curr_ws.clients.erase(curr_ws.clients.begin() + curr_ws.focused);

      new_ws.clients.push_back(std::move(moved));

      Client *client = moved.get();

      if(curr_ws.clients.empty())
        curr_ws.focused = -1;
      else if(curr_ws.focused >= curr_ws.n_clients)
        curr_ws.focused = curr_ws.n_clients - 1;
      // else just stays the same


      new_ws.focused = new_ws.n_clients - 1;

      XUnmapWindow(dpy, client -> window);

      this -> current_workspace = arg -> i;

      Arg new_arg = { .i = new_ws.id };
      this -> focus_workspace(dpy, &new_arg);

      XMapWindow(dpy, client -> window);

      new_ws.set_focus(dpy, new_ws.n_clients - 1);

      curr_ws.tile(dpy, this -> config);
      new_ws.tile(dpy, this -> config);
    }
};


int main()
{

  WindowManager WM;

  Display *dpy;
  XEvent event;
  if(!(dpy = XOpenDisplay(0x0))) return 1;

  WM.dpy = dpy;

  WM.run(dpy, event);
}




