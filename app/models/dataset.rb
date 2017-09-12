class Dataset < ApplicationRecord

  def initialize(attributes={})
    super
    @query = nil
    @rows = nil
    @total_rows = nil
    @sql = nil
    @levels = nil
  end

  def schema
  end

  def rows
    run if @rows.nil?
    @rows
  end

  def sql
    run if @sql.nil?
    @sql
  end

  def query
    run if @query.nil?
    @query
  end

  def total_rows
    run if @total_rows.nil?
    @total_rows
  end

  def levels
    run if @levels.nil?
    @levels
  end

  def run query = {}
  end
def self.inherited(child)
  child.instance_eval do
    def model_name
      Dataset.model_name
    end
  end
  super
end
end
