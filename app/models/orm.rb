class Orm
  attr_reader :id

  def initialize(attributes = {})
    @id = attributes[:id]
    sql = <<-SQL
      select *
      from "#{self.class.to_s.capitalize}s"
    SQL
    response = ActiveRecord::Base.connection.execute(sql)
    columns_except_id = response.first.keys - ["id"]
    columns_except_id.each do |column|
      instance_variable_set(:"@#{column}", attributes[:"#{column}"])
      self.class.send(:attr_accessor, column)
    end
  end

  def self.create(attributes = {})
    columns = "("+ attributes.keys.join(', ') + ")"
    values = []
    attributes.keys.each do |column|
      values << "'#{attributes[column]}'"
    end
    string_values = "(" + values.join(', ') + ")"

    response = ActiveRecord::Base.connection.execute("INSERT INTO #{name.to_s.capitalize}s #{columns} VALUES  #{string_values} RETURNING *").first
    responses = {
      id: response["id"]
    }
    attributes.keys.each do |column|
      responses[column] = response[column.to_s]
    end
    new(responses)
  end

  def self.find(id)
    response = ActiveRecord::Base.connection.execute("SELECT * FROM #{name.to_s.capitalize}s WHERE id = #{id}").first
    return unless response

    attributes = {}
    response.keys.each do |column|
      attributes[column.to_sym] = response[column.to_s]
    end
    new(attributes)
  end

  def update(attributes = {})
    attributes.keys.each do |column|
      sql = <<-SQL
        UPDATE "#{self.class.to_s.capitalize}s" SET "#{column.to_sym}" = "#{attributes[column]}"
        WHERE id = "#{@id}"
      SQL
      ActiveRecord::Base.connection.execute(sql).first
    end
    response = ActiveRecord::Base.connection.execute("SELECT * FROM #{self.class.to_s.capitalize}s WHERE id = #{id}").first
    attributes = {}
    response.keys.each do |column|
      attributes[column.to_sym] = response[column.to_s]
    end
    self.class.new(attributes)
  end

  def destroy
    sql = <<-SQL
      DELETE FROM "#{self.class.to_s.capitalize}s" WHERE id = "#{@id}"
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM "#{name.to_s.capitalize}s"
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end
end
