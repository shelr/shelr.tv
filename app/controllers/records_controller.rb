class RecordsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  before_filter :find_record, :only => [:show, :edit, :update, :destroy, :embed]

  respond_to :html, :json, :atom

  def index
    @query = Record.desc(:created_at).without(:typescript, :timing).visible_by(current_user)
    if params[:tags]
      @records = RecordDecorator.decorate(@query.where(:tags.in => params[:tags]).page(params[:page]))
    else
      @records = RecordDecorator.decorate(@query.page(params[:page]))
    end
    respond_with @records
  end

  def show
    @record.hit!(current_user) if request.format.json?
    respond_with @record
  end

  def embed
    render :embed, :layout => 'embed'
  end

  def create
    user = User.where(api_key: params[:api_key]).first if params[:api_key].present?
    user = User.where(nickname: 'Anonymous').first unless user

    @record = user.records.build(JSON.parse(params[:record]))

    if @record.save
      record_full_url =
        if @record.private?
          record_path(@record, only_path: false, access_key: @record.access_key)
        else
          record_path(@record, only_path: false)
        end

      render json: {
        ok: true,
        id: @record.id.to_s,
        url: record_full_url,
        message: 'Record published!'
      }
    else
      render json: { ok: false, message: 'Cannot publish the record :(' }
    end
  rescue => e
    render json: { ok: false, message: "Cannot publish the record :(\n\n" + e.message }
  end

  def update
    if @record.editable_by?(current_user) && @record.update_attributes(params[:record])
      flash[:notice] = 'Record was succesfully updated.'
    else
      flash[:error] = 'You cannot edit this record.'
    end

    redirect_to @record
  end

  def destroy
    if @record.destroy
      flash[:notice] = "Record was destroyed!"
      redirect_to records_path
    else
      flash[:error] = "Record was NOT destroyed!"
      redirect_to @record
    end
  end

  def search
    @records = Record.solr_search do
      fulltext params[:q]
      with :private, false
      paginate page: params[:page] || 1
    end.results

    respond_with @records
  end

  private

  def find_record
    if params[:access_key].present?
      @record = RecordDecorator.decorate(Record.priv.where(access_key: params[:access_key]).find(params[:id]))
    else
      @record = RecordDecorator.decorate(Record.visible_by(current_user).find(params[:id]))
    end

  rescue Mongoid::Errors::DocumentNotFound
    render :no_such_record
  end
end
