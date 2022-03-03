/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Dropzone                                                         */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

// Global settings
Dropzone.autoDiscover = false;
		
function RugFormDropzone(hash, options)
{
	this.hash = hash;
	this.dropzone = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}
RugFormDropzone.prototype = {
	constructor: RugFormDropzone,
	addFile: function(fileName, fileSize, thumbUrl)
	{
		var mockFile = { name: fileName, size: fileSize };
		this.dropzone.emit('addedfile', mockFile);
		this.dropzone.emit('thumbnail', mockFile, thumbUrl);
		this.dropzone.files.push(mockFile);
		this.dropzone.emit('complete', mockFile);
		this.dropzone.options.maxFiles = this.dropzone.options.maxFiles - 1;
	},
	ready: function()
	{
		var _this = this;

		// Dropzone	
		this.dropzone = new Dropzone('div#' + this.options.id, {
			url: this.options.defaultUrl,
			method: this.options.defaultMethod, /* method given by function not working, that's why we do it by changing static options in success event */
			paramName: this.options.objectParamKey + '[' + this.options.name + ']',
			maxFiles: 1,
			dictDefaultMessage: this.options.defaultMessage,
			dictRemoveFile: this.options.removeFileMessage,
			dictCancelUpload: this.options.cancelUploadMessage,
			dictCancelUploadConfirmation: this.options.cancelUploadConfirmationMessage,
			addRemoveLinks: (this.options.removeUrl ? true : false),
		});

		// Events
		this.dropzone.on('sending', function(file, xhr, data) {
			data.append('authenticity_token', _this.options.formAuthenticityToken);
			if (_this.options.appendColumns) {
				for (appendColumn in _this.options.appendColumns) {
					var asColumn = _this.options.appendColumns[appendColumn];
					data.append(_this.options.objectParamKey + '[' + asColumn + ']', $('#' + _this.options.objectParamKey + '_' + appendColumn).val());
				}
			}
		});
		this.dropzone.on('maxfilesexceeded', function(file) {
			this.options.maxFiles = 1;
			this.removeAllFiles(true);
			this.addFile(file);
		});
		this.dropzone.on('success', function(file, response) {
			_this.options.objectId = parseInt(response);
			if (!isNaN(_this.options.objectId)) {
				var form = $(_this.options.formSelector);
				var updateUrl = _this.options.updateUrl.replace(':id', _this.options.objectId);
				if (form.attr('action') != updateUrl) {
					form.attr('action', updateUrl); /* Form */
					form.prepend('<input type="hidden" name="_method" value="patch" />');
				}
				this.options.url = updateUrl; /* Dropzone - this causes that only one dropzone is supported for creating */
				this.options.method = 'put';
				if (_this.options.reloadObject) {
					var showUrl = updateUrl; /* Update URL is similar to show URL (it differs in method) */
					$.get(showUrl, function(callback) {
						if (callback && callback[_this.options.name + "_url"]) {
							var src = callback[_this.options.name + "_url"];
							eval('var object = ' + _this.options.reloadObject + ';');
							object.reload(src);
						}
					}, 'json');
				}
			} else { /* Error saving image */ 
			}
		});
		this.dropzone.on('removedfile', function(file) {
			var removeUrl = _this.options.removeUrl.replace(':id', _this.options.objectId);
			if (removeUrl) {
				$.ajax({
					url: removeUrl,
					dataType: 'json',
					type: 'put'
				});
			}
		});
	}
}