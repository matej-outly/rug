/**
 * Init TinyMCE 
 */
function tinymce_ready()
{
	tinyMCE.baseURL = "/assets/tinymce/";
	tinymce.init({
		
		/**
		 * Basic setting
		 */
		selector: "textarea.tinymce", /* TinyMCE is applied to all textareas with class .tinymce */
		theme: "modern", /* Theme of the editor */
		height: 350, /* Editor height */
		language : "cs", /* Editor language */
		fix_list_elements : true, /* Fix nested ul/ol elements */
		paste_as_text: true, /* Paste as text set as default */
		paste_word_valid_elements: "b,strong,i,em,h1,h2,h3", /* Paste form word cleanup */
		content_css: ["/assets/gumby/css/gumby.css", "/assets/libraries/tinymce.css"],
		entity_encoding : "raw", /* All characters will be stored in non-entity form except &amp; &lt; &gt; &quot; */
		relative_urls: false, /* Don't convert URLs to relative paths */
		image_list: "/admin/website/text_attachments/images",
		link_list: "/admin/website/text_attachments/links",

		/**
		 * Plugins:
		 * - fullscreen - switch to fullscreen
		 * - paste - remove formating in text pasted from clipboard
		 * - charmap - instert some special character
		 * - code - switch to HTML editation mode
		 * - hr - insert a horizontal line
		 * - image - insert a picture
		 * - link - insert a link
		 * - nonbreaking - instert &nbsp;
		 * - searchreplace - tool for find/replace text
		 * - table - insert and edit a table
		 * - visualblocks - display non-visible blocks - p, div, span, ...
		 * - visualchars - display non-visible characters
		 */
		plugins: "fullscreen paste charmap codemirror hr image link nonbreaking searchreplace table visualblocks visualchars",
		
		/**
		 * Toolbar
		 */
		toolbar: "undo redo | styleselect | link image | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist indent outdent | fullscreen code",

		/**
		 * Codemirror
		 */
		codemirror: {
			indentOnInit: true, /* Whether or not to indent code on init. */
			path: 'codemirror-4.8', /* Path to CodeMirror distribution */
			config: { /* CodeMirror config object */
			}
		}

	});
}

/**
 * Hook
 */
$(document).ready(tinymce_ready);