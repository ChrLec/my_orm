class Client
  attr_reader :id
  attr_accessor :name, :city

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @city = attributes[:city]
  end

  # A FAIRE update create

  def self.find(id)
    return unless id.is_a?(Integer)

    attributes = {id: id}
    sql = <<-SQL
    SELECT * FROM clients
    WHERE id = "#{attributes[:id]}"
    SQL

    response = ActiveRecord::Base.connection.execute(sql).first
    build_record(response) if response
  end

  def destroy
    sql = <<-SQL
    DELETE FROM clients WHERE id = "#{@id}"
    SQL
    ActiveRecord::Base.connection.execute(sql)
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
