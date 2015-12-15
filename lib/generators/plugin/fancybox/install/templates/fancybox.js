/**
 * Init Fancybox 
 */
function fancybox_ready()
{
	/* Fancybox */
	$(".fancybox").fancybox({
		openEffect	: 'none',
		closeEffect	: 'none'
	});
}

/**
 * Hook
 */
$(document).ready(fancybox_ready);
$(document).on("page:load", fancybox_ready);