import game

import ../../scripts/main

type
  ScriptOpaque* = pointer

proc runEntryPointScript*() =
  main()