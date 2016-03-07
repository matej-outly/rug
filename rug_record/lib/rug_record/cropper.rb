# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Paperclip cropper, based on http://railscasts.com/episodes/182-cropping-images
# *
# * Author: Matěj Outlý
# * Date  : 9. 3. 2015
# *
# *****************************************************************************

module Paperclip
	class Cropper < Thumbnail
		
		#
		# Modify command accordingly
		#
		def transformation_command
			if perform_cropping?
				command = super
				
				crop_index = command.index("-crop")
				if !crop_index.nil?
					
					# Replace crop command
					command[crop_index + 1] = crop_command

					resize_index = command.index("-resize")
					if !resize_index.nil?
						
						# Place after crop
						command = command.insert(crop_index + 2, command[resize_index + 1])
						command = command.insert(crop_index + 2, "-resize")

						# Delete from its original position
						if resize_index < crop_index
							command.delete_at(resize_index)
							command.delete_at(resize_index)
						else
							command.delete_at(resize_index + 2)
							command.delete_at(resize_index + 2)
						end

					end
				end

				return command
			else
				super
			end
		end

	private 

		#
		# Is the picture currently cropped?
		#
		def perform_cropping?
			name = attachment.name
			instance = attachment.instance
			return instance.send("#{name.to_s}_perform_cropping?".to_sym)
		end

		#
		# Create crop command
		#
		def crop_command
			name = attachment.name
			instance = attachment.instance
			
			# Get correction ratio in case croppable style dimensions are different from original dimensions
			ratio = (instance.send("#{name.to_s}_geometry", :original).width.to_f / instance.send("#{name.to_s}_geometry", instance.send("#{name.to_s}_croppable_style".to_sym)).width.to_f).round(2)

			# Get command values
			crop_x = (instance.send("#{name.to_s}_crop_x".to_sym).to_i.to_f * ratio).to_i
			crop_y = (instance.send("#{name.to_s}_crop_y".to_sym).to_i.to_f * ratio).to_i
			crop_w = (instance.send("#{name.to_s}_crop_w".to_sym).to_i.to_f * ratio).to_i
			crop_h = (instance.send("#{name.to_s}_crop_h".to_sym).to_i.to_f * ratio).to_i

			return "\"#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}\""
		end
	end
end