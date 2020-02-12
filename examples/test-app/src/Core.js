exports["setScreen"] = function(screen) {
    return function() {
        window.__dui_screen = screen
    }
}