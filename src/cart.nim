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

proc update {.exportWasm.} =
  PALETTE[0] = 0x142228
  PALETTE[1] = 0x604000
  PALETTE[2] = 0xb2893c
  PALETTE[3] = 0xf4ebd0
  DRAW_COLORS[] = 2
  text("Hello from Nim!", 10, 10)

  var gamepad = GAMEPAD1[]
  if bool(gamepad and BUTTON_1):
    DRAW_COLORS[] = 4
  
  blit(addr smiley[0], 76, 76, 8, 8, BLIT_1BPP)
  DRAW_COLORS[] = 3
  text("Press X to blink", 16, 90)
