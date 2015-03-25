require 'trailblazer'

module TransferMoney
  class Create < Trailblazer::Operation
    contract do
      include ActiveModel
      #include Reform::Form::ActiveModel

      property :source_account_id
      property :destination_account_id
      property :amount

      # TODO: add validations regarding:
      # * existance of accounts
      # * amount cannot be negative
    end

    def process(params)
      #validate params[:transfer_money] do
        ActiveRecord::Base.transaction do
          amount = params[:transfer_money][:amount]
          source_account_id = params[:transfer_money][:source_account_id]
          destination_account_id = params[:transfer_money][:destination_account_id]

          # TODO: move the amount check to the contract
          if amount > 0 && get_balance(source_account_id) >= amount
            Trade.create(amount: - amount, account_id: source_account_id)
            Trade.create(amount: amount, account_id: destination_account_id)
          else
            false
          end
        end
      #end
    end

    def get_balance(account_id)
      Trade.where(account_id: account_id).sum(:amount)
    end
  end
end
