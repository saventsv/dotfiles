#!/bin/bash
pkill wlogout || true

sleep 0.1

wlogout --protocol layer-shell &
