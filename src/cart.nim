import cart/wasm4

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

var tick = 0
var tickB = 0
PALETTE[] = [uint32(0x161f38), 0x841e35, 0xb4742f, 0xf3eac0]

proc update {.exportWasm.} =
  tick = (tick + 1) mod 3
  tickB = (tickB + 1) mod 10
  DRAW_COLORS[] = 4
  text("Hello from Nim!", 10, 10)
  DRAW_COLORS[] = 2

  var gamepad = GAMEPAD1[]
  if bool(gamepad and BUTTON_1):
    DRAW_COLORS[] = if tick == 0: 2 elif tickB == 0: 4 else: 1
  
  blit(addr smiley[0], 76, 76, 8, 8, BLIT_1BPP)
  DRAW_COLORS[] = 3
  text("Press X to blink", 16, 90)
