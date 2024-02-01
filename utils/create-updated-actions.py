#!/usr/bin/env python3

from sys import stdin
import re

if __name__ == "__main__":
    actions = []
    for action in stdin:
        actions.append(action[:-1])

    pattern = re.compile("static int pif_action_exec_([^_]*)__([^(]*)")

    with open("pifs/pif_actions.c") as pif_actions:
        with open("pifs/updated_pif_actions.c", "w") as updated_actions:
            for line in pif_actions:
                updated_actions.write(line)
                match = re.search(pattern, line)
                if match and match.group(2) in actions:
                    previous = ""
                    line2 = next(pif_actions)
                    while not re.search("return _pif_return;*", line2):
                        updated_actions.write(line2)
                        previous = line2
                        line2 = next(pif_actions)
                    # NOTE: We make this check to ensure the line is not
                    # duplicated in case the script is ran more than once
                    # or in the case someone uses a fixed compiler version
                    if not re.search("pif_flowcache_bypass = 1;", previous):
                        updated_actions.write(
                            "\t\tpif_flowcache_bypass = 1;\n"
                        )
                    updated_actions.write(line2)
