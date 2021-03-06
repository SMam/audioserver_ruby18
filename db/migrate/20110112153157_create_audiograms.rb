class CreateAudiograms < ActiveRecord::Migration
  def self.up
    create_table :audiograms do |t|
      t.integer :patient_id
      t.datetime :examdate
      t.string :comment
      t.string :image_location
      t.float :ac_rt_125
      t.float :ac_rt_250
      t.float :ac_rt_500
      t.float :ac_rt_1k
      t.float :ac_rt_2k
      t.float :ac_rt_4k
      t.float :ac_rt_8k
      t.float :ac_lt_125
      t.float :ac_lt_250
      t.float :ac_lt_500
      t.float :ac_lt_1k
      t.float :ac_lt_2k
      t.float :ac_lt_4k
      t.float :ac_lt_8k
      t.float :bc_rt_250
      t.float :bc_rt_500
      t.float :bc_rt_1k
      t.float :bc_rt_2k
      t.float :bc_rt_4k
      t.float :bc_rt_8k
      t.float :bc_lt_250
      t.float :bc_lt_500
      t.float :bc_lt_1k
      t.float :bc_lt_2k
      t.float :bc_lt_4k
      t.float :bc_lt_8k
      t.boolean :ac_rt_125_scaleout
      t.boolean :ac_rt_250_scaleout
      t.boolean :ac_rt_500_scaleout
      t.boolean :ac_rt_1k_scaleout
      t.boolean :ac_rt_2k_scaleout
      t.boolean :ac_rt_4k_scaleout
      t.boolean :ac_rt_8k_scaleout
      t.boolean :ac_lt_125_scaleout
      t.boolean :ac_lt_250_scaleout
      t.boolean :ac_lt_500_scaleout
      t.boolean :ac_lt_1k_scaleout
      t.boolean :ac_lt_2k_scaleout
      t.boolean :ac_lt_4k_scaleout
      t.boolean :ac_lt_8k_scaleout
      t.boolean :bc_rt_250_scaleout
      t.boolean :bc_rt_500_scaleout
      t.boolean :bc_rt_1k_scaleout
      t.boolean :bc_rt_2k_scaleout
      t.boolean :bc_rt_4k_scaleout
      t.boolean :bc_rt_8k_scaleout
      t.boolean :bc_lt_250_scaleout
      t.boolean :bc_lt_500_scaleout
      t.boolean :bc_lt_1k_scaleout
      t.boolean :bc_lt_2k_scaleout
      t.boolean :bc_lt_4k_scaleout
      t.boolean :bc_lt_8k_scaleout
      t.float :mask_ac_rt_125
      t.float :mask_ac_rt_250
      t.float :mask_ac_rt_500
      t.float :mask_ac_rt_1k
      t.float :mask_ac_rt_2k
      t.float :mask_ac_rt_4k
      t.float :mask_ac_rt_8k
      t.float :mask_ac_lt_125
      t.float :mask_ac_lt_250
      t.float :mask_ac_lt_500
      t.float :mask_ac_lt_1k
      t.float :mask_ac_lt_2k
      t.float :mask_ac_lt_4k
      t.float :mask_ac_lt_8k
      t.float :mask_bc_rt_250
      t.float :mask_bc_rt_500
      t.float :mask_bc_rt_1k
      t.float :mask_bc_rt_2k
      t.float :mask_bc_rt_4k
      t.float :mask_bc_rt_8k
      t.float :mask_bc_lt_250
      t.float :mask_bc_lt_500
      t.float :mask_bc_lt_1k
      t.float :mask_bc_lt_2k
      t.float :mask_bc_lt_4k
      t.float :mask_bc_lt_8k
      t.string :mask_ac_rt_125_type
      t.string :mask_ac_rt_250_type
      t.string :mask_ac_rt_500_type
      t.string :mask_ac_rt_1k_type
      t.string :mask_ac_rt_2k_type
      t.string :mask_ac_rt_4k_type
      t.string :mask_ac_rt_8k_type
      t.string :mask_ac_lt_125_type
      t.string :mask_ac_lt_250_type
      t.string :mask_ac_lt_500_type
      t.string :mask_ac_lt_1k_type
      t.string :mask_ac_lt_2k_type
      t.string :mask_ac_lt_4k_type
      t.string :mask_ac_lt_8k_type
      t.string :mask_bc_rt_250_type
      t.string :mask_bc_rt_500_type
      t.string :mask_bc_rt_1k_type
      t.string :mask_bc_rt_2k_type
      t.string :mask_bc_rt_4k_type
      t.string :mask_bc_rt_8k_type
      t.string :mask_bc_lt_250_type
      t.string :mask_bc_lt_500_type
      t.string :mask_bc_lt_1k_type
      t.string :mask_bc_lt_2k_type
      t.string :mask_bc_lt_4k_type
      t.string :mask_bc_lt_8k_type
      t.boolean :manual_input
      t.string :audiometer
      t.string :hospital
      t.integer :examiner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :audiograms
  end
end
