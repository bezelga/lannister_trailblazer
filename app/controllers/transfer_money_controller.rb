class TransferMoneyController < ApplicationController
  include Trailblazer::Operation::Controller

  def new
    form TransferMoney::Create
  end

  def create
    run TransferMoney::Create do |operation|
      return redirect_to(comments_path, notice: op.message)
    end
  end
end
