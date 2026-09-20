package game

import "core:fmt"
import "vendor:raylib"

main :: proc() {
	props := Engine_Properties{ 30 }
	engine_run(props)
}
