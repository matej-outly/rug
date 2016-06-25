/**
 * Init slidebars
 */
function slidebars_ready()
{
	var controller = new slidebars();
	controller.init();

	// Toggles
}

/**
 * Hook
 */
$(document).ready(slidebars_ready);
$(document).on("page:load", slidebars_ready);