/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Crop                                                             */
/*                                                                           */
/* Author:                                                                   */
/* Date  : 4. 4. 2017                                                        */
/*                                                                           */
/*****************************************************************************/


function RugFormCrop(hash, options)
{
	this.hash = hash;
	this.$cropBox = null;
	this.$cropImg = null;
	this.$cropX = null;
	this.$cropY = null;
	this.$cropW = null;
	this.$cropH = null;

	this.options = $.extend({
		aspectRatio: null,
		initial: null,
	}, options);
}
RugFormCrop.prototype = {
	constructor: RugFormCrop,

	//
	// Cropped area has been changed
	//
	onCropUpdate: function(coords)
	{
		this.$cropX.val(coords.x);
		this.$cropY.val(coords.y);
		this.$cropW.val(coords.width);
		this.$cropH.val(coords.height);
	},

	//
	// Reload plugin with different image src
	//
	reload: function(src)
	{
		// Replace original src with croppable style (Paperclip dependency)
		src = src.replace('/original/', '/' + this.options.croppableStyle + '/');

		// New image and plugin reload
		this.$cropBox.html('<img src="' + src + '" />');
		this.options.initial = null;
		this.ready();
	},

	//
	// Initialize
	//
	ready: function()
	{
		this.$cropBox = $('#crop_' + this.hash + ' .cropbox');
		this.$cropImg = $('#crop_' + this.hash + ' .cropbox img');
		this.$cropX   = $('#crop_' + this.hash + ' .crop_x');
		this.$cropY   = $('#crop_' + this.hash + ' .crop_y');
		this.$cropW   = $('#crop_' + this.hash + ' .crop_w');
		this.$cropH   = $('#crop_' + this.hash + ' .crop_h');

		this.$cropImg.croppable({
			aspectRatio: this.options.aspectRatio,
			initial: this.options.initial,
			cropUpdated: this.onCropUpdate.bind(this),
		});
	},
}
