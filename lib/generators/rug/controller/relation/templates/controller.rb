# *****************************************************************************
# * Copyright (c) Clockstar s.r.o. All rights reserved.
# *****************************************************************************
# *
# * <%= controller_name.gsub("_", " ").capitalize %>
# *
# * Author: 
# * Date  : <%= Date.today.strftime("%-d. %-m. %Y") %>
# *
# *****************************************************************************

class <%= controller_path.to_camel %>Controller < ApplicationController

	before_action :set_<%= model_1_name.to_snake.singularize %>, only: [:edit, :update, :destroy]
	before_action :set_<%= model_2_name.to_snake.singularize %>, only: [:destroy]

	#
	# Edit action
	#
	def edit
		@<%= model_2_name.to_snake.pluralize %> = <%= model_2_path.to_camel.singularize %>.all.order(id: :asc)
	end

	#
	# Update action
	#
	def update
		@<%= model_1_name.to_snake.singularize %>.<%= model_2_name.to_snake.singularize %>_ids = <%= model_2_name.to_snake.singularize %>_ids_from_params
		redirect_to main_app.<%= model_1_controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_1_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_1_name.to_snake.singularize %>.bind_<%= model_2_name.to_snake.singularize %>")
	end

	#
	# Destroy action
	#
	def destroy
		@<%= model_1_name.to_snake.singularize %>.<%= model_2_name.to_snake.pluralize %>.delete(@<%= model_2_name.to_snake.singularize %>)
		redirect_to main_app.<%= model_1_controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_1_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_1_name.to_snake.singularize %>.unbind_<%= model_2_name.to_snake.singularize %>")
	end

protected

	def set_<%= model_1_name.to_snake.singularize %>
		@<%= model_1_name.to_snake.singularize %> = <%= model_1_path.to_camel.singularize %>.find_by_id(params[:id])
		if @<%= model_1_name.to_snake.singularize %>.nil?
			redirect_to root_path, alert: I18n.t("activerecord.errors.models.<%= model_1_name.to_snake.singularize %>.not_found")
		end
	end

	def set_<%= model_2_name.to_snake.singularize %>
		@<%= model_2_name.to_snake.singularize %> = <%= model_2_path.to_camel.singularize %>.find_by_id(params[:<%= model_2_name.to_snake.singularize %>_id])
		if @<%= model_2_name.to_snake.singularize %>.nil?
			redirect_to root_path, alert: I18n.t("activerecord.errors.models.<%= model_2_name.to_snake.singularize %>.not_found")
		end
	end

	# 
	# Never trust parameters from the scary internet, only allow the white list through.
	#
	def <%= model_2_name.to_snake.singularize %>_ids_from_params
		if params[:<%= model_1_name.to_snake.singularize %>] && params[:<%= model_1_name.to_snake.singularize %>][:<%= model_2_name.to_snake.pluralize %>] && params[:<%= model_1_name.to_snake.singularize %>][:<%= model_2_name.to_snake.pluralize %>].is_a?(Hash)
			return params[:<%= model_1_name.to_snake.singularize %>][:<%= model_2_name.to_snake.pluralize %>].keys
		else
			return []
		end
	end

end
