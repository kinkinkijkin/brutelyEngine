# This file is for making compiled-in configurations to
# your game. It comes with some values mandatory to set, and you can
# add anything else you want to this file without fear of breaking
# the engine. Basically a nim equiv to a config header.
# Subject to change in format between versions.


# ----
# MANDATORY
# ----
const
    PRGNAME* = "BRUTELY ENGINE" #game's name

    WNDNAME* = "BRUTELY" #window's name, required whether or not
                        #you actually render to a windowing system.

    WNDSIZE* = @[800,600] #window size, also required whether or not
                        #you render to a window.

    WNDRSIZ* = false #whether or not the window can be resized.

    VERMAJ* = 1
    VERMIN* = 0
    VERHOT* = 0 #semantic versioning numbers.

# ----
# YOUR LINES FROM HERE
# ----