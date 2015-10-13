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

	before_action :set_<%= model_1_name.to_snake.singularize %>, only: [:show, :edit, :update, :destroy]

	#
	# Show action
	#
	def show
		respond_to do |format|
			format.html { render "show" }
			format.json { render json: @<%= model_1_name.to_snake.singularize %>.to_json }
		end
	end

	#
	# New action
	#
	def new
		@<%= model_1_name.to_snake.singularize %> = <%= model_1_path.to_camel.singularize %>.new
		if params[:<%= model_2_name.to_snake.singularize %>_id]
			@<%= model_1_name.to_snake.singularize %>.<%= model_2_name.to_snake.singularize %>_id = params[:<%= model_2_name.to_snake.singularize %>_id] 
		else
			redirect_to root_path, alert: I18n.t("activerecord.errors.models.<%= model_1_name.to_snake.singularize %>.attributes.<%= model_2_name.to_snake.singularize %>_id.blank")
		end
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
		@<%= model_1_name.to_snake.singularize %> = <%= model_1_path.to_camel.singularize %>.new(<%= model_1_name.to_snake.singularize %>_params)
		if @<%= model_1_name.to_snake.singularize %>.save
			respond_to do |format|
				format.html { redirect_to <%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_1_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_1_name.to_snake.singularize %>.create") }
				format.json { render json: @<%= model_1_name.to_snake.singularize %>.id }
			end
		else
			respond_to do |format|
				format.html { render "new" }
				format.json { render json: @<%= model_1_name.to_snake.singularize %>.errors }
			end
		end
	end

	#
	# Update action
	#
	def update
		if @<%= model_1_name.to_snake %>.update(<%= model_1_name.to_snake.singularize %>_params)
			respond_to do |format|
				format.html { redirect_to <%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_1_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_1_name.to_snake.singularize %>.update") }
				format.json { render json: @<%= model_1_name.to_snake.singularize %>.id }
			end
		else
			respond_to do |format|
				format.html { render "edit" }
				format.json { render json: @<%= model_1_name.to_snake.singularize %>.errors }
			end
		end
	end

	#
	# Destroy action
	#
	def destroy
		@<%= model_1_name.to_snake.singularize %>.destroy
		respond_to do |format|
			format.html { redirect_to <%= model_2_controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_1_name.to_snake.singularize %>.<%= model_2_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_1_name.to_snake.singularize %>.destroy") }
			format.json { render json: @<%= model_1_name.to_snake.singularize %>.id }
		end
	end

protected

	#
	# Set model
	#
	def set_<%= model_1_name.to_snake.singularize %>
		@<%= model_1_name.to_snake.singularize %> = <%= model_1_path.to_camel.singularize %>.find_by_id(params[:id])
		if @<%= model_1_name.to_snake.singularize %>.nil?
			redirect_to root_path, alert: I18n.t("activerecord.errors.models.<%= model_1_name.to_snake.singularize %>.not_found")
		end
	end

	# 
	# Never trust parameters from the scary internet, only allow the white list through.
	#
	def <%= model_1_name.to_snake.singularize %>_params
		params.require(:<%= model_1_name.to_snake.singularize %>).permit(:<%= model_2_name.to_snake.singularize %>_id, <%= columns.map { |column| ":#{column.split(":").first}" }.join(", ") if columns %>)
	end

end
