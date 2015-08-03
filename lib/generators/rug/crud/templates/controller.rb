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
		@<%= model_name.to_snake.pluralize %> = <%= model_path.to_camel.singularize %>.all.sorting(params[:sort]).page(params[:page]).per(50)
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
			respond_to do |format|
				format.html { redirect_to <%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.create") }
				format.json { render json: @<%= model_name.to_snake.singularize %>.id }
			end
		else
			respond_to do |format|
				format.html { render "new" }
				format.json { render json: @<%= model_name.to_snake.singularize %>.errors }
			end
		end
	end

	#
	# Update action
	#
	def update
		if @<%= model_name.to_snake %>.update(<%= model_name.to_snake.singularize %>_params)
			respond_to do |format|
				format.html { redirect_to <%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.update") }
				format.json { render json: @<%= model_name.to_snake.singularize %>.id }
			end
		else
			respond_to do |format|
				format.html { render "edit" }
				format.json { render json: @<%= model_name.to_snake.singularize %>.errors }
			end
		end
	end

	#
	# Destroy action
	#
	def destroy
		@<%= model_name.to_snake.singularize %>.destroy
		respond_to do |format|
			format.html { redirect_to <%= controller_path.to_snake.gsub("/", "_").pluralize %>_path, notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.destroy") }
			format.json { render json: @<%= model_name.to_snake.singularize %>.id }
		end
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
