Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$Root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$OutDir = Join-Path $Root "assets\art\generated\environment\batch_03"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Color([int] $R, [int] $G, [int] $B, [int] $A = 255) {
    return [System.Drawing.Color]::FromArgb($A, $R, $G, $B)
}

function New-Sheet([int] $Width, [int] $Height, [System.Drawing.Color] $Background) {
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear($Background)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Save-Sheet([hashtable] $Sheet, [string] $Path) {
    if ($null -eq $Sheet.Bitmap -or $null -eq $Sheet.Graphics) {
        throw "Invalid sheet object for $Path."
    }
    $Sheet.Graphics.Dispose()
    $Sheet.Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $Sheet.Bitmap.Dispose()
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Failed to write environment sheet: $Path"
    }
}

function Fill-Rect([System.Drawing.Graphics] $G, [int] $X, [int] $Y, [int] $W, [int] $H, [System.Drawing.Color] $C) {
    $brush = [System.Drawing.SolidBrush]::new($C)
    $G.FillRectangle($brush, $X, $Y, $W, $H)
    $brush.Dispose()
}

function Fill-Ellipse([System.Drawing.Graphics] $G, [int] $X, [int] $Y, [int] $W, [int] $H, [System.Drawing.Color] $C) {
    $brush = [System.Drawing.SolidBrush]::new($C)
    $G.FillEllipse($brush, $X, $Y, $W, $H)
    $brush.Dispose()
}

function Draw-Line([System.Drawing.Graphics] $G, [int] $X1, [int] $Y1, [int] $X2, [int] $Y2, [System.Drawing.Color] $C, [int] $W = 1) {
    $pen = [System.Drawing.Pen]::new($C, $W)
    $G.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

function Draw-Tile([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Room, [int] $Variant) {
    $base = Color 232 215 181
    $seam = Color 155 148 136
    $accent = Color 239 195 184
    if ($Room -eq "kitchen") {
        $base = Color 224 226 218
        $seam = Color 119 133 137
        $accent = Color 196 211 216
    } elseif ($Room -eq "warehouse") {
        $base = Color 142 143 136
        $seam = Color 103 111 112
        $accent = Color 166 156 130
    } elseif ($Room -eq "transition") {
        $base = Color 199 174 134
        $seam = Color 130 103 75
        $accent = Color 226 207 158
    }

    Fill-Rect $G $Ox $Oy 32 32 $base
    Fill-Rect $G $Ox $Oy 32 1 $seam
    Fill-Rect $G $Ox $Oy 1 32 $seam
    Fill-Rect $G ($Ox + 31) $Oy 1 32 (Color $seam.R $seam.G $seam.B 125)
    Fill-Rect $G $Ox ($Oy + 31) 32 1 (Color $seam.R $seam.G $seam.B 125)

    if ($Room -eq "sales") {
        if ($Variant % 2 -eq 0) { Fill-Rect $G ($Ox + 1) ($Oy + 1) 30 30 (Color 241 221 185) }
        if ($Variant -in @(1, 5)) { Fill-Rect $G ($Ox + 1) ($Oy + 1) 30 30 $accent }
        if ($Variant -eq 6) { Fill-Rect $G ($Ox + 5) ($Oy + 13) 22 6 (Color 168 108 83) }
        if ($Variant -eq 7) { Fill-Rect $G ($Ox + 7) ($Oy + 7) 18 18 (Color 220 185 124) }
    } elseif ($Room -eq "kitchen") {
        if ($Variant % 2 -eq 1) { Fill-Rect $G ($Ox + 1) ($Oy + 1) 30 30 (Color 236 237 231) }
        if ($Variant -in @(2, 6)) { Fill-Rect $G ($Ox + 7) ($Oy + 7) 18 18 $accent }
        if ($Variant -eq 5) { Fill-Rect $G ($Ox + 3) ($Oy + 22) 9 2 (Color 172 177 169) }
        if ($Variant -eq 7) { Fill-Rect $G ($Ox + 12) ($Oy + 3) 2 26 (Color 167 188 191) }
    } elseif ($Room -eq "warehouse") {
        if ($Variant % 3 -eq 0) { Fill-Rect $G ($Ox + 2) ($Oy + 2) 28 28 (Color 151 153 147) }
        if ($Variant -eq 3) { Draw-Line $G ($Ox + 5) ($Oy + 25) ($Ox + 25) ($Oy + 5) (Color 116 123 121) 1 }
        if ($Variant -eq 5) { Fill-Rect $G ($Ox + 2) ($Oy + 14) 28 4 (Color 190 167 98) }
        if ($Variant -eq 7) { Fill-Rect $G ($Ox + 4) ($Oy + 4) 24 24 (Color 127 133 133) }
    } else {
        if ($Variant -in @(0, 1)) { Fill-Rect $G ($Ox + 1) ($Oy + 1) 30 15 (Color 240 221 184); Fill-Rect $G ($Ox + 1) ($Oy + 16) 30 15 (Color 226 226 219) }
        if ($Variant -eq 2) { Fill-Rect $G ($Ox + 2) ($Oy + 13) 28 6 (Color 116 151 134) }
        if ($Variant -eq 3) { Fill-Rect $G ($Ox + 3) ($Oy + 3) 26 26 (Color 185 148 96) }
        if ($Variant -eq 4) { Draw-Line $G ($Ox + 4) ($Oy + 4) ($Ox + 28) ($Oy + 28) (Color 231 212 127) 2 }
        if ($Variant -eq 5) { Fill-Rect $G ($Ox + 4) ($Oy + 22) 24 4 (Color 105 131 126) }
        if ($Variant -eq 6) { Fill-Rect $G ($Ox + 6) ($Oy + 6) 20 20 (Color 174 137 92) }
        if ($Variant -eq 7) { Fill-Rect $G ($Ox + 10) ($Oy + 10) 12 12 (Color 225 205 150) }
    }
}

function Draw-Wall([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Room, [int] $Variant) {
    $wall = Color 238 222 190
    $trim = Color 165 104 67
    $detail = Color 218 156 144
    if ($Room -eq "kitchen") {
        $wall = Color 230 232 224
        $trim = Color 127 144 148
        $detail = Color 184 197 200
    } elseif ($Room -eq "warehouse") {
        $wall = Color 151 142 126
        $trim = Color 86 92 88
        $detail = Color 185 160 102
    }

    Fill-Rect $G ($Ox + 5) ($Oy + 8) 54 30 $wall
    Fill-Rect $G ($Ox + 5) ($Oy + 36) 54 5 $trim
    Fill-Rect $G ($Ox + 5) ($Oy + 7) 54 2 (Color 255 249 220 115)
    if ($Variant -eq 1) {
        Fill-Rect $G ($Ox + 30) ($Oy + 8) 6 34 $trim
    } elseif ($Variant -eq 2) {
        Fill-Rect $G ($Ox + 5) ($Oy + 8) 8 34 $trim
        Fill-Rect $G ($Ox + 51) ($Oy + 8) 8 34 $trim
    } elseif ($Variant -eq 3) {
        Fill-Rect $G ($Ox + 22) ($Oy + 14) 20 27 (Color 115 83 61)
        Fill-Rect $G ($Ox + 25) ($Oy + 17) 14 17 (Color 167 202 208)
        Fill-Rect $G ($Ox + 10) ($Oy + 42) 44 9 (Color 145 91 57)
    } elseif ($Variant -eq 4) {
        Fill-Rect $G ($Ox + 18) ($Oy + 14) 28 6 $detail
        Fill-Rect $G ($Ox + 20) ($Oy + 24) 24 4 $detail
        Fill-Rect $G ($Ox + 24) ($Oy + 32) 16 4 $detail
    } elseif ($Variant -eq 5) {
        Fill-Rect $G ($Ox + 10) ($Oy + 14) 44 16 (Color 124 93 66)
        Fill-Rect $G ($Ox + 13) ($Oy + 17) 38 10 (Color 230 202 137)
    } elseif ($Variant -eq 6) {
        Fill-Rect $G ($Ox + 12) ($Oy + 12) 10 14 $detail
        Fill-Rect $G ($Ox + 29) ($Oy + 11) 10 15 $detail
        Fill-Rect $G ($Ox + 46) ($Oy + 13) 6 13 $detail
    } elseif ($Variant -eq 7) {
        Fill-Rect $G ($Ox + 8) ($Oy + 40) 48 13 (Color 159 105 64)
        Fill-Rect $G ($Ox + 11) ($Oy + 37) 42 6 (Color 233 212 163)
        Fill-Rect $G ($Ox + 17) ($Oy + 32) 8 6 (Color 224 150 75)
        Fill-Rect $G ($Ox + 35) ($Oy + 32) 9 6 (Color 195 83 67)
    }
}

function Draw-Machine([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Id) {
    $shadow = Color 45 32 27 55
    $outline = Color 48 35 29
    Fill-Ellipse $G ($Ox + 8) ($Oy + 52) 48 7 $shadow
    switch ($Id) {
        "oven_basic" {
            Fill-Rect $G ($Ox + 12) ($Oy + 16) 40 34 $outline
            Fill-Rect $G ($Ox + 15) ($Oy + 13) 34 36 (Color 194 86 71)
            Fill-Rect $G ($Ox + 19) ($Oy + 20) 26 17 (Color 248 218 164)
            Fill-Rect $G ($Ox + 22) ($Oy + 23) 20 11 (Color 255 164 66)
            Fill-Rect $G ($Ox + 40) ($Oy + 15) 4 4 (Color 237 197 82)
        }
        "prep_counter" {
            Fill-Rect $G ($Ox + 7) ($Oy + 27) 50 20 $outline
            Fill-Rect $G ($Ox + 9) ($Oy + 24) 46 21 (Color 126 82 54)
            Fill-Rect $G ($Ox + 10) ($Oy + 17) 44 13 (Color 219 204 177)
            Fill-Ellipse $G ($Ox + 31) ($Oy + 20) 14 8 (Color 127 158 151)
            Draw-Line $G ($Ox + 15) ($Oy + 18) ($Ox + 35) ($Oy + 13) (Color 116 75 42) 2
        }
        "stovetop" {
            Fill-Rect $G ($Ox + 8) ($Oy + 26) 48 21 $outline
            Fill-Rect $G ($Ox + 10) ($Oy + 23) 44 22 (Color 95 103 105)
            Fill-Ellipse $G ($Ox + 16) ($Oy + 28) 12 9 (Color 34 34 34)
            Fill-Ellipse $G ($Ox + 36) ($Oy + 28) 12 9 (Color 34 34 34)
            Fill-Rect $G ($Ox + 19) ($Oy + 30) 6 3 (Color 246 137 55)
            Fill-Rect $G ($Ox + 38) ($Oy + 30) 7 3 (Color 73 130 202)
        }
        "display_case" {
            Fill-Rect $G ($Ox + 7) ($Oy + 27) 50 21 $outline
            Fill-Rect $G ($Ox + 9) ($Oy + 25) 46 21 (Color 121 82 55)
            Fill-Rect $G ($Ox + 12) ($Oy + 17) 40 20 (Color 159 211 219 165)
            Fill-Rect $G ($Ox + 15) ($Oy + 28) 7 4 (Color 229 149 80)
            Fill-Rect $G ($Ox + 28) ($Oy + 27) 8 5 (Color 203 82 70)
            Fill-Rect $G ($Ox + 42) ($Oy + 28) 6 4 (Color 237 197 88)
        }
        "warehouse_rack" {
            Fill-Rect $G ($Ox + 8) ($Oy + 17) 48 33 $outline
            Fill-Rect $G ($Ox + 11) ($Oy + 19) 42 29 (Color 106 113 111)
            Fill-Rect $G ($Ox + 13) ($Oy + 23) 38 4 (Color 73 78 76)
            Fill-Rect $G ($Ox + 13) ($Oy + 37) 38 4 (Color 73 78 76)
            Fill-Rect $G ($Ox + 16) ($Oy + 28) 11 8 (Color 205 166 99)
            Fill-Rect $G ($Ox + 33) ($Oy + 28) 13 8 (Color 145 92 50)
        }
        "cold_storage" {
            Fill-Rect $G ($Ox + 15) ($Oy + 11) 34 42 $outline
            Fill-Rect $G ($Ox + 17) ($Oy + 9) 30 42 (Color 194 222 207)
            Fill-Rect $G ($Ox + 20) ($Oy + 15) 24 20 (Color 146 198 214)
            Fill-Rect $G ($Ox + 41) ($Oy + 28) 3 10 (Color 91 103 99)
        }
        "mixer" {
            Fill-Rect $G ($Ox + 22) ($Oy + 22) 22 18 $outline
            Fill-Rect $G ($Ox + 24) ($Oy + 20) 18 18 (Color 210 142 120)
            Fill-Ellipse $G ($Ox + 20) ($Oy + 34) 24 11 (Color 162 174 166)
            Fill-Rect $G ($Ox + 27) ($Oy + 16) 12 7 (Color 238 213 177)
        }
        "drink_station" {
            Fill-Rect $G ($Ox + 18) ($Oy + 20) 30 27 $outline
            Fill-Rect $G ($Ox + 20) ($Oy + 18) 26 27 (Color 150 111 76)
            Fill-Rect $G ($Ox + 23) ($Oy + 12) 8 10 (Color 185 213 206)
            Fill-Rect $G ($Ox + 35) ($Oy + 12) 7 12 (Color 213 97 80)
            Fill-Rect $G ($Ox + 25) ($Oy + 32) 17 3 (Color 83 64 52)
        }
        "cashier_stand" {
            Fill-Rect $G ($Ox + 8) ($Oy + 28) 48 20 $outline
            Fill-Rect $G ($Ox + 10) ($Oy + 25) 44 21 (Color 143 91 58)
            Fill-Rect $G ($Ox + 35) ($Oy + 17) 14 10 (Color 72 74 76)
            Fill-Rect $G ($Ox + 38) ($Oy + 19) 8 3 (Color 96 174 188)
            Fill-Ellipse $G ($Ox + 17) ($Oy + 20) 6 6 (Color 231 184 78)
        }
        "table_two" {
            Fill-Ellipse $G ($Ox + 20) ($Oy + 21) 24 22 $outline
            Fill-Ellipse $G ($Ox + 22) ($Oy + 20) 20 20 (Color 166 104 61)
            Fill-Rect $G ($Ox + 24) ($Oy + 10) 16 7 (Color 125 83 57)
            Fill-Rect $G ($Ox + 24) ($Oy + 45) 16 7 (Color 125 83 57)
            Fill-Rect $G ($Ox + 30) ($Oy + 25) 4 4 (Color 229 194 110)
        }
        "sink" {
            Fill-Rect $G ($Ox + 10) ($Oy + 25) 44 21 $outline
            Fill-Rect $G ($Ox + 12) ($Oy + 23) 40 21 (Color 213 219 211)
            Fill-Ellipse $G ($Ox + 21) ($Oy + 27) 18 10 (Color 142 188 202)
            Draw-Line $G ($Ox + 31) ($Oy + 24) ($Ox + 40) ($Oy + 18) (Color 176 133 73) 2
        }
        "trash_bin" {
            Fill-Rect $G ($Ox + 22) ($Oy + 22) 21 28 $outline
            Fill-Rect $G ($Ox + 24) ($Oy + 20) 17 28 (Color 83 116 105)
            Fill-Rect $G ($Ox + 22) ($Oy + 18) 21 5 (Color 63 88 82)
            Fill-Rect $G ($Ox + 30) ($Oy + 44) 6 2 (Color 203 183 134)
        }
        "tablet_station" {
            Fill-Rect $G ($Ox + 22) ($Oy + 24) 21 24 $outline
            Fill-Rect $G ($Ox + 24) ($Oy + 22) 17 24 (Color 112 83 58)
            Fill-Rect $G ($Ox + 20) ($Oy + 11) 24 16 $outline
            Fill-Rect $G ($Ox + 23) ($Oy + 14) 18 10 (Color 79 158 185)
        }
        "packing_station" {
            Fill-Rect $G ($Ox + 8) ($Oy + 27) 48 20 $outline
            Fill-Rect $G ($Ox + 10) ($Oy + 24) 44 21 (Color 130 91 62)
            Fill-Rect $G ($Ox + 15) ($Oy + 17) 14 10 (Color 183 127 69)
            Fill-Rect $G ($Ox + 34) ($Oy + 19) 12 8 (Color 228 208 156)
            Fill-Rect $G ($Ox + 39) ($Oy + 15) 9 4 (Color 104 78 57)
        }
        default {
            Fill-Rect $G ($Ox + 24) ($Oy + 30) 16 18 $outline
            Fill-Rect $G ($Ox + 26) ($Oy + 28) 12 18 (Color 190 135 87)
            Fill-Ellipse $G ($Ox + 20) ($Oy + 15) 12 15 (Color 92 148 91)
            Fill-Ellipse $G ($Ox + 33) ($Oy + 12) 12 16 (Color 102 158 96)
            Fill-Ellipse $G ($Ox + 28) ($Oy + 8) 10 14 (Color 118 171 105)
        }
    }
}

function Draw-Room-Thumbnail([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Room) {
    $floor = if ($Room -eq "sales") { Color 235 215 181 } elseif ($Room -eq "kitchen") { Color 224 226 219 } elseif ($Room -eq "warehouse") { Color 145 147 140 } else { Color 209 185 139 }
    $wall = if ($Room -eq "sales") { Color 238 222 190 } elseif ($Room -eq "kitchen") { Color 230 232 224 } elseif ($Room -eq "warehouse") { Color 151 142 126 } else { Color 192 165 122 }
    Fill-Rect $G $Ox $Oy 192 128 $floor
    for ($x = 0; $x -lt 192; $x += 16) { Draw-Line $G ($Ox + $x) $Oy ($Ox + $x) ($Oy + 128) (Color 80 70 60 35) 1 }
    for ($y = 0; $y -lt 128; $y += 16) { Draw-Line $G $Ox ($Oy + $y) ($Ox + 192) ($Oy + $y) (Color 80 70 60 35) 1 }
    Fill-Rect $G $Ox $Oy 192 13 $wall
    Fill-Rect $G $Ox $Oy 12 128 $wall
    Fill-Rect $G ($Ox + 180) $Oy 12 128 $wall
    if ($Room -eq "sales") {
        Draw-Machine $G ($Ox + 18) ($Oy + 26) "display_case"
        Draw-Machine $G ($Ox + 88) ($Oy + 28) "cashier_stand"
        Draw-Machine $G ($Ox + 128) ($Oy + 70) "table_two"
        Fill-Rect $G ($Ox + 76) ($Oy + 104) 44 8 (Color 116 151 134)
    } elseif ($Room -eq "kitchen") {
        Draw-Machine $G ($Ox + 18) ($Oy + 26) "prep_counter"
        Draw-Machine $G ($Ox + 86) ($Oy + 22) "oven_basic"
        Draw-Machine $G ($Ox + 130) ($Oy + 62) "stovetop"
        Draw-Machine $G ($Ox + 34) ($Oy + 68) "sink"
    } elseif ($Room -eq "warehouse") {
        Draw-Machine $G ($Ox + 16) ($Oy + 26) "warehouse_rack"
        Draw-Machine $G ($Ox + 82) ($Oy + 24) "cold_storage"
        Draw-Machine $G ($Ox + 134) ($Oy + 30) "tablet_station"
        Fill-Rect $G ($Ox + 36) ($Oy + 92) 52 18 (Color 190 167 98)
    } else {
        Fill-Rect $G ($Ox + 22) ($Oy + 25) 58 38 (Color 226 207 158)
        Fill-Rect $G ($Ox + 92) ($Oy + 25) 58 38 (Color 240 221 184)
        Draw-Line $G ($Ox + 24) ($Oy + 86) ($Ox + 162) ($Oy + 86) (Color 231 212 127) 2
        Draw-Machine $G ($Ox + 104) ($Oy + 58) "plant"
    }
}

function Draw-Decal([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Index) {
    switch ($Index) {
        0 { Draw-Line $G ($Ox + 4) ($Oy + 6) ($Ox + 27) ($Oy + 26) (Color 238 222 130) 2 }
        1 { Fill-Rect $G ($Ox + 4) ($Oy + 13) 24 6 (Color 188 163 91) }
        2 { Fill-Rect $G ($Ox + 8) ($Oy + 8) 16 16 (Color 226 207 158); Draw-Line $G ($Ox + 8) ($Oy + 8) ($Ox + 24) ($Oy + 24) (Color 153 128 87) 1 }
        3 { Fill-Rect $G ($Ox + 7) ($Oy + 18) 18 5 (Color 241 235 208 150); Fill-Rect $G ($Ox + 14) ($Oy + 14) 7 3 (Color 241 235 208 130) }
        4 { Fill-Rect $G ($Ox + 5) ($Oy + 12) 22 3 (Color 96 101 98 120); Fill-Rect $G ($Ox + 8) ($Oy + 19) 16 2 (Color 96 101 98 95) }
        5 { Fill-Rect $G ($Ox + 4) ($Oy + 4) 24 24 (Color 116 151 134 125); Fill-Rect $G ($Ox + 8) ($Oy + 14) 16 4 (Color 116 151 134 180) }
        6 { Fill-Rect $G ($Ox + 5) ($Oy + 5) 22 22 (Color 231 96 67 70); Draw-Line $G ($Ox + 5) ($Oy + 5) ($Ox + 27) ($Oy + 27) (Color 231 96 67 120) 2 }
        7 { Fill-Rect $G ($Ox + 4) ($Oy + 4) 24 24 (Color 190 167 98 125); Fill-Rect $G ($Ox + 8) ($Oy + 8) 16 16 (Color 190 167 98 80) }
    }
}

$manifest = [ordered]@{
    batch = "environment_batch_03"
    style = "Stardew-like cozy top-down 2D pixel art, 32 px tile grid, room-specific materials"
    assets = @()
}

$sheet = New-Sheet 256 128 (Color 0 0 0 0)
$rooms = @("sales", "kitchen", "warehouse", "transition")
for ($row = 0; $row -lt 4; $row++) {
    for ($col = 0; $col -lt 8; $col++) {
        Draw-Tile $sheet.Graphics ($col * 32) ($row * 32) $rooms[$row] $col
    }
}
$path = Join-Path $OutDir "room_floor_tiles_8x4.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "room_floor_tiles_8x4.png"; frame_size = "32x32"; grid = "8x4"; hframes = 8; vframes = 4; rows = @("sales_room", "kitchen", "warehouse", "transitions_and_markers") }

$sheet = New-Sheet 512 192 (Color 0 0 0 0)
$wallRooms = @("sales", "kitchen", "warehouse")
for ($row = 0; $row -lt 3; $row++) {
    for ($col = 0; $col -lt 8; $col++) {
        Draw-Wall $sheet.Graphics ($col * 64) ($row * 64) $wallRooms[$row] $col
    }
}
$path = Join-Path $OutDir "room_wall_modules_8x3.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "room_wall_modules_8x3.png"; frame_size = "64x64"; grid = "8x3"; hframes = 8; vframes = 3; rows = @("sales_room", "kitchen", "warehouse"); columns = @("straight", "post", "corner", "door", "shelves", "board", "hooks", "pass_counter") }

$sheet = New-Sheet 256 256 (Color 0 0 0 0)
$machineIds = @(
    "oven_basic", "prep_counter", "stovetop", "display_case",
    "warehouse_rack", "cold_storage", "mixer", "drink_station",
    "cashier_stand", "table_two", "sink", "trash_bin",
    "tablet_station", "packing_station", "plant", "plant"
)
for ($i = 0; $i -lt $machineIds.Count; $i++) {
    Draw-Machine $sheet.Graphics (($i % 4) * 64) ([Math]::Floor($i / 4) * 64) $machineIds[$i]
}
$path = Join-Path $OutDir "starter_machines_placeables_4x4.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "starter_machines_placeables_4x4.png"; frame_size = "64x64"; grid = "4x4"; hframes = 4; vframes = 4; cells = $machineIds }

$sheet = New-Sheet 384 256 (Color 34 32 30)
Draw-Room-Thumbnail $sheet.Graphics 0 0 "sales"
Draw-Room-Thumbnail $sheet.Graphics 192 0 "kitchen"
Draw-Room-Thumbnail $sheet.Graphics 0 128 "warehouse"
Draw-Room-Thumbnail $sheet.Graphics 192 128 "expansion"
$path = Join-Path $OutDir "room_concept_thumbnails_2x2.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "room_concept_thumbnails_2x2.png"; frame_size = "192x128"; grid = "2x2"; hframes = 2; vframes = 2; cells = @("sales_room", "kitchen", "warehouse", "expansion_preview") }

$sheet = New-Sheet 256 32 (Color 0 0 0 0)
for ($col = 0; $col -lt 8; $col++) {
    Draw-Decal $sheet.Graphics ($col * 32) 0 $col
}
$path = Join-Path $OutDir "floor_decals_markers_8x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "floor_decals_markers_8x1.png"; frame_size = "32x32"; grid = "8x1"; hframes = 8; vframes = 1; cells = @("chalk_line", "tape_strip", "spare_tile", "flour_dust", "scuff_marks", "queue_marker", "heat_clearance", "delivery_zone") }

$manifestPath = Join-Path $OutDir "environment_batch_03_manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Generated environment design batch:"
Get-ChildItem -LiteralPath $OutDir -Filter "*.png" | Sort-Object Name | ForEach-Object {
    Write-Host (" - " + $_.FullName)
}
