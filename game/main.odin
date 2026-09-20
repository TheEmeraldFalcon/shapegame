package game

import "core:fmt"
import "vendor:raylib"

main :: proc() {
	raylib.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	raylib.InitWindow(640, 480, "Odin Raylib Window")

	monitor := raylib.GetCurrentMonitor()

	fmt.println("Monitor W: ", raylib.GetMonitorWidth(monitor))
	fmt.println("Monitor H: ", raylib.GetMonitorHeight(monitor))
	fmt.println("Monitor Hz: ", raylib.GetMonitorRefreshRate(monitor))

	for !raylib.WindowShouldClose() {
		raylib.BeginDrawing()

		raylib.ClearBackground(raylib.RED)
		raylib.DrawText("Amon Gus", 200, 200, 48, raylib.WHITE)

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
