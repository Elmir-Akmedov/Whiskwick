Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$Root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$OutDir = Join-Path $Root "assets\art\generated\animations\batch_02"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Color([int] $R, [int] $G, [int] $B, [int] $A = 255) {
    return [System.Drawing.Color]::FromArgb($A, $R, $G, $B)
}

function New-Sheet([int] $Width, [int] $Height) {
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
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
        throw "Failed to write animation sheet: $Path"
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

function Draw-Outlined-Rect([System.Drawing.Graphics] $G, [int] $X, [int] $Y, [int] $W, [int] $H, [System.Drawing.Color] $Fill, [System.Drawing.Color] $Outline) {
    Fill-Rect $G ($X - 1) ($Y - 1) ($W + 2) ($H + 2) $Outline
    Fill-Rect $G $X $Y $W $H $Fill
}

function Draw-Outlined-Ellipse([System.Drawing.Graphics] $G, [int] $X, [int] $Y, [int] $W, [int] $H, [System.Drawing.Color] $Fill, [System.Drawing.Color] $Outline) {
    Fill-Ellipse $G ($X - 1) ($Y - 1) ($W + 2) ($H + 2) $Outline
    Fill-Ellipse $G $X $Y $W $H $Fill
}

function Get-Role-Palette([string] $Role) {
    switch ($Role) {
        "player" {
            return @{
                Skin = Color 217 156 107; Hair = Color 78 48 33; Shirt = Color 92 143 122; Apron = Color 241 220 177
                Pants = Color 66 48 43; Accent = Color 197 87 72; Hat = Color 241 220 177; Prop = Color 155 105 60
            }
        }
        "baker" {
            return @{
                Skin = Color 219 160 109; Hair = Color 92 63 45; Shirt = Color 226 214 186; Apron = Color 247 239 217
                Pants = Color 72 61 55; Accent = Color 191 75 62; Hat = Color 255 248 231; Prop = Color 209 146 78
            }
        }
        "cashier" {
            return @{
                Skin = Color 210 146 100; Hair = Color 104 70 45; Shirt = Color 65 84 111; Apron = Color 240 217 169
                Pants = Color 50 45 55; Accent = Color 224 181 83; Hat = Color 65 84 111; Prop = Color 226 210 162
            }
        }
        "runner" {
            return @{
                Skin = Color 213 151 101; Hair = Color 61 45 34; Shirt = Color 234 219 187; Apron = Color 171 119 74
                Pants = Color 67 92 117; Accent = Color 195 72 59; Hat = Color 171 119 74; Prop = Color 143 88 49
            }
        }
        "cleaner" {
            return @{
                Skin = Color 218 155 106; Hair = Color 70 55 48; Shirt = Color 232 223 196; Apron = Color 108 170 151
                Pants = Color 86 81 78; Accent = Color 84 124 183; Hat = Color 108 170 151; Prop = Color 97 142 124
            }
        }
        "regular" {
            return @{
                Skin = Color 212 145 99; Hair = Color 95 66 47; Shirt = Color 137 166 192; Apron = Color 185 124 78
                Pants = Color 65 58 55; Accent = Color 230 210 158; Hat = Color 137 166 192; Prop = Color 96 64 45
            }
        }
        default {
            return @{
                Skin = Color 221 165 113; Hair = Color 67 48 39; Shirt = Color 204 108 132; Apron = Color 237 207 96
                Pants = Color 72 82 120; Accent = Color 245 231 170; Hat = Color 204 108 132; Prop = Color 96 64 45
            }
        }
    }
}

function Draw-Character([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Role, [int] $Direction, [int] $Frame, [string] $Action) {
    $p = Get-Role-Palette $Role
    $outline = Color 44 32 29
    $shadow = Color 46 34 30 56
    $step = @(-2, 0, 2, 0)[$Frame % 4]
    $bob = @(0, -1, 0, -1)[$Frame % 4]
    $cx = $Ox + 24
    $baseY = $Oy + 40

    Fill-Ellipse $G ($Ox + 12) ($Oy + 40) 24 5 $shadow

    $leftLegX = $cx - 7
    $rightLegX = $cx + 2
    if ($Direction -eq 1 -or $Direction -eq 3) {
        $leftLegX += $step
        $rightLegX -= $step
    } else {
        $leftLegX -= $step
        $rightLegX += $step
    }
    Draw-Outlined-Rect $G $leftLegX ($baseY - 12) 5 10 $p.Pants $outline
    Draw-Outlined-Rect $G $rightLegX ($baseY - 12) 5 10 $p.Pants $outline
    Fill-Rect $G ($leftLegX - 1) ($baseY - 2) 7 3 $outline
    Fill-Rect $G ($rightLegX - 1) ($baseY - 2) 7 3 $outline

    $torsoY = $Oy + 19 + $bob
    Draw-Outlined-Rect $G ($cx - 8) $torsoY 16 14 $p.Shirt $outline
    Draw-Outlined-Rect $G ($cx - 6) ($torsoY + 3) 12 13 $p.Apron $outline
    Fill-Rect $G ($cx - 4) ($torsoY + 7) 8 2 (Color 204 172 124)

    $armSwing = @(2, 0, -2, 0)[$Frame % 4]
    $leftArmX = $cx - 13
    $rightArmX = $cx + 9
    if ($Action -eq "carry" -or $Action -eq "serve") {
        Draw-Outlined-Rect $G ($cx - 13) ($torsoY + 10) 26 5 $p.Prop $outline
        Fill-Rect $G ($cx - 9) ($torsoY + 8) 6 3 (Color 230 166 82)
        Fill-Rect $G ($cx + 3) ($torsoY + 8) 6 3 (Color 199 88 73)
    } elseif ($Action -eq "mop") {
        Draw-Line $G ($cx + 8) ($torsoY - 1) ($cx + 19) ($torsoY + 21) $outline 3
        Draw-Line $G ($cx + 8) ($torsoY - 1) ($cx + 19) ($torsoY + 21) $p.Prop 1
        Fill-Rect $G ($cx + 16) ($torsoY + 19) 8 4 $p.Accent
    } elseif ($Action -eq "cashier") {
        Draw-Outlined-Rect $G ($cx + 8) ($torsoY + 7) 12 7 (Color 83 75 70) $outline
        Fill-Rect $G ($cx + 10) ($torsoY + 8) 8 2 $p.Accent
    } elseif ($Action -eq "knead") {
        Draw-Outlined-Ellipse $G ($cx - 11) ($torsoY + 12) 22 8 (Color 138 168 156) $outline
        Fill-Rect $G ($cx - 6) ($torsoY + 13) 12 3 (Color 247 226 174)
    } else {
        Draw-Outlined-Rect $G $leftArmX ($torsoY + 2 + $armSwing) 5 11 $p.Skin $outline
        Draw-Outlined-Rect $G $rightArmX ($torsoY + 2 - $armSwing) 5 11 $p.Skin $outline
    }

    $headY = $Oy + 7 + $bob
    if ($Direction -eq 2) {
        Draw-Outlined-Ellipse $G ($cx - 8) $headY 16 13 $p.Hair $outline
        Fill-Rect $G ($cx - 8) ($headY + 7) 16 4 $p.Hair
    } else {
        Draw-Outlined-Ellipse $G ($cx - 8) $headY 16 14 $p.Skin $outline
        Fill-Rect $G ($cx - 8) $headY 16 5 $p.Hair
        if ($Direction -eq 0) {
            Fill-Rect $G ($cx - 4) ($headY + 8) 2 2 $outline
            Fill-Rect $G ($cx + 3) ($headY + 8) 2 2 $outline
        } else {
            $eyeX = if ($Direction -eq 1) { $cx + 4 } else { $cx - 5 }
            Fill-Rect $G $eyeX ($headY + 8) 2 2 $outline
        }
    }

    if ($Role -eq "baker") {
        Draw-Outlined-Rect $G ($cx - 9) ($headY - 5) 18 5 $p.Hat $outline
        Fill-Rect $G ($cx - 6) ($headY - 8) 12 4 $p.Hat
    } elseif ($Role -eq "cleaner") {
        Fill-Rect $G ($cx - 8) ($headY - 2) 16 4 $p.Hat
    } elseif ($Role -eq "runner") {
        Draw-Line $G ($cx - 8) ($torsoY + 1) ($cx + 8) ($torsoY + 15) $p.Accent 2
    } elseif ($Role -eq "cashier") {
        Fill-Rect $G ($cx - 5) ($headY - 3) 10 3 $p.Accent
    }

    if ($Action -eq "tired") {
        Fill-Rect $G ($cx + 10) ($headY - 5) 3 2 (Color 122 151 210)
        Fill-Rect $G ($cx + 14) ($headY - 8) 2 2 (Color 122 151 210)
    }
}

function Draw-Customer-Reaction([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Role, [int] $Frame) {
    $action = @("wait", "browse", "order", "pay", "happy", "impatient", "leave", "sad")[$Frame]
    Draw-Character $G $Ox $Oy $Role 0 $Frame $action
    $cx = $Ox + 24
    if ($action -eq "order") {
        Fill-Rect $G ($cx + 10) ($Oy + 14) 5 8 (Color 245 225 172)
    } elseif ($action -eq "pay") {
        Fill-Rect $G ($cx + 11) ($Oy + 25) 6 4 (Color 226 181 83)
    } elseif ($action -eq "happy") {
        Fill-Rect $G ($cx + 10) ($Oy + 8) 3 3 (Color 252 223 82)
        Fill-Rect $G ($cx + 15) ($Oy + 5) 2 2 (Color 252 223 82)
    } elseif ($action -eq "impatient") {
        Fill-Rect $G ($cx + 10) ($Oy + 4) 2 8 (Color 205 70 62)
        Fill-Rect $G ($cx + 10) ($Oy + 14) 2 2 (Color 205 70 62)
    } elseif ($action -eq "sad") {
        Fill-Rect $G ($cx + 11) ($Oy + 7) 5 2 (Color 104 124 165)
    }
}

function Draw-Carry-Overlay([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Index) {
    $outline = Color 48 35 29
    Fill-Ellipse $G ($Ox + 8) ($Oy + 27) 16 4 (Color 46 34 30 48)
    switch ($Index) {
        0 { Draw-Outlined-Rect $G ($Ox + 7) ($Oy + 13) 18 12 (Color 154 94 51) $outline; Fill-Rect $G ($Ox + 10) ($Oy + 15) 12 3 (Color 218 160 89) }
        1 { Draw-Outlined-Rect $G ($Ox + 6) ($Oy + 14) 20 10 (Color 178 128 73) $outline; Fill-Rect $G ($Ox + 9) ($Oy + 11) 5 6 (Color 235 211 143); Fill-Rect $G ($Ox + 17) ($Oy + 10) 5 7 (Color 235 211 143) }
        2 { Draw-Outlined-Rect $G ($Ox + 8) ($Oy + 12) 16 13 (Color 119 152 141) $outline; Fill-Ellipse $G ($Ox + 11) ($Oy + 9) 10 5 (Color 238 229 198) }
        3 { Draw-Outlined-Rect $G ($Ox + 7) ($Oy + 12) 18 13 (Color 129 87 60) $outline; Fill-Rect $G ($Ox + 9) ($Oy + 14) 14 4 (Color 232 187 108) }
        4 { Draw-Outlined-Rect $G ($Ox + 8) ($Oy + 11) 15 15 (Color 211 91 76) $outline; Fill-Rect $G ($Ox + 10) ($Oy + 13) 11 4 (Color 244 220 162) }
        5 { Draw-Outlined-Ellipse $G ($Ox + 7) ($Oy + 12) 18 13 (Color 234 164 79) $outline; Fill-Rect $G ($Ox + 11) ($Oy + 11) 10 3 (Color 251 226 147) }
        6 { Draw-Outlined-Rect $G ($Ox + 11) ($Oy + 9) 10 18 (Color 98 151 205) $outline; Fill-Rect $G ($Ox + 13) ($Oy + 11) 6 4 (Color 238 230 196) }
        7 { Draw-Outlined-Rect $G ($Ox + 7) ($Oy + 15) 18 9 (Color 224 202 149) $outline; Fill-Rect $G ($Ox + 10) ($Oy + 12) 12 5 (Color 145 104 66) }
    }
}

function Draw-Action-Loop([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [string] $Role, [string] $Action, [int] $Frame) {
    Draw-Character $G $Ox $Oy $Role 0 $Frame $Action
    $cx = $Ox + 24
    $outline = Color 45 32 28
    if ($Action -eq "tablet") {
        Draw-Outlined-Rect $G ($cx + 8) ($Oy + 21) 9 12 (Color 58 87 118) $outline
        Fill-Rect $G ($cx + 10) ($Oy + 23) 5 7 (Color 94 181 198)
        if ($Frame % 2 -eq 0) {
            Fill-Rect $G ($cx + 12) ($Oy + 19) 2 2 (Color 250 232 142)
        }
    } elseif ($Action -eq "sprinkle") {
        Draw-Outlined-Rect $G ($cx + 7) ($Oy + 18) 7 10 (Color 226 219 188) $outline
        for ($i = 0; $i -lt 3; $i++) {
            $x = $cx - 7 + (($Frame + $i) * 3 % 15)
            $y = $Oy + 28 + ($i * 2)
            Fill-Rect $G $x $y 2 2 (Color 251 226 120)
        }
    } elseif ($Action -eq "payment") {
        Draw-Outlined-Rect $G ($cx + 7) ($Oy + 24) 13 8 (Color 66 70 75) $outline
        Fill-Rect $G ($cx + 9) ($Oy + 26) 9 2 (Color 232 189 82)
        Fill-Rect $G ($cx - 14 + $Frame) ($Oy + 22) 8 5 (Color 241 224 176)
    } elseif ($Action -eq "mop_loop") {
        $swing = @(-5, -2, 1, 4, 1, -2)[$Frame % 6]
        Draw-Line $G ($cx + $swing) ($Oy + 17) ($cx + 14 - $swing) ($Oy + 40) $outline 3
        Draw-Line $G ($cx + $swing) ($Oy + 17) ($cx + 14 - $swing) ($Oy + 40) (Color 100 150 130) 1
        Fill-Rect $G ($cx + 10 - $swing) ($Oy + 39) 13 4 (Color 84 124 183)
        Fill-Rect $G ($cx - 12) ($Oy + 38) 8 5 (Color 121 172 191)
    } elseif ($Action -eq "impatient") {
        $tap = if ($Frame % 2 -eq 0) { 2 } else { -1 }
        Fill-Rect $G ($cx + 12) ($Oy + 6) 2 9 (Color 198 70 62)
        Fill-Rect $G ($cx + 12) ($Oy + 17) 2 2 (Color 198 70 62)
        Fill-Rect $G ($cx - 8) ($Oy + 42 + $tap) 8 2 (Color 48 35 30)
    }
}

$manifest = [ordered]@{
    batch = "animation_batch_02"
    style = "cozy top-down RPG pixel animation, transparent PNG, fixed Godot slicing cells, no frame separators"
    direction_order = @("south", "east", "north", "west")
    assets = @()
}

$sheet = New-Sheet 192 192
for ($row = 0; $row -lt 4; $row++) {
    for ($col = 0; $col -lt 4; $col++) {
        Draw-Character $sheet.Graphics ($col * 48) ($row * 48) "player" $row $col "walk"
    }
}
$path = Join-Path $OutDir "player_walk_4dir_4f_4x4.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "player_walk_4dir_4f_4x4.png"; frame_size = "48x48"; grid = "4x4"; hframes = 4; vframes = 4; rows = @("south", "east", "north", "west"); columns = @("step_0", "step_1", "step_2", "step_3") }

$sheet = New-Sheet 288 192
$roles = @("baker", "cashier", "runner", "cleaner")
$actions = @("idle", "knead", "cashier", "carry", "mop", "tired")
for ($row = 0; $row -lt $roles.Count; $row++) {
    for ($col = 0; $col -lt $actions.Count; $col++) {
        $action = $actions[$col]
        if ($roles[$row] -eq "baker" -and $col -in @(2, 4)) { $action = "knead" }
        if ($roles[$row] -eq "cashier" -and $col -in @(1, 2, 3)) { $action = "cashier" }
        if ($roles[$row] -eq "runner" -and $col -in @(1, 2, 3)) { $action = "carry" }
        if ($roles[$row] -eq "cleaner" -and $col -in @(1, 2, 4)) { $action = "mop" }
        if ($col -eq 5) { $action = "tired" }
        Draw-Character $sheet.Graphics ($col * 48) ($row * 48) $roles[$row] 0 $col $action
    }
}
$path = Join-Path $OutDir "worker_task_loops_6x4.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "worker_task_loops_6x4.png"; frame_size = "48x48"; grid = "6x4"; hframes = 6; vframes = 4; rows = $roles; columns = @("idle", "action_a", "action_b", "serve_or_carry", "work_loop", "tired") }

$sheet = New-Sheet 192 192
for ($row = 0; $row -lt 4; $row++) {
    for ($col = 0; $col -lt 4; $col++) {
        Draw-Character $sheet.Graphics ($col * 48) ($row * 48) "runner" $row $col "carry"
    }
}
$path = Join-Path $OutDir "runner_carry_walk_4dir_4f_4x4.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "runner_carry_walk_4dir_4f_4x4.png"; frame_size = "48x48"; grid = "4x4"; hframes = 4; vframes = 4; rows = @("south", "east", "north", "west"); columns = @("carry_step_0", "carry_step_1", "carry_step_2", "carry_step_3") }

$sheet = New-Sheet 384 96
for ($row = 0; $row -lt 2; $row++) {
    $role = if ($row -eq 0) { "regular" } else { "kid" }
    for ($col = 0; $col -lt 8; $col++) {
        Draw-Customer-Reaction $sheet.Graphics ($col * 48) ($row * 48) $role $col
    }
}
$path = Join-Path $OutDir "customer_reactions_8x2.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "customer_reactions_8x2.png"; frame_size = "48x48"; grid = "8x2"; hframes = 8; vframes = 2; rows = @("morning_regular", "sweet_tooth_kid"); columns = @("wait", "browse", "order", "pay", "happy", "impatient", "leave", "failed") }

$sheet = New-Sheet 256 32
for ($col = 0; $col -lt 8; $col++) {
    Draw-Carry-Overlay $sheet.Graphics ($col * 32) 0 $col
}
$path = Join-Path $OutDir "carry_item_overlays_8x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "carry_item_overlays_8x1.png"; frame_size = "32x32"; grid = "8x1"; hframes = 8; vframes = 1; columns = @("empty_crate", "full_crate", "mixing_bowl", "tray", "boxed_order", "bread_or_pastry", "drink", "wrapped_bundle") }

$singleLoops = @(
    @{ File = "player_use_tablet_6x1.png"; Role = "player"; Action = "tablet"; Columns = @("lift", "tap_0", "tap_1", "confirm", "lower", "idle") },
    @{ File = "baker_sprinkle_loop_6x1.png"; Role = "baker"; Action = "sprinkle"; Columns = @("ready", "shake_0", "shake_1", "falling", "finish", "idle") },
    @{ File = "cashier_payment_loop_6x1.png"; Role = "cashier"; Action = "payment"; Columns = @("wait", "card_in", "tap", "receipt", "bag", "done") },
    @{ File = "cleaner_mop_loop_6x1.png"; Role = "cleaner"; Action = "mop_loop"; Columns = @("left", "mid_left", "center", "right", "center_return", "mid_left_return") },
    @{ File = "customer_impatience_6x1.png"; Role = "regular"; Action = "impatient"; Columns = @("wait", "tap_0", "tap_1", "look", "warning", "settle") }
)

foreach ($loop in $singleLoops) {
    $sheet = New-Sheet 288 48
    for ($col = 0; $col -lt 6; $col++) {
        Draw-Action-Loop $sheet.Graphics ($col * 48) 0 $loop.Role $loop.Action $col
    }
    $path = Join-Path $OutDir $loop.File
    Save-Sheet $sheet $path
    $manifest.assets += [ordered]@{ file = $loop.File; frame_size = "48x48"; grid = "6x1"; hframes = 6; vframes = 1; columns = $loop.Columns }
}

$manifestPath = Join-Path $OutDir "animation_batch_02_manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Generated cozy RPG animation batch:"
Get-ChildItem -LiteralPath $OutDir -Filter "*.png" | Sort-Object Name | ForEach-Object {
    Write-Host (" - " + $_.FullName)
}
