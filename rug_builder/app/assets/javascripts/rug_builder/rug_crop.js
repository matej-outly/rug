/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Crop                                                                  */
/*                                                                           */
/* Author:                                                                   */
/* Date  : 4. 4. 2017                                                        */
/*                                                                           */
/*****************************************************************************/


function RugCrop(hash, options)
{
	this.hash = hash;
	this.$crop = null;
	this.$cropX = null;
	this.$cropY = null;
	this.$cropW = null;
	this.$cropH = null;

	this.options = $.extend({
		aspectRatio: null,
		initial: null,
	}, options);
}
RugCrop.prototype = {
	constructor: RugCrop,

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
	// Reload plugin
	//
	reload: function()
	{
		console.log("RugCrop::reload not implemented");
	},

	//
	// Initialize
	//
	ready: function()
	{
		this.$crop = $('#crop_' + this.hash + ' .cropbox img');
		this.$cropX = $('#crop_' + this.hash + ' .crop_x');
		this.$cropY = $('#crop_' + this.hash + ' .crop_y');
		this.$cropW = $('#crop_' + this.hash + ' .crop_w');
		this.$cropH = $('#crop_' + this.hash + ' .crop_h');

		this.$crop.croppable({
			aspectRatio: this.options.aspectRatio,
			initial: this.options.initial,
			cropUpdated: this.onCropUpdate.bind(this),
		});
	},
}
