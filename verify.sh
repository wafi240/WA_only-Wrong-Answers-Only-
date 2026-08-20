#!/bin/bash
# Script to automate verification
{
  echo "2" # Register
  echo "testuser"
  echo "test123"
  echo "1" # Login
  echo "testuser"
  echo "test123"
  echo "1" # Browse
  echo "0" # Exit browse (Wait, how do I exit submenus?)
  # The menus use loops, I need to know how to exit each menu.
  # Based on the code, "pressEnterToContinue()" uses `cin.ignore` and `cin.get()`.
  # This makes automation very hard with piped input.
} | ./waonly
