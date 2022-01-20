import cart/wasm4
import std/algorithm
import std/bitops
import std/math
import std/random
import std/sugar

# Call NimMain so that global Nim code in modules will be called, 
# preventing unexpected errors
proc NimMain {.importc.}

proc start {.exportWasm.} = 
  NimMain()

# var tick = 0
# var tickB = 0
PALETTE[] = [0x161f38'u32, 0x841e35, 0xb4742f, 0xf3eac0]

var posX = 0'i32

type
  Color = object
  Draw = object
  Scroll = object
  Tree = object
    baseX: int32
    baseY: int32
    sizeY: int32
    radius: int32

func getPosX(): int32 {.tags: [Scroll].} =
  {.cast(noSideEffect).}:
    posX

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

func drawLeaves(color: uint16, offsetX: int32, rng: var Rand, scale: float, tree: Tree) {.tags: [Color, Draw, Rand].} =
  let
    midX = tree.baseX + offsetX
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
  for i in 1..int32(float(sizeX * sizeY) * scale):
    let
      xf = rng.randf(2.0) - 1
      yf = rng.randf(2.0) - 1
    if xf * xf + yf * yf <= 1:
      let
        x = int32(xf * float(radiusX)) + midX
        y = int32(yf * float(radiusY)) + midY
      drawPixel(color, x, y)

func drawTree(scale: float, tree: Tree) {.tags: [Color, Draw, Rand, Scroll].} =
  var rng = initRand(tree.baseY * SCREEN_SIZE + tree.baseX)
  let offsetX = tree.baseX + int32(float(getPosX()) * scale)
  for y in 0..tree.sizeY - 1:
    let r = int32(round(tree.radius * (tree.sizeY - y * 2 div 3) / tree.sizeY))
    for x in -r..r:
      let
        rf = (x / r) ^ 3
        lim = rng.randf(1.0'f32)
        color = uint16(if rf < -lim: 4 elif rf > lim: 2 else: 3)
      drawPixel(color = color, x = tree.baseX + offsetX + x, y = tree.baseY - y)
  drawLeaves(color = 2, offsetX = offsetX, rng = rng, scale = 2, tree = tree)
  drawLeaves(color = 3, offsetX = offsetX, rng = rng, scale = 0.1, tree = tree)

# system.onUnhandledException = proc (errorMsg: string) {.nimcall, gcsafe.} =
#   discard

proc drawTrees(count: int, scale: float, seed: int32) {.tags: [Color, Draw, Rand, Scroll].} =
  var rng = initRand(seed)
  for i in 1..count:
    let
      edge = SCREEN_SIZE - 1
      sizeY = rng.randi(int32(80 * scale), int32(120 * scale))
      tree = Tree(
        baseX: rng.randi(0, edge),
        baseY: 120, # rng.randi(0, edge),
        sizeY: sizeY,
        radius: rng.randi(3, sizeY div 10 + 3),
      )
  # trees.sort(func(a, b: Tree): int = a.baseY - b.baseY)
  # for tree in trees:
    drawTree(scale = scale, tree = tree)

proc ditherFade() {.tags: [Draw, Scroll].} =
  let
    frameWidth = SCREEN_SIZE div 4
    # posX = getPosX()
    posX = int32(float(getPosX()) * 0.8)
    # posX = 0
  var offset = 0
  for y in 0..SCREEN_SIZE:
    let mask: uint8 = if (y + posX) mod 2 == 0: 0xCC else: 0x33
    offset += frameWidth
    for x in 0..frameWidth:
      clearMask(FRAMEBUFFER[][offset + x], mask)

proc update {.exportWasm, tags: [Color, Draw, Rand].} =
  # tick = (tick + 1) mod 2
  # tickB = (tickB + 1) mod 10
  # DRAW_COLORS[] = 4
  # text("Hello from Nim!", 10, 10)
  if bool(GAMEPAD1[] and BUTTON_LEFT):
    posX -= 1
  if bool(GAMEPAD1[] and BUTTON_RIGHT):
    posX += 1
  drawTrees(count = 10, scale = 0.8, seed = 0x1337)
  ditherFade()
  drawTrees(count = 5, scale = 1.0, seed = 0x1340)
  # # var trees = collect:

  # var gamepad = GAMEPAD1[]
  # if bool(gamepad and BUTTON_1):
  #   DRAW_COLORS[] = if tick == 0: 2 elif tickB == 0: 4 else: 1
  
  # blit(addr smiley[0], 76, 76, 8, 8, BLIT_1BPP)
  # DRAW_COLORS[] = 3
  # text("Press X to blink", 16, 90)
