/**
 * Init sidr 
 */
function sidr_ready()
{
	$(".sidr-toggle-left").sidr({
		name: "sidr-left",
		side: "left"
	});
	$(".sidr-toggle-right").sidr({
		name: "sidr-right",
		side: "right"
	});
}

/**
 * Hook
 */
$(document).ready(sidr_ready);
$(document).on("page:load", sidr_ready);