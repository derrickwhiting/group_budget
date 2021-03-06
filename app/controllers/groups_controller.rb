class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :group, except: [:index, :create]
  def index
    @groups = current_user.groups
    render json: @groups
  end

  def show
    @bills = @group.bills_breakdown
    @comments = @group.comments.map do |comment|
      {id: comment.id, body: comment.body, first_name: User.find(comment.user_id).first_name}
    end
  end

  def create
    # binding.pry
    @group = Group.new(group_params)
    @group.creator_id = current_user.id
    if @group.save
      UserGroup.create({user_id: current_user.id, group_id: @group.id})
      render json: @group
    else
      redirect_to root_path
    end
  end

  def update
    if @group.creator_id == current_user.id
      if @group.update(group_params)
        render json: @group
      else
        render :edit
      end
    else
      render json: {error: 'Not the creator.'}
    end
  end

  def invite
    @user = User.find_by(email: params[:email])
    
    @connection = UserGroup.find_by({user_id: @user.id, group_id: @group.id}) if @user
    if @user && @connection == nil
      UserGroup.create({group_id: @group.id, user_id: @user.id})
      head :ok
    else
      render json: {error: 'Could not find user or user is already in your group. Please make sure user has registered before inviting to group'}
    end
  end

  def destroy
    if @group.creator_id == current_user.id
      if @group.destroy
        #binding.pry
        #redirect_to root_path
        head :ok
      else
        redirect_to groups_path
      end
    else
      render json: {error: 'Not the creator.'}
    end
  end


  private
  def group_params
    params.require(:group).permit(:name)
  end

  def group
    @group = Group.find(params[:id])
  end

end
