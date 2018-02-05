/*****************************************************************************/
/* Copyright (c) Clockstar s.r.o. All rights reserved.                       */
/*****************************************************************************/
/*                                                                           */
/* Rug Form Dropzone Many                                                    */
/*                                                                           */
/* Author: Matěj Outlý                                                       */
/* Date  : 9. 3. 2017                                                        */
/*                                                                           */
/*****************************************************************************/

// Global settings
Dropzone.autoDiscover = false;
		
function RugDropzoneMany(hash, options)
{
	this.hash = hash;
	this.dropzone = null;
	this.options = (typeof options !== 'undefined' ? options : {});
}
RugDropzoneMany.prototype = {
	constructor: RugDropzoneMany,
	addFile: function(fileName, fileSize, thumbUrl, recordId)
	{
		var mockFile = { name: fileName, size: fileSize, record_id: recordId };
		this.dropzone.emit('addedfile', mockFile);
		this.dropzone.emit('thumbnail', mockFile, thumbUrl);
		this.dropzone.files.push(mockFile);
		this.dropzone.emit('complete', mockFile);
	},
	ready: function()
	{
		var _this = this;
		
		// Dropzone init
		this.dropzone = new Dropzone('div#' + this.options.id, {
			url: this.options.createUrl,
			method: 'post',
			paramName: this.options.collectionParamKey + '[' + this.options.attachmentName + ']',
			addRemoveLinks: true,
			dictDefaultMessage: this.options.defaultMessage,
			dictRemoveFile: this.options.removeFileMessage,
			dictCancelUpload: this.options.cancelUploadMessage,
			dictCancelUploadConfirmation: this.options.cancelUploadConfirmationMessage,
		});

		// Events
		this.dropzone.on('sending', function(file, xhr, data) {
			data.append('authenticity_token', _this.options.formAuthenticityToken);
			if (_this.options.appendColumns) {
				for (appendColumn in _this.options.appendColumns) {
					var asColumn = _this.options.appendColumns[appendColumn];
					data.append(_this.options.collectionParamKey + '[' + asColumn + ']', $('#' + _this.options.objectParamKey + '_' + appendColumn).val());
				}
			}
		});
		this.dropzone.on('success', function(file, response) {
			var responseId = parseInt(response);
			if (!isNaN(responseId)) {
				file.record_id = responseId;
				if (_this.options.reloadObjects && _this.options.reloadObjects.length > 0) {
					_this.dropzone.removeFile(file);
					_this.options.reloadObjects.forEach(function(item) {
						eval('var object = ' + item + ';');
						object.reload(responseId);
					});
				}
			} else { /* Error saving image */
			}
		});
		if (!this.options.reloadObjects || this.options.reloadObjects.length == 0) {
			this.dropzone.on('removedfile', function(file) {
				if (file.record_id) {
					var destroyUrl = _this.options.destroyUrl.replace(':id', file.record_id);
					$.ajax({
						url: destroyUrl,
						dataType: 'json',
						type: 'DELETE'
					});
				}
			});
		}
		
	}
}