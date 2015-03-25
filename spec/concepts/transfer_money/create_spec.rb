require 'rails_helper'

describe TransferMoney::Create do
  describe '.transfer' do
    subject(:transfer) do
      described_class.run({ transfer_money: { source_account_id: source_account_id,
                             destination_account_id: destination_account_id,
                             amount: amount } })
    end

    let(:amount)                 { 1_000 }
    let(:source_account_id)      { 1 }
    let(:destination_account_id) { 2 }

    def get_balance(account_id)
      Trade.where(account_id: account_id).sum(:amount)
    end

    def source_account_balance
      get_balance(source_account_id)
    end

    def destination_account_balance
      get_balance(destination_account_id)
    end

    context 'enough money to transfer' do
      before do
        Trade.create!(account_id: source_account_id,
                      amount: amount)
      end

      it 'debits the source account' do
        expect{ transfer }.to change{ source_account_balance }.by(- amount)
      end

      it 'credits the destination account' do
        expect{ transfer }.to change{ destination_account_balance }.by(amount)
      end
    end

    context 'not enough money to transfer' do
      it 'cancels the transfer and responds false' do
        response, operation = transfer
        expect(response).to eq(false)
        expect(operation.errors.messages).to eq({:amount=>['not enough balance']})
      end

      it 'does not change the accounts balance' do
        expect{ transfer }.to_not change{ source_account_balance }
        expect{ transfer }.to_not change{ destination_account_balance }
      end
    end

    context 'when the amount is zero' do
      let(:amount) { 0 }

      it 'cancels the transfer' do
        response, operation = transfer
        expect(response).to eq(false)
        expect(operation.errors.messages).to eq({:amount=>["amount must be greater than 0"]})
      end
    end
  end
end
