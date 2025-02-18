window.addEventListener("message", function(event) {
    if (event.data.type === "update") {
        document.getElementById("plate-text").textContent = event.data.plate;
        document.getElementById("km-text").textContent = event.data.km;
    }
    if (event.data.type === "toggle") {
        document.getElementById("hud-container").style.display = event.data.display ? "block" : "none";
    }
});
