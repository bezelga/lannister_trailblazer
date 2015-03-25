require 'trailblazer'

module TransferMoney
  Transfer = Struct.new(:source_account_id,
                        :destination_account_id,
                        :amount)

  class Create < Trailblazer::Operation
    contract do
      include ActiveModel
      #include Reform::Form::ActiveModel

      property :source_account_id
      property :destination_account_id
      property :amount

      validate :validate_amount, :enough_balance?

      validates_presence_of :source_account_id,
                            :destination_account_id,
                            :amount

      def validate_amount
        unless amount > 0
          errors.add :amount, 'amount must be greater than 0'
        end
      end

      def enough_balance?
        unless get_balance(source_account_id) >= amount
          errors.add :amount, 'not enough balance'
        end
      end

      private

      def get_balance(account_id)
        Trade.where(account_id: account_id).sum(:amount)
      end
    end

    def process(params)
      model = Transfer.new

      validate(params[:transfer_money], model) do
        ActiveRecord::Base.transaction do
          amount = params[:transfer_money][:amount]
          source_account_id = params[:transfer_money][:source_account_id]
          destination_account_id = params[:transfer_money][:destination_account_id]

          Trade.create(amount: - amount, account_id: source_account_id)
          Trade.create(amount: amount, account_id: destination_account_id)
        end
      end

      false
    end
  end
end
