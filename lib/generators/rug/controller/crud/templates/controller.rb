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

	before_action :save_referrer, only: [:new, :edit]
	before_action :set_<%= model_name.to_snake.singularize %>, only: [:show, :edit, :update, :destroy]

	def index
		@filter_<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.new(load_params_from_session)
		@<%= model_name.to_snake.pluralize %> = <%= model_path.to_camel.singularize %>.filter(load_params_from_session.symbolize_keys).sorting(params[:sort]).page(params[:page]).per(50)
		respond_to do |format|
			format.html { render "index" }
			format.json { render json: @<%= model_name.to_snake.pluralize %>.to_json }
		end
	end

	def filter
		save_params_to_session(filter_params)
		redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").pluralize %>_path
	end

	def search
		@<%= model_name.to_snake.pluralize %> = <%= model_path.to_camel.singularize %>.search(params[:q]).order(id: :asc)
		respond_to do |format|
			format.html { render "index" }
			format.json { render json: @<%= model_name.to_snake.pluralize %>.to_json }
		end
	end

	def show
		respond_to do |format|
			format.html { render "show" }
			format.json { render json: @<%= model_name.to_snake.singularize %>.to_json }
		end
	end

	def new
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.new
	end

	def edit
	end

	def create
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.new(<%= model_name.to_snake.singularize %>_params)
		if @<%= model_name.to_snake.singularize %>.save
			respond_to do |format|
				format.html { redirect_to load_referrer, notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.create") }
				format.json { render json: @<%= model_name.to_snake.singularize %>.id }
			end
		else
			respond_to do |format|
				format.html { render "new" }
				format.json { render json: @<%= model_name.to_snake.singularize %>.errors }
			end
		end
	end

	def update
		if @<%= model_name.to_snake %>.update(<%= model_name.to_snake.singularize %>_params)
			respond_to do |format|
				format.html { redirect_to load_referrer, notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.update") }
				format.json { render json: @<%= model_name.to_snake.singularize %>.id }
			end
		else
			respond_to do |format|
				format.html { render "edit" }
				format.json { render json: @<%= model_name.to_snake.singularize %>.errors }
			end
		end
	end

	def destroy
		@<%= model_name.to_snake.singularize %>.destroy
		respond_to do |format|
			format.html { redirect_to request.referrer, notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.destroy") }
			format.json { render json: @<%= model_name.to_snake.singularize %>.id }
		end
	end

protected

	# *************************************************************************
	# Model setters
	# *************************************************************************

	def set_<%= model_name.to_snake.singularize %>
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.find_by_id(params[:id])
		if @<%= model_name.to_snake.singularize %>.nil?
			redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").pluralize %>_path, alert: I18n.t("activerecord.errors.models.<%= model_name.to_snake.singularize %>.not_found")
		end
	end

	# *************************************************************************
	# Param filters
	# *************************************************************************

	def <%= model_name.to_snake.singularize %>_params
		params.require(:<%= model_name.to_snake.singularize %>).permit(<%= model_path.to_camel.singularize %>.permitted_columns)
	end

	def filter_params
		return params[:<%= model_name.to_snake.singularize %>].permit(<%= model_path.to_camel.singularize %>.filter_columns)
	end

end
