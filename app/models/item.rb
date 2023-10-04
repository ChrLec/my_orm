class Item
  attr_reader :id
  attr_accessor :name, :price

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @price = attributes[:price]
  end

  def self.create(attributes = {})
    sql = <<-SQL
    INSERT INTO items (name, price)
    VALUES ("#{attributes[:name]}", "#{attributes[:price]}")
    RETURNING *
    SQL
    response = ActiveRecord::Base.connection.execute(sql).first
    build_record(response)
  end

  def self.find(id)
    sql = <<-SQL
    SELECT * FROM items WHERE id = "#{id}"
    SQL
    response = ActiveRecord::Base.connection.execute(sql).first
    build_record(response) if response
  end

  def update(attributes = {})
    sql = <<-SQL
    UPDATE items SET name = "#{attributes[:name] ? attributes[:name] : @name}",
                     price = "#{attributes[:price] ? attributes[:price] : @price}"
    WHERE id = "#{@id}"
    RETURNING *
    SQL
    response = ActiveRecord::Base.connection.execute(sql).first
    build_record(response)
  end

  def destroy
    sql = <<-SQL
    DELETE FROM items WHERE id = "#{@id}"
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.all
    sql = <<-SQL
    SELECT * FROM items
    SQL
    response = ActiveRecord::Base.connection.execute(sql)
  end

  def self.build_record(response)
    attributes = {
      id: response["id"],
      name: response["name"],
      price: response["price"]
    }
    Item.new(attributes)
  end
end
