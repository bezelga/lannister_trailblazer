class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.references :account, index: true, foreign_key: true
      t.decimal :amount
      t.date :date

      t.timestamps null: false
    end
  end
end
