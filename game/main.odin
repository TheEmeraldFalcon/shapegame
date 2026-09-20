package game

import "core:fmt"
import "vendor:raylib"

main :: proc() {
	props := EngineProperties{ 30 }
	engine_run(props)
}
