import cart/wasm4
import std/math
import std/random

# Call NimMain so that global Nim code in modules will be called, 
# preventing unexpected errors
proc NimMain {.importc.}

proc start {.exportWasm.} = 
  NimMain()

# var tick = 0
# var tickB = 0
PALETTE[] = [0x161f38'u32, 0x841e35, 0xb4742f, 0xf3eac0]

type
  Color = object
  Draw = object
  Tree = object
    baseX: int32
    baseY: int32
    height: int32
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

func drawLeaves(tree: Tree) {.tags: [Color, Draw].} =
  let
    width = tree.radius * 2 + tree.height div 3
    height = tree.height div 2
  setColors(0x22)
  oval(
    x = tree.baseX - width div 2,
    y = tree.baseY - tree.height * 3 div 4 - height div 2,
    width = uint32(width),
    height = uint32(height),
  )

func drawTree(tree: Tree) {.tags: [Color, Draw, Rand].} =
  var rng = initRand(tree.baseY * SCREEN_SIZE + tree.baseX)
  for y in 0..tree.height - 1:
    let r = int32(round(tree.radius * (tree.height - y) / tree.height))
    for x in -r..r:
      let
        rf = (x / r) ^ 3
        lim = rng.randf(1.0'f32)
        color = uint16(if rf < -lim: 4 elif rf > lim: 2 else: 3)
      drawPixel(color = color, x = tree.baseX + x, y = tree.baseY - y)
  drawLeaves(tree)

proc update {.exportWasm.} =
  # tick = (tick + 1) mod 3
  # tickB = (tickB + 1) mod 10
  # DRAW_COLORS[] = 4
  # text("Hello from Nim!", 10, 10)
  var rng = initRand(0x1337)
  DRAW_COLORS[] = uint16(rand(2..4))
  DRAW_COLORS[] = 3
  for i in 1..10:
    let
      edge = SCREEN_SIZE - 1
      height = rng.randi(20, 80)
      tree = Tree(
        baseX: rng.randi(0, edge),
        baseY: rng.randi(0, edge),
        height: height,
        radius: rng.randi(3, height div 10 + 3),
      )
    drawTree(tree)

  # var gamepad = GAMEPAD1[]
  # if bool(gamepad and BUTTON_1):
  #   DRAW_COLORS[] = if tick == 0: 2 elif tickB == 0: 4 else: 1
  
  # blit(addr smiley[0], 76, 76, 8, 8, BLIT_1BPP)
  # DRAW_COLORS[] = 3
  # text("Press X to blink", 16, 90)
