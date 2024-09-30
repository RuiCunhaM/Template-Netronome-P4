#!/bin/bash

grep "#pragma netro no_lookup_caching" src/*.p4 | sed 's/^[ \t]*//' | awk '{print $4}' | python3 utils/create-updated-actions.py
mv pifs/updated_pif_actions.c pifs/pif_actions.c
