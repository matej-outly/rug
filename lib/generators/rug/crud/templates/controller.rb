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

	before_action :set_<%= model_name.to_snake.singularize %>, only: [:show, :edit, :update, :destroy]

	#
	# Index action
	#
	def index
		@<%= model_name.to_snake.pluralize %> = <%= model_path.to_camel.singularize %>.all.order(id: :asc)
	end

	#
	# Show action
	#
	def show
	end

	#
	# New action
	#
	def new
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.new
	end

	#
	# Edit action
	#
	def edit
	end

	#
	# Create action
	#
	def create
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.new(<%= model_name.to_snake.singularize %>_params)
		if @<%= model_name.to_snake.singularize %>.save
			redirect_to <%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.create")
		else
			render "new"
		end
	end

	#
	# Update action
	#
	def update
		if @<%= model_name.to_snake %>.update(<%= model_name.to_snake.singularize %>_params)
			redirect_to <%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.update")
		else
			render "edit"
		end
	end

	#
	# Destroy action
	#
	def destroy
		@<%= model_name.to_snake.singularize %>.destroy
		redirect_to <%= controller_path.to_snake.gsub("/", "_").pluralize %>_path, notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.destroy")
	end

private

	#
	# Set model
	#
	def set_<%= model_name.to_snake.singularize %>
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.find_by_id(params[:id])
		if @<%= model_name.to_snake.singularize %>.nil?
			redirect_to root_path, alert: I18n.t("activerecord.errors.models.<%= model_name.to_snake.singularize %>.not_found")
		end
	end

	# 
	# Never trust parameters from the scary internet, only allow the white list through.
	#
	def <%= model_name.to_snake.singularize %>_params
		params.require(:<%= model_name.to_snake.singularize %>).permit(<%= columns.map { |column| ":#{column.split(":").first}" }.join(", ") if columns %>)
	end

end
