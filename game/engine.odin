package game

import "core:fmt"
import "core:time"
import "core:math"

import "vendor:raylib"

import "../pixel_canvas"

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
	comps.canvas = pixel_canvas.create_canvas(320, 240, raylib.BLACK)

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

	offset := i32(math.round(math.sin_f32(f32(time.duration_seconds(frame_timer))) * 10.))

	e : pixel_canvas.Shape_Ellipse
	e.color = raylib.GREEN
	e.position = pixel_canvas.Vector{130 + offset, 130}
	e.size = pixel_canvas.Vector{50, 70}
	e.outline.color = raylib.DARKGREEN
	e.outline.width = 32

	es : [dynamic]pixel_canvas.Shape_Ellipse
	append(&es, e)

//	l : pixel_canvas.Shape_Line
//	l.color = raylib.GREEN
//	l.point1 = pixel_canvas.Vector{100, 100}
//	l.point2 = pixel_canvas.Vector{340, 470}
//	l.width = 64
//	l.outline.color = raylib.DARKGREEN
//	l.outline.width = 32
//
//	ls : [dynamic]pixel_canvas.Shape_Line
//	append(&ls, l)

	raylib.BeginDrawing()
	raylib.ClearBackground(raylib.WHITE)

	pixel_canvas.start_frame(&comps.canvas)

	pixel_canvas.draw_ellipses(&comps.canvas, es)

	pixel_canvas.present_frame(&comps.canvas)

	raylib.EndDrawing()
}
