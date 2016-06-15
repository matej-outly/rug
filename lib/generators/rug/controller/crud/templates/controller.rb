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
		@filter_<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.new(load_params_from_session)
		@<%= model_name.to_snake.pluralize %> = <%= model_path.to_camel.singularize %>.filter(load_params_from_session.symbolize_keys).sorting(params[:sort]).page(params[:page]).per(50)
		respond_to do |format|
			format.html { render "index" }
			format.json { render json: @<%= model_name.to_snake.pluralize %>.to_json }
		end
	end

	#
	# Filter action
	#
	def filter
		save_params_to_session(filter_params)
		redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").pluralize %>_path
	end

	#
	# Search action
	#
	def search
		@<%= model_name.to_snake.pluralize %> = <%= model_path.to_camel.singularize %>.search(params[:q]).order(id: :asc)
		respond_to do |format|
			format.html { render "index" }
			format.json { render json: @<%= model_name.to_snake.pluralize %>.to_json }
		end
	end

	#
	# Show action
	#
	def show
		respond_to do |format|
			format.html { render "show" }
			format.json { render json: @<%= model_name.to_snake.singularize %>.to_json }
		end
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
				format.html { redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.create") }
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
				format.html { redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").singularize %>_path(@<%= model_name.to_snake.singularize %>), notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.update") }
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
			format.html { redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").pluralize %>_path, notice: I18n.t("activerecord.notices.models.<%= model_name.to_snake.singularize %>.destroy") }
			format.json { render json: @<%= model_name.to_snake.singularize %>.id }
		end
	end

protected

	# *************************************************************************
	# Model setters
	# *************************************************************************

	#
	# Set model
	#
	def set_<%= model_name.to_snake.singularize %>
		@<%= model_name.to_snake.singularize %> = <%= model_path.to_camel.singularize %>.find_by_id(params[:id])
		if @<%= model_name.to_snake.singularize %>.nil?
			redirect_to main_app.<%= controller_path.to_snake.gsub("/", "_").pluralize %>_path, alert: I18n.t("activerecord.errors.models.<%= model_name.to_snake.singularize %>.not_found")
		end
	end

	# *************************************************************************
	# Session
	# *************************************************************************

	#
	# Get session key unique for the controller
	#
	def session_key
		return "<%= model_name.to_snake.pluralize %>"
	end

	#
	# Save given params to session
	#
	def save_params_to_session(params)
		session[session_key] = {} if session[session_key].nil?
		session[session_key]["params"] = params if !params.nil?
	end

	#
	# Load last saved params from session
	#
	def load_params_from_session
		if !session[session_key].nil? && !session[session_key]["params"].nil?
			return session[session_key]["params"]
		else
			return {}
		end
	end

	# *************************************************************************
	# Param filters
	# *************************************************************************

	# 
	# Never trust parameters from the scary internet, only allow the white list through.
	#
	def <%= model_name.to_snake.singularize %>_params
		params.require(:<%= model_name.to_snake.singularize %>).permit(<%= model_path.to_camel.singularize %>.permitted_columns)
	end

	# 
	# Never trust parameters from the scary internet, only allow the white list through.
	#
	def filter_params
		return params[:<%= model_name.to_snake.singularize %>]#.permit(...)
	end

end
