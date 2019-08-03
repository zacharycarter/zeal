import game, render, fpmath
from compiler/astalgo import debug
from compiler/idents import IdentCache
from compiler/vmdef import registerCallback, VmArgs, PCtx
from compiler/modulegraphs import ModuleGraph

from compiler/vm import
  # Getting values from VmArgs
  getInt, getFloat, getString, getBool, getNode,
  # Setting result (return value)
  setResult

from compiler/ast import
  # Types
  PSym, PNode, TNodeKind,
  # Getting values from PNodes
  getInt, getFloat,
  # Creating new PNodes
  newNode, newFloatNode, addSon, newTree

from os import splitFile
from threadpool import FlowVar

# Assume location of shared state type in ../state
# import ../state


type
  Script* = ref object
    filename*: string
    moduleName*: string
    mainModule*: PSym
    graph*: ModuleGraph
    context*: PCtx
    watcher*: FlowVar[int]

proc getVec3(a: VmArgs): Vec3 =
  let keyset = getNode(a, 0)
  doAssert keyset.kind == nkBracket
  doAssert len(keyset.sons) == 3
  for i, son in keyset.sons:
    doAssert son.kind == nkFloatLit
    result[i] = son.floatVal

proc exposeScriptApi*(script: Script) =
  template expose (procName, procBody: untyped) {.dirty.} =
    script.context.registerCallback script.moduleName & "." & astToStr(procName),
        proc (a: VmArgs) =
            procBody
    
  expose newGame:
    game.newGame(getString(a, 0), getString(a, 1))
  
  expose setAmbientLightColor:
    var val = getVec3(a)
    render.setAmbientLightColor(val)

  expose setEmitLightColor:
    var val = getVec3(a)
    render.setEmitLightColor(val)

  expose setEmitLightPos:
    var val = getVec3(a)
    render.setEmitLightPos(val)
    # expose add:
    #     # We need to use procs like getInt to retrieve the argument values from VmArgs
    #     # Instead of using the return statement we need to use setResult
    #     setResult(a,
    #         getInt(a, 0) +
    #         getInt(a, 1))

    # expose modifyState:
    #     modifyMe = getString(a, 0)
    #     echo "`", script.moduleName, "` has changed state.modifyMe to `", modifyMe, "`"
