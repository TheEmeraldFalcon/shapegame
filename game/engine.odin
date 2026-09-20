package game

import "core:fmt"
import "core:time"
import "core:math"

import "vendor:raylib"

MAX_DELTA_TIME :: 0.25

EngineProperties :: struct {
	tick_rate : int
}

engine_run :: proc(props: EngineProperties) {
	prev_time := time.tick_now()
	delta := 1.0 / f64(props.tick_rate)
	accumulator := 0.0
	num_ticks := 0
	
	frame_start_time := time.tick_now()

	raylib.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	raylib.InitWindow(640, 480, "Odin Raylib Window")

	monitor := raylib.GetCurrentMonitor()

	fmt.println("Monitor W: ", raylib.GetMonitorWidth(monitor))
	fmt.println("Monitor H: ", raylib.GetMonitorHeight(monitor))
	fmt.println("Monitor Hz: ", raylib.GetMonitorRefreshRate(monitor))

	for !raylib.WindowShouldClose() {
		prev_time = frame_start_time
		frame_duration := f64(time.duration_seconds(time.tick_since(prev_time)))
		frame_start_time = time.tick_now()

		accumulator += frame_duration
		num_ticks = int(math.floor(accumulator / delta))
		accumulator -= f64(num_ticks) * delta

		for tick_index in 0..<num_ticks {
			engine_tick(delta)
		}

		engine_frame(accumulator / delta)
	}
	
	engine_shutdown()
}

engine_shutdown :: proc() {
	raylib.CloseWindow()

	fmt.println("engine_shutdown")
}

engine_tick :: proc(dt: f64) {
	fmt.println("engine_tick: ", dt)
}

engine_frame :: proc(alpha: f64) {
	fmt.println("engine_frame: ", alpha)

	canvas := raylib.GenImageColor(360, 240, raylib.BLACK)

	raylib.ImageDrawCircle(&canvas, 140, 60, 24, raylib.WHITE)
	raylib.ImageDrawCircle(&canvas, 140, 60, 20, raylib.BLACK)

	texture := raylib.LoadTextureFromImage(canvas)


	raylib.BeginDrawing()

	raylib.ClearBackground(raylib.RED)
	raylib.DrawText("Amon Gus", 200, 200, 48, raylib.WHITE)

	raylib.DrawTextureEx(texture, raylib.Vector2{0., 0.}, 0.0, 4.0, raylib.WHITE)

	raylib.EndDrawing()
}
