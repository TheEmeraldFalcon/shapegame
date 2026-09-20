package game

import "core:time"

EngineProperties :: struct {
	quit : bool
		
	tick_rate : int
}

engine_run :: proc(props: EngineProperties) {
	tick_delta := 1.0 / f64(props.tick_rate)
	accumulator := 0.0
	num_ticks = 0
	
	frame_start_time := time.tick_now()

	for !quit {
		prev_time = frame_start_time
		frame_duration := f64(time.duration_seconds(time.tick_since(prev_time)))
		frame_start_time = time.tick_now()

		accumulator += frame_duration
		num_ticks = int(floor(accumulator / tick_delta))
		accumulator -= f64(num_ticks) * tick_delta

		for tick_index in 0..<num_ticks {
			engine_tick(tick_delta)
		}
	}
	
	engine_shutdown()
}

engine_shutdown :: proc() {
	
}

engine_tick :: proc(dt: f64) {
	
}

engine_frame :: proc(dt: f64) {
	
}

engine_draw :: proc(alpha: f64) {
	
}
