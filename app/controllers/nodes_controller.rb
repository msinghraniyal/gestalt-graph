class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy]

  # GET /nodes
  # GET /nodes.json
  def index
    if !params[:map_id]
      @nodes = Node.all
      render :master_index
    else
      @map = Map.find(params[:map_id])
    end
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  # GET /nodes/new
  def new
    @map = Map.find(params[:map_id])
    @node = Node.new(map_id: params[:map_id])
  end

  # GET /nodes/1/edit
  def edit
    @map = Map.find(@node.map_id)
  end

  def create_relationship
    p "---------- form params ------------"
    p params
    @node = Node.find(params[:start_id])
    target_nodes = Node.find(params[:target_ids])
    target_nodes.each do |target|
      @node.create_rel(params[:my_rel_type], target, props = {strength: params[:strength]})
    end
    @node.rels.each {|r| p r.rel_type}
    render :show
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(node_params)

    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1
  # PATCH/PUT /nodes/1.json
  def update
    respond_to do |format|
      if @node.update(node_params)
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { render :show, status: :ok, location: @node }
      else
        format.html { render :edit }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    @node.destroy
    respond_to do |format|
      format.html { redirect_to nodes_url, notice: 'Node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_relationship
    @node = Node.find(params[:id])
    target_node = Node.find(params[:target_id])
    p "----------- rel to node ------------"
    p params[:relationship]
    p params[:rel_id]
    this_rel_type = params[:relationship].to_sym
    #p @node.rel(between: target_node, dir: :both)
    @node.rels(between: target_node).each do |rel|
      p " rel id: #{rel.id} | param: #{params[:rel_id]}"
      if rel.id == params[:rel_id].to_i
        rel.del
        p "********* deleted rel ***********"
      end
    end

    render :show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @node = Node.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def node_params
      params.require(:node).permit(:name, :description, :map_id, :category_ids => [], :node_ids => [])
    end
end
