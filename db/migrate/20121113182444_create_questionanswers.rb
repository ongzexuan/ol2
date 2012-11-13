class CreateQuestionanswers < ActiveRecord::Migration
  def change
    create_table :questionanswers do |t|
      t.text :question
      t.text :answer
      t.integer :position
      t.integer :checkpoint_id

      t.timestamps
    end
  end
end
