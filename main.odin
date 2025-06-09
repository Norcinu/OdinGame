package main

import rl "vendor:raylib"
import "core:fmt"
import "core:strconv"
import "core:strings"


flip_through_colour_text := true
last_colour_change_time: f64 = 0.0 // Add this at the top-level (global scope)
increment_gap := 1 //change colour every 5 seconds
current_colour_idx := 0
colour_list := [26]rl.Color{
    rl.LIGHTGRAY,
    rl.GRAY, 
    rl.DARKGRAY,
    rl.YELLOW,  
    rl.GOLD,    
    rl.ORANGE,
    rl.PINK,       
    rl.RED,      
    rl.MAROON,
    rl.GREEN,    
    rl.LIME,     
    rl.DARKGREEN,
    rl.SKYBLUE, 
    rl.BLUE,   
    rl.DARKBLUE,
    rl.PURPLE,  
    rl.VIOLET,    
    rl.DARKPURPLE,
    rl.BEIGE,
    rl.BROWN,     
    rl.DARKBROWN,
    rl.WHITE, 
    rl.BLACK,     
    rl.BLANK,     
    rl.MAGENTA,
    rl.RAYWHITE   
}

screen_resolution_idx: i32 = 0
screen_resolutions: [5]rl.Vector2 = {
    rl.Vector2{640,  480},
    rl.Vector2{800,  600},
    rl.Vector2{1024, 768},
    rl.Vector2{1280, 720},
    rl.Vector2{1920, 1080},
}

Input_Type :: enum {
    None,
    StopColourChange,
    ChangeScreenRes,
}


main :: proc() {
    
    person: Player = Player{
        name = "Steve",
        age = 42,
        score = 0,
    }   

    SCREEN_HEIGHT :: 720
    SCREEN_WIDTH :: 1280

   // screen_resolution_idx: i32 = 0
    
    text_start_pos_x: i32 = SCREEN_WIDTH / 2
    text_start_pos_y: i32 = SCREEN_HEIGHT / 2
    font_size: f32 = 20.00
    spacing: f32 = 1.00
    screen_message: cstring = "Hello my name is Steven."

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window");

    last_colour_change_time = rl.GetTime()

    font := rl.GetFontDefault()
    size: rl.Vector2 = rl.MeasureTextEx(font, screen_message, font_size, spacing)

    fmt.println("Vector dimensions")
    fmt.println("x = ", size.x, ": y = ", size.y)
    fmt.println("x = ", text_start_pos_x, ": y = ", text_start_pos_y)

    for i in 0 ..< rl.GetMonitorCount() {
        fmt.println("Monitor ", i, " : ", rl.GetMonitorName(i))
        fmt.println("Monitor ", i, " : ", rl.GetMonitorWidth(i), " x ", rl.GetMonitorHeight(i))
        fmt.println("Monitor ", i, " : ", rl.GetMonitorRefreshRate(i))
    }

    rl.SetTargetFPS(rl.GetMonitorRefreshRate(0))
    rl.ClearBackground(rl.RAYWHITE)

    text_colour: rl.Color = rl.DARKGRAY

    image: rl.Image = rl.LoadImage("assets/png/face.png")
    loaded_texture: rl.Texture2D = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)

    texture_position: rl.Vector2 = rl.Vector2{ }
    texture_position.x = 20.0
    texture_position.y = f32(SCREEN_HEIGHT / 2 - loaded_texture.height / 2)

    outer_bounds: rl.Rectangle = rl.Rectangle{
        x = 0.0,
        y = 0.0,
        width = f32(SCREEN_WIDTH) - f32(loaded_texture.width),
        height = f32(SCREEN_HEIGHT) - f32(loaded_texture.height)
    }

    user_input: Input_Type = .None

    for !rl.WindowShouldClose() {

        user_input = check_user_input(&texture_position, outer_bounds)

        #partial switch user_input {
            case .ChangeScreenRes:
                screen_resolution_idx = (screen_resolution_idx + 1) % len(screen_resolutions)
                rl.SetWindowSize(i32(screen_resolutions[screen_resolution_idx].x), i32(screen_resolutions[screen_resolution_idx].y))

                
                //reposition stuff on screen
                //reposition window
        }

        rl.BeginDrawing()
        
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawTexture(loaded_texture, i32(texture_position.x), i32(texture_position.y), rl.WHITE)

        manage_steve_text(screen_message, text_start_pos_x, text_start_pos_y, size, spacing)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}

check_user_input :: proc(texture_position: ^rl.Vector2, outer_bounds: rl.Rectangle) -> Input_Type {

    ret := Input_Type.None

    if rl.IsKeyPressed(.UP) || rl.IsKeyDown(.UP){
        if (texture_position.y - 10) < 0 {
            texture_position.y = 0
        } else {
            texture_position.y -= 10
        }
    } 
    
    if rl.IsKeyPressed(.DOWN) || rl.IsKeyDown(.DOWN) {
        if (texture_position.y + 10) > outer_bounds.height {
            texture_position.y = outer_bounds.height
        } else {
            texture_position.y += 10
        }
    }

    if rl.IsKeyPressed(.LEFT) || rl.IsKeyDown(.LEFT) {
        if (texture_position.x - 10) < 0 {
            texture_position.x = 0
        } else {
            texture_position.x -= 10
        }
    }
    
    if rl.IsKeyPressed(.RIGHT) || rl.IsKeyDown(.RIGHT) {
        if (texture_position.x + 10) > outer_bounds.width {
            texture_position.x = outer_bounds.width
        } else {
            texture_position.x += 10
        }
    }

    if (rl.IsKeyPressed(.T)) {
        fmt.println("T key pressed")
        flip_through_colour_text = !flip_through_colour_text
        ret = Input_Type.StopColourChange
    }

    if (rl.IsKeyPressed(.ONE)) {
       ret = Input_Type.ChangeScreenRes
    }

    return ret
}

manage_steve_text :: proc(screen_message:cstring, text_start_pos_x:i32, text_start_pos_y:i32, size:rl.Vector2, spacing:f32) {
    fps := rl.GetFPS()
    text_colour := rl.DARKGRAY

    rl.DrawText(fmt.ctprint("fps: ", fps), 10,20, 20, rl.DARKPURPLE)


    now := rl.GetTime()
    if now - last_colour_change_time >= f64(increment_gap) && flip_through_colour_text {
        current_colour_idx = (current_colour_idx + 1) % len(colour_list)
        last_colour_change_time = now
    }

    rl.DrawText(screen_message, text_start_pos_x - i32(size.x/2), text_start_pos_y - i32(size.y/2), 20, colour_list[current_colour_idx])   
}
