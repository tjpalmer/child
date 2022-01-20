import cart/wasm4
import std/algorithm
import std/math
import std/random
import std/sugar

# Call NimMain so that global Nim code in modules will be called, 
# preventing unexpected errors
proc NimMain {.importc.}

proc start {.exportWasm.} = 
  NimMain()

var tick = 0
# var tickB = 0
PALETTE[] = [0x161f38'u32, 0x841e35, 0xb4742f, 0xf3eac0]

type
  Color = object
  Draw = object
  Tree = object
    baseX: int32
    baseY: int32
    sizeY: int32
    radius: int32

func randf(rng: var Rand, high: float): float {.tags: [Rand].} =
  rng.rand(high)

func randi(rng: var Rand, low: int, high: int): int32 {.tags: [Rand].} =
  int32(rng.rand(high - low) + low)

func setColors(colors: uint16) {.tags: [Color].} =
  DRAW_COLORS[] = colors

func drawPixel(color: uint16, x: int32, y: int32) {.tags: [Color, Draw].} =
  setColors(color)
  # FRAMEBUFFER[1] = 0x23
  hline(x, y, 1)

func drawLeaves(color: uint16, sup: int32, sub: int32, rng: var Rand, tree: Tree) {.tags: [Color, Draw, Rand].} =
  let
    midX = tree.baseX
    midY = tree.baseY - tree.sizeY * 3 div 4
    sizeX = tree.radius * 2 + tree.sizeY * 4 div 9
    sizeY = tree.sizeY * 5 div 9
    radiusX = sizeX div 2
    radiusY = sizeY div 2
  # Ovals have bad edge effects.
  # setColors(0x22)
  # oval(
  #   x = midX - sizeX div 2,
  #   y = midY - sizeY div 2,
  #   width = uint32(sizeX),
  #   height = uint32(sizeY),
  # )
  for i in 1..sizeX * sizeY * sup div sub:
    let
      xf = rng.randf(2.0) - 1
      yf = rng.randf(2.0) - 1
    if xf * xf + yf * yf <= 1:
      let
        x = int32(xf * float(radiusX)) + midX
        y = int32(yf * float(radiusY)) + midY
      drawPixel(color, x, y)

func drawTree(tree: Tree) {.tags: [Color, Draw, Rand].} =
  var rng = initRand(tree.baseY * SCREEN_SIZE + tree.baseX)
  for y in 0..tree.sizeY - 1:
    let r = int32(round(tree.radius * (tree.sizeY - y * 2 div 3) / tree.sizeY))
    for x in -r..r:
      let
        rf = (x / r) ^ 3
        lim = rng.randf(1.0'f32)
        color = uint16(if rf < -lim: 4 elif rf > lim: 2 else: 3)
      drawPixel(color = color, x = tree.baseX + x, y = tree.baseY - y)
  drawLeaves(color = 2, sup = 3, sub = 1, rng = rng, tree = tree)
  drawLeaves(color = 3, sup = 1, sub = 10, rng = rng, tree = tree)

# system.onUnhandledException = proc (errorMsg: string) {.nimcall, gcsafe.} =
#   discard

proc drawTrees(count: int, scaleY: float, seed: int32) {.tags: [Color, Draw, Rand].} =
  var rng = initRand(seed)
  for i in 1..count:
    let
      edge = SCREEN_SIZE - 1
      sizeY = rng.randi(int32(80 * scaleY), int32(120 * scaleY))
      tree = Tree(
        baseX: rng.randi(0, edge),
        baseY: 120, # rng.randi(0, edge),
        sizeY: sizeY,
        radius: rng.randi(3, sizeY div 10 + 3),
      )
  # trees.sort(func(a, b: Tree): int = a.baseY - b.baseY)
  # for tree in trees:
    drawTree(tree)

proc update {.exportWasm.} =
  tick = (tick + 1) mod 2
  # tickB = (tickB + 1) mod 10
  # DRAW_COLORS[] = 4
  # text("Hello from Nim!", 10, 10)
  drawTrees(count = 10, scaleY = 0.8, seed = 0x1337)
  # if tick == 0:
  #   setColors(0x11)
  #   rect(0, 0, SCREEN_SIZE, SCREEN_SIZE)
  drawTrees(count = 5, scaleY = 1.0, seed = 0x1340)
  # var rng = initRand(0x1340)
  # # DRAW_COLORS[] = uint16(rand(2..4))
  # # DRAW_COLORS[] = 3
  # # var trees = collect:
  # for i in 1..5:
  #   let
  #     edge = SCREEN_SIZE - 1
  #     sizeY = rng.randi(80, 120)
  #     tree = Tree(
  #       baseX: rng.randi(0, edge),
  #       baseY: 120, # rng.randi(0, edge),
  #       sizeY: sizeY,
  #       radius: rng.randi(3, sizeY div 10 + 3),
  #     )
  # # trees.sort(func(a, b: Tree): int = a.baseY - b.baseY)
  # # for tree in trees:
  #   drawTree(tree)

  # var gamepad = GAMEPAD1[]
  # if bool(gamepad and BUTTON_1):
  #   DRAW_COLORS[] = if tick == 0: 2 elif tickB == 0: 4 else: 1
  
  # blit(addr smiley[0], 76, 76, 8, 8, BLIT_1BPP)
  # DRAW_COLORS[] = 3
  # text("Press X to blink", 16, 90)
