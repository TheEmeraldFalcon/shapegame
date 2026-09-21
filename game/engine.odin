package game

import "core:fmt"
import "core:time"
import "core:math"

import "vendor:raylib"

import "../pixel_canvas"

PXCANVAS_W := 320
PXCANVAS_H := 240

MAX_DELTA_TIME :: 0.25

Engine_Properties :: struct {
	tick_rate : int
}

Engine_Components :: struct {
	canvas : pixel_canvas.Canvas
}

engine_run :: proc(props: Engine_Properties) {
	raylib.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	raylib.InitWindow(640, 480, "Odin Raylib Window")

	monitor := raylib.GetCurrentMonitor()

	fmt.println("Monitor W: ", raylib.GetMonitorWidth(monitor))
	fmt.println("Monitor H: ", raylib.GetMonitorHeight(monitor))
	fmt.println("Monitor Hz: ", raylib.GetMonitorRefreshRate(monitor))

	comps : Engine_Components
	comps.canvas = pixel_canvas.create_canvas(PXCANVAS_W, PXCANVAS_H, raylib.Color{20, 20, 20, 255})

	prev_time := time.tick_now()
	delta := 1.0 / f64(props.tick_rate)
	accumulator := 0.0
	num_ticks := 0
	
	frame_start_time := time.tick_now()

	frame_timer := time.tick_now()

	for !raylib.WindowShouldClose() {
		prev_time = frame_start_time
		frame_duration := f64(time.duration_seconds(time.tick_since(prev_time)))
		frame_start_time = time.tick_now()

		accumulator += frame_duration
		num_ticks = int(math.floor(accumulator / delta))
		accumulator -= f64(num_ticks) * delta

		for tick_index in 0..<num_ticks {
			engine_tick(&comps, delta, time.tick_since(frame_timer))
		}

		engine_frame(&comps, accumulator / delta, time.tick_since(frame_timer))
	}
	
	engine_shutdown(&comps)
}

engine_shutdown :: proc(comps : ^Engine_Components) {
	raylib.CloseWindow()

	fmt.println("engine_shutdown")
}

engine_tick :: proc(comps : ^Engine_Components, dt: f64, frame_timer: time.Duration) {
	fmt.println("engine_tick: ", dt)

	
}

engine_frame :: proc(comps : ^Engine_Components, alpha: f64, frame_timer: time.Duration) {
	fmt.println("engine_frame: ", alpha)

	monitor := raylib.GetCurrentMonitor()
	screen_w := raylib.GetScreenWidth()
	screen_h := raylib.GetScreenHeight()

	// TODO: Properly letterbox this if screen width < canvas width.
	comps.canvas.screen_scale = f32(screen_h) / f32(PXCANVAS_H)
	comps.canvas.screen_coords.x = f32(screen_w / 2.) - (f32(comps.canvas.width / 2.) * comps.canvas.screen_scale)

	offset := i32(math.round(math.sin_f32(f32(time.duration_seconds(frame_timer))) * 10.))

	e : pixel_canvas.Shape_Ellipse
	e.color = raylib.Color{20, 20, 20, 255} 
	e.position = pixel_canvas.Vector{130 + offset, 130}
	e.size = pixel_canvas.Vector{16, 16}
	e.outline.color = raylib.WHITE
	e.outline.width = 2

	es : [dynamic]pixel_canvas.Shape_Ellipse
	append(&es, e)

	raylib.BeginDrawing()
	raylib.ClearBackground(raylib.BLACK)

	pixel_canvas.start_frame(&comps.canvas)

	pixel_canvas.draw_ellipses(&comps.canvas, es)

	pixel_canvas.present_frame(&comps.canvas)

	raylib.EndDrawing()
}
