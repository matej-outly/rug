# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * Picture definition
# *
# * Author: Matěj Outlý
# * Date  : 17. 8. 2015
# *
# *****************************************************************************

require "active_record"
require "rug_record/concerns/type/picture/cropper"

module RugRecord
	module Concerns
		module Type
			module Picture extend ActiveSupport::Concern

				module ClassMethods
					
					#
					# Add new picture column
					#
					def picture_column(new_column, options = {})
						
						# Define attachment
						has_attached_file new_column.to_sym, styles: options[:styles]
						validates_attachment_content_type new_column.to_sym, content_type: /\Aimage\/.*\Z/

					end

					#
					# Add new croppable picture column
					#
					def croppable_picture_column(new_column, options = {})
						
						# Check styles
						if !options[:styles]
							raise "Please define attachment styles."
						end

						# Prepare cropped style
						if options[:cropped_style]
							cropped_style = options[:cropped_style]
						else
							cropped_style = nil
							options[:styles].each do |style, style_geometry|
								if style_geometry.end_with?("#")
									cropped_style = style
									break
								end
							end
							if cropped_style.nil?
								raise "Unable to resolve cropped style. Please define style with ...x...# geometry or set :cropped_style option."
							end
						end

						# Prepare croppable style
						if options[:croppable_style]
							croppable_style = options[:croppable_style]
						else
							croppable_style = nil
							options[:styles].each do |style, style_geometry|
								if style_geometry.end_with?(">")
									croppable_style = style
									break
								end
							end
							croppable_style = :original if croppable_style.nil?
						end

						# Define attachment
						has_attached_file new_column.to_sym, styles: options[:styles], processors: [ :cropper ]
						validates_attachment_content_type new_column.to_sym, content_type: /\Aimage\/.*\Z/

						# Cropped styles method
						define_method("#{new_column.to_s}_cropped_style".to_sym) do
							return cropped_style
						end

						# Croppable styles method
						define_method("#{new_column.to_s}_croppable_style".to_sym) do
							return croppable_style
						end

						# Geometry method
						define_method("#{new_column.to_s}_geometry".to_sym) do |style = :original|
							@paperclip_geometry ||= {}
							@paperclip_geometry[new_column.to_sym] ||= {}
							@paperclip_geometry[new_column.to_sym][style] ||= Paperclip::Geometry.from_file(self.send(new_column.to_sym).path(style))
						end

						# URL method
						define_method("#{new_column.to_s}_url".to_sym) do
							value = self.send(new_column.to_sym)
							if value && value.present?
								return self.send(new_column.to_sym).url
							else
								return nil
							end
						end

						# Reprocess method
						define_method("#{new_column.to_s}_reprocess".to_sym) do
							self.send(new_column.to_sym).assign(self.send(new_column.to_sym))
							self.send(new_column.to_sym).save
						end

						# Bind after update event
						after_update("#{new_column.to_s}_reprocess".to_sym, :if => "#{new_column.to_s}_perform_cropping?".to_sym)

						# Define virtual crop attributes if needed => specify crop dimensions
						x_attribute = "#{new_column.to_s}_crop_x".to_sym
						attr_accessor x_attribute if !column_names.include?(x_attribute.to_s)
						y_attribute = "#{new_column.to_s}_crop_y".to_sym
						attr_accessor y_attribute if !column_names.include?(y_attribute.to_s)
						w_attribute = "#{new_column.to_s}_crop_w".to_sym
						attr_accessor w_attribute if !column_names.include?(w_attribute.to_s)
						h_attribute = "#{new_column.to_s}_crop_h".to_sym
						attr_accessor h_attribute if !column_names.include?(h_attribute.to_s)

						# Already cropped method
						define_method("#{new_column.to_s}_already_cropped?".to_sym) do
							return !self.send(x_attribute).blank? && !self.send(y_attribute).blank? && !self.send(w_attribute).blank? && !self.send(h_attribute).blank?
						end

						# Define virtual cropping attribute => specifi if cropping performed
						perform_cropping_attribute = "#{new_column.to_s}_perform_cropping".to_sym
						attr_accessor perform_cropping_attribute

						# Perform cropping method
						define_method("#{new_column.to_s}_perform_cropping?".to_sym) do
							return !self.send(perform_cropping_attribute).blank?
						end

					end

				end

			end
		end
	end
end

ActiveRecord::Base.send(:include, RugRecord::Concerns::Type::Picture)
