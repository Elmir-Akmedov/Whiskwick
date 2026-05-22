from PIL import Image, ImageDraw
import os

OUT = "/mnt/user-data/outputs/whiskwick_sprites"
os.makedirs(OUT, exist_ok=True)

def img(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))

def px(d, x, y, w, h, col):
    if len(col) == 3:
        col = col + (255,)
    d.rectangle([x, y, x+w-1, y+h-1], fill=col)

def save(im, name):
    im.save(os.path.join(OUT, name))
    print(f"  ✓ {name}")

# ── PALETTE ──────────────────────────────────────────────────────────────────
# Warm wood / sales
WF1  = (212,151, 90)  # sales floor warm
WF2  = (196,136, 72)  # sales floor alt
WFD  = (168,104, 48)  # floor dark seam
WFL  = (228,172,112)  # floor light
WW1  = (210,125, 74)  # sales wall
WW2  = (186,100, 48)  # sales wall dark
WWC  = ( 58, 32, 16)  # wall cap
WB1  = (160,100, 56)  # wainscot wood
WB2  = (136, 80, 36)  # wainscot dark

# Kitchen
KF1  = (200,184,152)  # kitchen floor
KF2  = (184,168,136)  # kitchen floor alt
KFD  = (144,128,104)  # kitchen floor seam
KW1  = (240,236,220)  # kitchen wall tile
KW2  = (220,216,200)  # kitchen wall grout

# Warehouse
RF1  = (136,148,160)  # warehouse floor
RF2  = (120,132,148)  # warehouse floor alt
RFD  = ( 96,108,124)  # warehouse floor seam
RW1  = (120,132,148)  # warehouse wall brick
RW2  = ( 96,108,124)  # warehouse wall mortar

# Wood
WD1  = (139, 69, 19)  # wood medium
WD2  = (107, 48, 16)  # wood dark
WD3  = (160, 88, 40)  # wood light
WDL  = (192,120, 64)  # wood highlight
WDK  = ( 74, 36,  8)  # wood very dark

# Counters / surfaces
CT   = (232,220,196)  # counter top
CTL  = (248,240,216)  # counter top light
CTD  = (184,164,136)  # counter side
GLS  = (180,220,240,160)  # glass blue tint
GLSL = (220,240,255,120)  # glass highlight

# Products
CK1  = (232,136,152)  # cupcake pink
CK2  = (248,176,192)  # cupcake light
BRD  = (212,144, 72)  # bread brown
CAK  = (200,120,184)  # cake purple
PST  = (232,200,120)  # pastry yellow
JAR1 = (120,168,200)  # jar blue
JAR2 = (168,200,120)  # jar green
JAR3 = (232,120,120)  # jar red

# Plant
PL1  = ( 74,138, 74)  # leaf dark
PL2  = ( 42,106, 42)  # leaf very dark
PL3  = (106,170,106)  # leaf light
POT  = (200,122, 90)  # pot terracotta
POTD = (160, 90, 60)  # pot dark

# Machine
RK1  = (106,122,138)  # rack metal
RK2  = (138,154,176)  # rack light
RKD  = ( 74, 90,106)  # rack dark
CR1  = (200,144, 80)  # crate wood
CR2  = (224,176,112)  # crate light
CRD  = (160,112, 48)  # crate dark

# Oven
OV1  = ( 74, 74, 84)  # oven body
OV2  = ( 42, 42, 52)  # oven door
OVH  = (255,196,  0)  # oven highlight strip
OVG1 = (255,160,  0)  # glow orange
OVG2 = (255,220, 80)  # glow yellow

# Misc
WHT  = (248,240,220)  # near white
CRM  = (240,228,200)  # cream
BLK  = ( 26, 18,  8)  # near black
REG  = ( 58, 58, 74)  # register dark
RSC  = (112,200,112)  # register screen
GLD  = (212,168, 64)  # gold

# ─────────────────────────────────────────────────────────────────────────────
# FLOOR TILES (32×32)
# ─────────────────────────────────────────────────────────────────────────────

def make_floor_sales():
    """Warm wood plank – horizontal lines."""
    im = img(32, 32); d = ImageDraw.Draw(im)
    for y in range(32):
        # alternate planks every 8 px
        base = WF1 if (y // 8) % 2 == 0 else WF2
        for x in range(32):
            d.point((x, y), base)
        # plank seam
        if y % 8 == 0:
            d.line([(0, y), (31, y)], fill=WFD)
        if y % 8 == 7:
            d.line([(0, y), (31, y)], fill=WFL)
    # vertical nail gaps every 16
    for x in [0, 16]:
        for y in range(3, 30, 8):
            d.rectangle([x, y, x+1, y+3], fill=WFD)
    save(im, "floor_sales.png")

def make_floor_kitchen():
    """Light square tiles with grout."""
    im = img(32, 32); d = ImageDraw.Draw(im)
    for y in range(32):
        for x in range(32):
            in_grout = (x % 16 == 0) or (y % 16 == 0)
            d.point((x, y), KFD if in_grout else (KF1 if (x//16+y//16)%2==0 else KF2))
    save(im, "floor_kitchen.png")

def make_floor_warehouse():
    """Concrete slab with cracks."""
    im = img(32, 32); d = ImageDraw.Draw(im)
    for y in range(32):
        for x in range(32):
            d.point((x, y), RF1 if (x+y)%3!=0 else RF2)
    d.line([(0,0),(31,31)], fill=RFD)
    d.line([(16,0),(31,15)], fill=RFD)
    for x in [0, 31]:
        for y in range(32):
            d.point((x,y), RFD)
    for y in [0, 31]:
        for x in range(32):
            d.point((x,y), RFD)
    save(im, "floor_warehouse.png")

make_floor_sales()
make_floor_kitchen()
make_floor_warehouse()

# ─────────────────────────────────────────────────────────────────────────────
# WALLS (32×32) — top-down, seen from above so just a colored strip
# ─────────────────────────────────────────────────────────────────────────────

def make_wall_sales():
    im = img(32, 32); d = ImageDraw.Draw(im)
    # Upper painted plaster
    for y in range(18):
        c = WW1 if y%4<2 else WW2
        d.line([(0,y),(31,y)], fill=c)
    # Wainscot wood paneling
    for y in range(18, 30):
        c = WB1 if y%4<2 else WB2
        d.line([(0,y),(31,y)], fill=c)
        if (y-18)%4==0: d.line([(0,y),(31,y)], fill=WDK)
    # Skirting / cap at bottom
    for y in range(30, 32):
        d.line([(0,y),(31,y)], fill=WWC)
    save(im, "wall_sales.png")

def make_wall_kitchen():
    im = img(32, 32); d = ImageDraw.Draw(im)
    for y in range(32):
        for x in range(32):
            grout = (x%8==0) or (y%8==0)
            d.point((x,y), KFD if grout else KW1)
    # Backsplash accent band
    for y in range(16,20):
        d.line([(0,y),(31,y)], fill=(180,200,210,255))
    save(im, "wall_kitchen.png")

def make_wall_warehouse():
    im = img(32, 32); d = ImageDraw.Draw(im)
    for y in range(32):
        row_off = (y//6)%2
        for x in range(32):
            bx = (x + row_off*8) // 8
            d.point((x,y), RW1 if bx%2==0 else RW2)
        if y%6==0: d.line([(0,y),(31,y)], fill=RFD)
    save(im, "wall_warehouse.png")

make_wall_sales()
make_wall_kitchen()
make_wall_warehouse()

# ─────────────────────────────────────────────────────────────────────────────
# DISPLAY SHELF – SALES (64×64)  ★ liked
# ─────────────────────────────────────────────────────────────────────────────
def make_shelf_display():
    im = img(64, 64); d = ImageDraw.Draw(im)
    # Cabinet base
    px(d,  0, 36, 64, 28, WD2)
    px(d,  2, 34, 60, 28, WD1)
    px(d,  0, 34,  2, 28, WDK)
    px(d, 62, 34,  2, 28, WDK)
    px(d,  0, 60, 64,  4, WDK)

    # Legs
    for lx in [4, 54]:
        px(d, lx, 58, 6, 6, WD2)

    # Glass case body
    px(d,  2,  8, 60, 30, (160,210,230,180))
    px(d,  2,  8, 60,  2, (220,240,255,200))
    px(d,  2, 36, 60,  2, (120,160,190,200))

    # Frame
    px(d,  0,  6,  2, 34, WD2)
    px(d, 62,  6,  2, 34, WD2)
    px(d,  0,  6, 64,  2, WD2)
    px(d, 20,  6,  2, 30, WD2)
    px(d, 42,  6,  2, 30, WD2)

    # Products section 1: cupcakes
    px(d,  4, 22, 14,  8, CK1)
    px(d,  5, 18, 12,  6, CK2)
    px(d,  9, 16,  4,  4, (200,240,200))  # frosting
    px(d, 10, 14,  2,  3, WD1)  # stick

    # Products section 2: bread loaf
    px(d, 24, 20, 16, 10, BRD)
    px(d, 25, 18, 14,  4, (232,168, 96))
    px(d, 28, 17,  8,  2, (248,196,128))
    for sx in [26,30,34]:
        px(d, sx, 19,  2,  5, (192,120, 56))

    # Products section 3: cake slice
    px(d, 46, 18, 14, 14, CAK)
    px(d, 47, 16, 12,  4, (220,152,208))
    px(d, 50, 14,  6,  4, WHT)
    px(d, 52, 12,  2,  3, (240, 80,120))  # cherry

    # Price tags
    for tx2,col in [(4,CK1),(24,BRD),(46,CAK)]:
        px(d, tx2+2, 36, 12,  8, WHT)
        px(d, tx2+3, 37,  2,  2, (200, 60, 60))  # price dot

    # Label strip
    px(d,  2, 44, 60,  6, CRM)
    px(d,  4, 45, 56,  4, (220,208,180))

    save(im, "shelf_display.png")

make_shelf_display()

# ─────────────────────────────────────────────────────────────────────────────
# CASHIER STAND (64×48)
# ─────────────────────────────────────────────────────────────────────────────
def make_cashier_stand():
    im = img(64, 48); d = ImageDraw.Draw(im)
    # Base cabinet
    px(d,  0, 26, 64, 22, WD2)
    px(d,  2, 24, 60, 22, WD1)
    px(d,  0, 42, 64,  4, WDK)

    # Counter top surface
    px(d,  2, 18, 60, 10, CT)
    px(d,  2, 18, 60,  2, CTL)
    px(d,  2, 26, 60,  2, CTD)
    px(d,  0, 18,  2, 10, CTD)
    px(d, 62, 18,  2, 10, CTD)

    # Rubber mat on counter
    px(d,  4, 20, 24,  6, (138,118, 96))
    px(d,  5, 21, 22,  4, (120,100, 78))

    # Register body
    px(d, 36,  8, 20, 14, REG)
    px(d, 38, 10, 16,  8, (78,78,96))
    # Screen
    px(d, 39, 11, 14,  6, RSC)
    px(d, 40, 12, 12,  4, (140,220,140))
    px(d, 41, 12,  8,  1, WHT)  # text line
    px(d, 41, 14,  8,  1, WHT)
    # Register base
    px(d, 34, 20, 24,  4, (78,78,96))

    # Bell
    px(d,  8,  8, 10, 10, GLD)
    px(d, 10,  6,  6,  4, (184,144, 48))
    px(d, 11,  8,  4,  6, (228,188, 80))
    px(d, 12, 18,  2,  2, GLD)  # clapper

    # Receipt strip
    px(d, 48, 18,  4, 12, WHT)
    px(d, 49, 20,  2,  8, (220,216,200))

    # Drawer handle
    px(d, 20, 32, 24,  4, CTD)
    px(d, 28, 31,  8,  6, (160,140,112))
    px(d, 30, 32,  4,  4, CTL)

    save(im, "cashier_stand.png")

make_cashier_stand()

# ─────────────────────────────────────────────────────────────────────────────
# TABLE (2-SEAT) (64×64)  ★ liked
# ─────────────────────────────────────────────────────────────────────────────
def make_table_2seat():
    im = img(64, 64); d = ImageDraw.Draw(im)
    # Chairs (drawn behind table)
    # Left chair
    px(d,  0, 20, 12, 22, (122, 76, 32))
    px(d,  1, 21, 10, 14, (176,128, 72))
    px(d,  1, 20, 10,  3, (136, 96, 44))
    # Right chair
    px(d, 52, 20, 12, 22, (122, 76, 32))
    px(d, 53, 21, 10, 14, (176,128, 72))
    px(d, 53, 20, 10,  3, (136, 96, 44))
    # Top chair
    px(d, 16,  0, 32, 14, (122, 76, 32))
    px(d, 17,  1, 30, 12, (176,128, 72))
    px(d, 17,  1, 30,  3, (136, 96, 44))

    # Table surface
    px(d,  8, 14, 48, 36, (139, 90, 43))
    px(d,  8, 14, 48,  2, (168,116, 64))
    px(d,  8, 14,  2, 36, (168,116, 64))
    px(d, 54, 14,  2, 36, (100, 60, 20))
    px(d,  8, 48, 48,  2, (100, 60, 20))
    # Wood grain lines
    for gy in range(17, 47, 5):
        for gx in range(9, 55):
            if (gx+gy)%7==0:
                d.point((gx,gy),(160,100,48))

    # Cup on table
    px(d, 18, 22, 10, 12, WHT)
    px(d, 19, 20,  8,  4, CRM)
    px(d, 20, 19,  6,  2, (180,120, 64))  # rim
    px(d, 20, 32,  6,  2, (200,160,100))  # saucer
    # Coffee in cup
    px(d, 20, 22,  6,  8, (100, 60, 30))
    px(d, 21, 23,  4,  2, (140, 90, 50))

    # Small vase with flower
    px(d, 38, 20,  8, 14, JAR1)
    px(d, 39, 18,  6,  4, (160,200,220))
    px(d, 40, 28,  4,  6, PL2)  # stem
    px(d, 37, 24,  4,  4, (240,100,120))  # petals
    px(d, 41, 24,  4,  4, (240,100,120))
    px(d, 39, 22,  4,  4, (240,100,120))
    px(d, 39, 26,  4,  4, (240,100,120))
    px(d, 40, 24,  2,  2, GLD)  # center

    # Legs
    for lx in [10, 50]:
        px(d, lx, 48,  4, 16, WD2)
        px(d, lx,  60,  6,  4, WD2)

    save(im, "table_2seat.png")

make_table_2seat()

# ─────────────────────────────────────────────────────────────────────────────
# OVEN (64×64)  ★ liked — improved version
# ─────────────────────────────────────────────────────────────────────────────
def make_oven():
    im = img(64, 64); d = ImageDraw.Draw(im)
    # Outer body
    px(d,  2,  6, 60, 58, (58,58,70))
    px(d,  0,  4,  2, 58, (42,42,54))
    px(d, 62,  4,  2, 58, (78,78,92))
    px(d,  0, 62, 64,  2, (32,32,42))

    # Control panel top
    px(d,  2,  4, 60,  6, (70,70,84))
    px(d,  2,  4, 60,  2, (90,90,108))
    # Knobs row
    for kx in [8, 20, 32, 44, 54]:
        px(d, kx,  4,  8,  8, (46,46,60))
        px(d, kx+1,5,  6,  6, (78,78,96))
        px(d, kx+3,6,  2,  4, (108,108,130))

    # Oven door frame
    px(d,  4, 12, 56,  2, (90,90,108))
    px(d,  4, 12, 56, 44, (38,38,48))
    px(d,  4, 12,  2, 44, (52,52,64))
    px(d, 58, 12,  2, 44, (30,30,40))
    px(d,  4, 54, 56,  2, (52,52,64))

    # Inner glow (oven cavity)
    px(d,  6, 14, 52, 40, (28,18, 8))
    # Orange/yellow radial gradient sim with rects
    px(d, 20, 28, 24, 16, (80,30, 0))
    px(d, 22, 26, 20, 18, (120,50, 0))
    px(d, 24, 24, 16, 20, (180, 80, 0))
    px(d, 26, 22, 12, 22, (220,120, 0))
    px(d, 28, 20,  8, 24, (255,160, 0))
    px(d, 29, 18,  6, 26, (255,200, 40))
    px(d, 30, 16,  4, 28, (255,220, 80))
    px(d, 31, 14,  2, 30, (255,240,120))

    # Baking tray
    px(d, 10, 38, 44,  6, (164,120, 64))
    px(d, 11, 36, 42,  4, (196,152, 88))
    # Cupcakes on tray
    for ci in range(4):
        cx = 13 + ci*9
        px(d, cx, 32,  7,  8, CK1)
        px(d, cx+1,30,  5,  4, CK2)
        px(d, cx+2,28,  3,  3, (240,200,160))

    # Door handle bar
    px(d, 10, 56, 44,  4, (136,136,156))
    px(d, 10, 56, 44,  2, (160,160,184))

    # Side heat vent strip
    px(d,  0, 30, 2, 12, (255,120, 40, 160))
    px(d,  0, 31, 2,  2, (255,180, 60, 200))

    save(im, "oven.png")

make_oven()

# ─────────────────────────────────────────────────────────────────────────────
# PREP COUNTER (64×32)
# ─────────────────────────────────────────────────────────────────────────────
def make_prep_counter():
    im = img(64, 32); d = ImageDraw.Draw(im)
    # Cabinet
    px(d,  0, 18, 64, 14, WD2)
    px(d,  2, 16, 60, 14, WD1)
    px(d,  0, 28, 64,  4, WDK)
    # Top surface (stone/marble)
    px(d,  2,  8, 60, 12, CT)
    px(d,  2,  8, 60,  2, CTL)
    px(d,  2, 18, 60,  2, CTD)
    px(d,  0,  8,  2, 12, CTD)
    px(d, 62,  8,  2, 12, CTD)
    # Cutting board
    px(d,  4,  9, 24,  8, (212,184,136))
    px(d,  5, 10, 22,  6, (196,168,120))
    px(d,  7, 10, 18,  6, (180,152,104))
    # Bowl
    px(d, 40,  6, 18, 12, (138,184,176))
    px(d, 41,  8, 16,  8, (160,200,196))
    px(d, 43,  9, 12,  4, (192,216,212))
    px(d, 44, 11,  8,  2, WHT)
    # Rolling pin
    px(d, 10,  7, 16,  3, (212,172,120))
    px(d,  8,  8,  4,  1, (160,120, 72))
    px(d, 24,  8,  4,  1, (160,120, 72))
    # Flour dust
    px(d, 16, 14,  6,  2, (255,248,232,80))
    px(d, 32, 12,  4,  2, (255,248,232,80))

    save(im, "prep_counter.png")

make_prep_counter()

# ─────────────────────────────────────────────────────────────────────────────
# SHELF – INGREDIENTS / KITCHEN (64×64)  ★ liked
# ─────────────────────────────────────────────────────────────────────────────
def make_shelf_ingredients():
    im = img(64, 64); d = ImageDraw.Draw(im)
    # Side brackets
    for bx in [0, 60]:
        px(d, bx,  0,  4, 64, WDK)
        px(d, bx+1,1,  2, 62, WD2)

    shelf_y = [16, 36, 54]
    item_data = [
        # (x_offset, color_body, color_top, height)
        [(2,JAR1,(160,208,228),12),(14,JAR2,(184,220,160),10),(26,JAR3,(240,160,160),14),
         (38,PST,(248,220,140), 9),(50,(200,168,120),(224,196,152),11)],
        [(2,BRD,(232,168, 96),10),(12,(216,136, 72),(236,160,100), 8),(24,CK1,CK2,12),
         (36,JAR1,(160,208,228),10),(48,JAR2,(184,220,160),12)],
        [(4,(212,200,160),WHT,8),(18,BRD,(232,168,96),10),(32,CK1,CK2,12),
         (44,PST,(248,220,140),9)],
    ]
    for si, sy in enumerate(shelf_y):
        # Shelf plank
        px(d,  2, sy, 60,  4, WD1)
        px(d,  2, sy, 60,  2, WDL)
        px(d,  2, sy+3,60,  1, WDK)
        # Items sitting on shelf
        if si < len(item_data):
            for item in item_data[si]:
                ix, col, top, ih = item
                iy = sy - ih
                px(d, ix,    iy,    10, ih,  col)
                px(d, ix+1,  iy,     8,  3,  top)
                px(d, ix+2,  iy-1,   6,  2,  WD2)  # lid/cap
                # highlight
                px(d, ix+2,  iy+2,   3,  max(1,ih-4), (255,255,255,60))

    save(im, "shelf_ingredients.png")

make_shelf_ingredients()

# ─────────────────────────────────────────────────────────────────────────────
# SHELF – WAREHOUSE (64×80)  ★ liked, industrial crates
# ─────────────────────────────────────────────────────────────────────────────
def make_shelf_warehouse():
    im = img(64, 80); d = ImageDraw.Draw(im)
    for bx in [0, 60]:
        px(d, bx,  0,  4, 80, RKD)
        px(d, bx+1,1,  2, 78, RK1)

    shelf_y = [20, 48, 70]
    crate_rows = [
        [(2,12,16,CR1,CR2,CRD),(20,12,16,CR1,CR2,CRD),(38,12,16,CR1,CR2,CRD)],
        [(2,18,16,CR1,CR2,CRD),(22,14,14,(184,160, 96),(208,184,120),(144,120,64))],
        [(2,14,16,(168,184,200),(192,210,224),(128,148,168))],
    ]
    for si, sy in enumerate(shelf_y):
        # Metal shelf plank
        px(d,  2, sy, 60,  4, RK1)
        px(d,  2, sy, 60,  2, RK2)
        px(d,  2, sy+3,60,  1, RKD)
        if si < len(crate_rows):
            for (ix, ih, iw, cc, cl, cd) in crate_rows[si]:
                iy = sy - ih
                px(d, ix,    iy,    iw, ih, cc)
                px(d, ix+1,  iy,    iw-2,3, cl)
                px(d, ix,    iy+ih-2,iw,2, cd)
                # Cross brace lines
                px(d, ix+iw//2, iy,  2, ih, cd)
                px(d, ix,  iy+ih//2, iw, 2, cd)
                # Label
                if iw >= 14:
                    px(d, ix+2, iy+4, iw-4, 6, WHT)
    save(im, "shelf_warehouse.png")

make_shelf_warehouse()

# ─────────────────────────────────────────────────────────────────────────────
# DOOR – ENTRANCE (32×48) bottom-right of sales room
# ─────────────────────────────────────────────────────────────────────────────
def make_door_entrance():
    im = img(32, 48); d = ImageDraw.Draw(im)
    # Frame
    px(d,  0,  0,  4, 48, WDK)
    px(d, 28,  0,  4, 48, WDK)
    px(d,  0,  0, 32,  4, WDK)
    px(d,  1,  1,  2, 46, WD2)
    px(d, 29,  1,  2, 46, WD2)
    # Door panels
    px(d,  4,  4, 24, 44, (184,116, 56))
    px(d,  4,  4, 24,  2, (208,140, 80))
    px(d,  4,  4,  2, 44, (208,140, 80))
    px(d, 26,  4,  2, 44, (152, 88, 36))
    px(d,  4, 46, 24,  2, (152, 88, 36))
    # Recessed panels
    px(d,  7,  8, 18, 16, (160, 96, 44))
    px(d,  8,  9, 16, 14, (200,128, 72))
    px(d,  8,  9, 16,  2, (220,152, 96))
    px(d,  7, 28, 18, 14, (160, 96, 44))
    px(d,  8, 29, 16, 12, (200,128, 72))
    px(d,  8, 29, 16,  2, (220,152, 96))
    # Handle / knob
    px(d, 22, 26,  4,  6, GLD)
    px(d, 23, 24,  2,  3, (232,188, 80))
    # Glass strip (sidelight sim)
    px(d,  5, 10,  3, 12, (180,220,240,160))
    px(d,  5, 11,  2,  2, (220,240,255,200))

    save(im, "door_entrance.png")

make_door_entrance()

# ─────────────────────────────────────────────────────────────────────────────
# DOOR – INTERIOR (32×48) kitchen↔warehouse style
# ─────────────────────────────────────────────────────────────────────────────
def make_door_interior():
    im = img(32, 48); d = ImageDraw.Draw(im)
    px(d,  0,  0,  4, 48, WDK)
    px(d, 28,  0,  4, 48, WDK)
    px(d,  0,  0, 32,  4, WDK)
    px(d,  1,  1,  2, 46, WD2)
    px(d, 29,  1,  2, 46, WD2)
    # Door
    px(d,  4,  4, 24, 44, (216,216,208))
    px(d,  4,  4,  2, 44, (240,240,232))
    px(d, 26,  4,  2, 44, (192,192,184))
    # Panel border
    px(d,  7,  8, 18, 32, (200,200,192))
    px(d,  8,  9, 16, 30, (224,224,216))
    px(d,  8,  9, 16,  2, (240,240,232))
    # Handle
    px(d, 22, 26,  4,  6, (192,192,200))
    px(d, 23, 24,  2,  3, (216,216,224))
    # Kick plate bottom
    px(d,  5, 40, 22,  6, (176,176,184))
    px(d,  5, 40, 22,  2, (200,200,208))

    save(im, "door_interior.png")

make_door_interior()

# ─────────────────────────────────────────────────────────────────────────────
# PLANT (32×48)  decorative – sales room
# ─────────────────────────────────────────────────────────────────────────────
def make_plant():
    im = img(32, 48); d = ImageDraw.Draw(im)
    # Pot
    px(d,  6, 34, 20, 14, POT)
    px(d,  4, 32, 24,  4, POT)
    px(d,  4, 32, 24,  2, (220,144,112))
    px(d,  8, 33, 16,  2, (240,168,136))
    px(d,  7, 44, 18,  4, POTD)
    # Soil
    px(d,  7, 33, 18,  4, (88,56,24))
    px(d,  9, 34, 14,  2, (112,72,32))
    # Main stem
    px(d, 15, 16,  3, 18, PL2)
    px(d, 14, 24,  2, 10, PL2)
    px(d, 18, 20,  2,  8, PL2)
    # Leaves cluster
    px(d,  4,  4, 14, 18, PL1)
    px(d,  6,  2, 10, 16, PL3)
    px(d,  8,  1,  6, 12, PL1)
    px(d, 14,  6, 14, 18, PL1)
    px(d, 16,  4, 10, 14, PL3)
    px(d,  6, 18, 20, 10, PL1)
    px(d,  8, 16, 16,  8, PL3)
    # Vein highlights
    px(d,  9,  6,  2, 12, (148,192,148))
    px(d, 18,  8,  2, 14, (148,192,148))

    save(im, "plant_decor.png")

make_plant()

# ─────────────────────────────────────────────────────────────────────────────
# MIXER (32×32) – kitchen
# ─────────────────────────────────────────────────────────────────────────────
def make_mixer():
    im = img(32, 32); d = ImageDraw.Draw(im)
    # Base
    px(d,  2, 22, 28, 10, (160, 80, 72))
    px(d,  0, 24, 32,  8, (140, 60, 54))
    px(d,  0, 30, 32,  2, (100, 40, 36))
    # Bowl
    px(d,  2, 18, 28, 14, (138,184,176))
    px(d,  4, 20, 24, 10, (160,204,196))
    px(d,  6, 22, 20,  6, (184,220,212))
    # Batter
    px(d,  6, 24, 20,  6, (232,196,140))
    px(d,  8, 25, 16,  4, (248,216,160))
    # Arm
    px(d, 12,  6,  8, 16, (180, 90, 82))
    px(d, 10,  4, 12,  4, (200,110,102))
    # Head / motor
    px(d,  8,  2, 16, 10, (200,100, 92))
    px(d,  9,  3, 14,  8, (220,130,120))
    px(d,  9,  3, 14,  2, (240,160,152))
    # Whisk attachment
    px(d, 14, 14,  4, 10, (176,196,188))
    px(d, 13, 18,  2,  4, (152,176,168))
    px(d, 17, 18,  2,  4, (152,176,168))
    # Speed dial
    px(d, 22,  8,  6,  6, (60,60,74))
    px(d, 23,  9,  4,  4, (200,160, 80))
    px(d, 24, 10,  2,  2, GLD)

    save(im, "mixer.png")

make_mixer()

# ─────────────────────────────────────────────────────────────────────────────
# COLD STORAGE (64×64) – warehouse  ★
# ─────────────────────────────────────────────────────────────────────────────
def make_cold_storage():
    im = img(64, 64); d = ImageDraw.Draw(im)
    # Body
    px(d,  2,  4, 60, 60, (176,200,216))
    px(d,  0,  2,  2, 60, (144,168,188))
    px(d, 62,  2,  2, 60, (200,224,240))
    px(d,  0, 62, 64,  2, (120,148,168))
    # Top frame
    px(d,  0,  0, 64,  6, (106,130,152))
    px(d,  0,  0, 64,  2, (130,156,178))
    # Door
    px(d,  6,  8, 52, 50, (148,184,208))
    px(d,  6,  8, 52,  2, (200,230,248))
    px(d,  6,  8,  2, 50, (200,230,248))
    px(d, 56,  8,  2, 50, (120,155,180))
    px(d,  6, 56, 52,  2, (120,155,180))
    # Inner door panel
    px(d, 10, 12, 44, 42, (168,208,228))
    px(d, 11, 13, 42, 40, (188,222,240))
    # Ice/frost effect
    px(d, 12, 14, 10,  8, (220,238,252,180))
    px(d, 36, 20, 12,  6, (220,238,252,180))
    px(d, 16, 38, 14, 10, (220,238,252,180))
    # Snowflake symbol
    px(d, 28, 26,  8,  2, WHT)
    px(d, 31, 22,  2,  8, WHT)
    px(d, 28, 24,  2,  2, WHT)
    px(d, 34, 24,  2,  2, WHT)
    px(d, 28, 30,  2,  2, WHT)
    px(d, 34, 30,  2,  2, WHT)
    # Temperature display
    px(d, 14,  4, 24,  6, (40,60,80))
    px(d, 15,  5, 22,  4, (60,100,140))
    # Handle
    px(d, 50, 28,  8,  4, (136,160,180))
    px(d, 52, 26,  4,  8, (160,184,204))
    px(d, 53, 27,  2,  6, (200,220,236))

    save(im, "cold_storage.png")

make_cold_storage()

# ─────────────────────────────────────────────────────────────────────────────
# TABLET STATION (32×48) – warehouse
# ─────────────────────────────────────────────────────────────────────────────
def make_tablet_station():
    im = img(32, 48); d = ImageDraw.Draw(im)
    # Stand pole
    px(d, 13, 28,  6, 16, RK1)
    px(d, 14, 26,  4,  4, RK2)
    # Base
    px(d,  6, 42, 20,  6, RKD)
    px(d,  4, 44, 24,  4, RK1)
    # Tablet body
    px(d,  2,  4, 28, 26, (42, 54, 68))
    px(d,  0,  2,  2, 28, (32, 44, 58))
    px(d, 30,  2,  2, 28, (54, 68, 84))
    px(d,  0,  2, 32,  4, (54, 68, 84))
    px(d,  0, 28, 32,  4, (32, 44, 58))
    # Screen
    px(d,  4,  6, 24, 20, (56,160,200))
    px(d,  4,  6, 24,  2, (100,200,240))
    # UI elements on screen
    px(d,  6, 10, 20,  2, WHT)   # title bar
    for row in range(3):
        px(d,  6, 14+row*4, 10,  2, (200,220,240))
        px(d, 18, 14+row*4,  8,  2, (200,220,240))
    # Home button
    px(d, 13, 28,  6,  2, (80,80,100))
    px(d, 14, 27,  4,  2, (120,120,140))

    save(im, "tablet_station.png")

make_tablet_station()

# ─────────────────────────────────────────────────────────────────────────────
# STOVETOP / PAN STATION (64×32) – kitchen
# ─────────────────────────────────────────────────────────────────────────────
def make_stovetop():
    im = img(64, 32); d = ImageDraw.Draw(im)
    # Body
    px(d,  0, 14, 64, 18, (88,88,102))
    px(d,  0, 12, 64,  4, (110,110,128))
    px(d,  0, 12, 64,  2, CT)
    # Burners x4
    burners = [(4,16),(20,16),(4,24),(20,24)]
    for bx, by in burners:
        px(d, bx, by, 14,  8, (42,42,54))
        px(d, bx+2,by+2,10,  4, (66,66,80))
        px(d, bx+4,by+3, 6,  2, (255, 96, 32))   # flame
        px(d, bx+5,by+2, 4,  1, (255,176, 60))
    # Large pan on right burners
    px(d, 36, 10, 26, 18, (50,50,60))
    px(d, 37, 11, 24, 14, (36,36,46))
    px(d, 40, 13, 18, 10, (120,60,24))  # food
    px(d, 42, 12, 14,  5, (200,80,40))
    # Pan handle
    px(d, 60, 14,  8,  4, (78,78,90))
    px(d, 60, 14,  8,  2, (100,100,116))
    # Knobs on right
    for ky in [14,22]:
        px(d, 56, ky,  6,  6, (50,50,64))
        px(d, 57, ky+1,4,  4, GLD)
        px(d, 58, ky+2,2,  2, (248,216,100))

    save(im, "stovetop.png")

make_stovetop()

# ─────────────────────────────────────────────────────────────────────────────
# SINK (48×32) – kitchen
# ─────────────────────────────────────────────────────────────────────────────
def make_sink():
    im = img(48, 32); d = ImageDraw.Draw(im)
    px(d,  0, 18, 48, 14, WD2)
    px(d,  2, 16, 44, 14, WD1)
    px(d,  0, 28, 48,  4, WDK)
    # Counter top
    px(d,  2,  8, 44, 12, (200,200,192))
    px(d,  2,  8, 44,  2, (220,220,212))
    # Sink basin
    px(d,  6, 10, 36, 12, (106,140,152))
    px(d,  8, 12, 32,  8, (138,176,192))
    px(d, 10, 14, 28,  4, (180,210,220))
    # Drain
    px(d, 22, 18,  4,  2, (80,100,116))
    # Faucet
    px(d, 21,  2,  6, 10, (192,196,204))
    px(d, 18,  2, 12,  3, (192,196,204))
    px(d, 14,  2,  6,  3, (192,196,204))
    px(d, 28,  2,  6,  3, (192,196,204))
    px(d, 23,  8,  2,  4, (160,200,220))  # water
    # Soap dispenser
    px(d, 38,  8,  8, 12, (220,200,240))
    px(d, 39,  6,  6,  4, (200,180,220))
    px(d, 41,  5,  2,  2, (180,160,200))
    # Towel
    px(d,  0,  8,  5, 14, (212,200,144))
    px(d,  0,  8,  5,  3, (192,180,120))
    px(d,  0, 13,  5,  3, (192,180,120))

    save(im, "sink.png")

make_sink()

print("\n✅ All sprites generated!")
print(f"📁 Location: {OUT}")
import os
files = os.listdir(OUT)
print(f"📦 {len(files)} files:")
for f in sorted(files):
    size = os.path.getsize(os.path.join(OUT, f))
    print(f"   {f} ({size} bytes)")