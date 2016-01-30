class UserBillsController < ApplicationController
  before_action :authenticate_user!
  def pay_bill
    @user_bill = UserBill.find_by(bill_id: params[:id], user_id: current_user.id)
    if @user_bill
      @user_bill.amount_paid += params[:user_bill][:amount_paid].to_f
      @user_bill.amount_owed -= params[:user_bill][:amount_paid].to_f
      @bill = Bill.find(params[:id])
      @bill.amount_paid += params[:user_bill][:amount_paid].to_f
      @bill.amount_total -= params[:user_bill][:amount_paid].to_f
      if @user_bill.amount_owed <= 0.01
        @user_bill.is_paid = true
      end
      if @bill.amount_total <= 0.02
        @bill.is_paid = true
        if @bill.recurring == true
          @group = Group.find(@bill.group_id)
          @new_bill = @group.bills.new
          @new_bill.name = @bill.name
          # binding.pry
          @new_bill.recurring = @bill.recurring
          @new_bill.amount_total = @bill.amount_paid
          @new_bill.creator_id = @bill.creator_id
          @new_bill.save
          binding.pry
        end
      end
      @user_bill.save
      @bill.save

      render json: @user_bill
    else
        #inform user that there is nothing to be paid
    end
  end
  private
  def user_bill_params
    params.require(:user_bill).permit(:amount_owed, :amount_paid, :is_paid)
  end
end
