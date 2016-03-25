#! /usr/bin/env python3
import os
import sys
import re

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + "/python")
from setup_functions import verbose_symlink

# Determine source and destination paths
source_path = os.path.dirname(os.path.abspath(__file__)) + "/"
dest_path = os.path.expanduser("~/Library/Application Support/Sublime Text 3/Packages/User/")
projects_dir = "Projects/"
settings_regex = re.compile(".*\.sublime-settings")
project_regex = re.compile(".*\.sublime-project")
keymap_regex = re.compile(".*\.sublime-keymap")

print("Source path:\t ",    source_path)
print("Destination path:", dest_path)

# Create the destination
os.makedirs(dest_path + projects_dir, exist_ok=True)

# Find any projects that aren't yet symlinked
for fn in os.listdir(dest_path + projects_dir):
    if project_regex.match(fn) and
    not(os.path.islink(dest_path + projects_dir + fn)):
        os.rename(  dest_path + projects_dir + fn,
                  source_path + projects_dir + fn)

# Symlink Sublime Settings and keymaps
for fn in os.listdir(source_path):
    if settings_regex.match(fn) or keymap_regex.match(fn):
        verbose_symlink(source_path + fn, dest_path + fn)

# Symlink Sublime Projects
for fn in os.listdir(source_path + projects_dir):
    if project_regex.match(fn):
        verbose_symlink(source_path + projects_dir + fn,
                          dest_path + projects_dir + fn)