require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    attr_accessor :name, :grade

    # def initialize(id:nil, name:nil, grade:nil)
    #     @id = id
    #     @name = name
    #     @grade = grade
    # end

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
        end
    end
  
    def self.table_name
        self.to_s.pluralize.downcase
    end

    def self.column_names
        # returns by parameters including column name,
        # if no data present, just returns column name
        DB[:conn].execute2("SELECT * FROM students").flatten
    end

    def table_name_for_insert
        # DB[:conn].execute("SELECT name FROM sqlite_master WHERE type='table'")[0]["name"]
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        results = []
        self.class.column_names.each do |col_name|
            results << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        results.join(", ")
    end

    def save
        sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) 
        VALUES (#{values_for_insert})
        SQL
 
        DB[:conn].execute(sql)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM #{self.table_name} 
        WHERE name = '#{name}'
        SQL

        DB[:conn].execute(sql)
    end

    def self.find_by(arg)
        # k = arg.keys[0].to_s
        # v = arg.values[0]
        # sql = <<-SQL
        # SELECT *
        # FROM #{self.table_name}
        # WHERE #{k} = #{v};
        # SQL
        
        # DB[:conn].execute(sql, arg.keys[0].to_s, arg.values[0])

        dbhash = DB[:conn].execute("select * from students")[0]

        # binding.pry
        # dbhash.select do |key, value|
        #     if key == arg.keys[0].to_s  
        #       DB[:conn].execute("select * from students where #{key} = #{send(arg.values[0])}")
        #     end  
        # end
    end
end