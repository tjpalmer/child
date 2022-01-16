import cart/wasm4
import std/math
import std/random

# Call NimMain so that global Nim code in modules will be called, 
# preventing unexpected errors
proc NimMain {.importc.}

proc start {.exportWasm.} = 
  NimMain()

var smiley = [
  0b11000011'u8,
  0b10000001,
  0b00100100,
  0b00100100,
  0b00000000,
  0b00100100,
  0b10011001,
  0b11000011,
]

# var tick = 0
# var tickB = 0
PALETTE[] = [uint32(0x161f38), 0x841e35, 0xb4742f, 0xf3eac0]

type
  Tree = object
    baseX: int32
    baseY: int32
    height: int32
    radius: int32

proc drawTree(tree: Tree) =
  for y in 0..tree.height - 1:
    let r = int32(round(tree.radius * (tree.height - y) / tree.height))
    for x in -r..r:
      let
        rf = (x / r) ^ 3
        lim = rand(1.0)
      DRAW_COLORS[] = if rf < -lim: 4 elif rf > lim: 2 else: 3
      # FRAMEBUFFER[1] = 0x23
      hline(tree.baseX + x, tree.baseY - y, 1)

proc randi(low: int, high: int): int32 =
  return int32(rand(high - low) + low)

proc update {.exportWasm.} =
  # tick = (tick + 1) mod 3
  # tickB = (tickB + 1) mod 10
  # DRAW_COLORS[] = 4
  # text("Hello from Nim!", 10, 10)
  randomize(0x1337)
  DRAW_COLORS[] = uint16(rand(2..4))
  DRAW_COLORS[] = 3
  for i in 1..100:
    let
      edge = SCREEN_SIZE - 1
      height = randi(20, 80)
      tree = Tree(
        baseX: randi(0, edge),
        baseY: randi(0, edge),
        height: height,
        radius: randi(2, height div 8 + 2),
      )
    drawTree(tree)

  # var gamepad = GAMEPAD1[]
  # if bool(gamepad and BUTTON_1):
  #   DRAW_COLORS[] = if tick == 0: 2 elif tickB == 0: 4 else: 1
  
  # blit(addr smiley[0], 76, 76, 8, 8, BLIT_1BPP)
  # DRAW_COLORS[] = 3
  # text("Press X to blink", 16, 90)
