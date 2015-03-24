class TransferMoney
  class Create < Trailblazer::Operation
    contract do
      include ActiveModel
      include Reform::Form::ActiveModel

      property :source_account_id
      property :destination_account_id
      property :amount

      # TODO: add validations regarding:
      # * existance of accounts
      # * amount cannot be negative
      # * enough balance on source account
    end

    def process(params)
      validate params[:transfer_money] do
        ActiveRecord::Base.transaction do
          Trade.create(amount: - amount, account_id: source_account_id)
          Trade.create(amount: amount, account_id: destination_account_id)
        end
      end
    end
  end
end
