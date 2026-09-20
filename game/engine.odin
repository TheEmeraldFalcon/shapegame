package game

EngineProperties :: struct {
	quit : bool
		
	tick_rate : int
}

engine_run :: proc() {
	for !quit {
		
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
