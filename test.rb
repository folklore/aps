require 'time'
 
class Storage
  include Enumerable

  @@conversion_rules = { }

  attr_accessor :input

  def initialize(input)
    @input = converter(input)
  end

  def each(&block)
    @input.each{ |i| block.call(i) }
    # @input.each(&block)
  end

  def self.attrb(attribute, format = nil)
    @@conversion_rules[self.name] ||= { }

    if block_given?
      format = Proc.new do |value|
        yield(value)
      end
    end

    @@conversion_rules[self.name].merge!(attribute => format)
  end

  def converter(input)
    conversion_rules = @@conversion_rules[self.class.name]

    input.each do |i|
      i.each do |key, value|
        # Если преобразование не требуется
        if conversion_rules[key].nil?
          next
        # Если для преобразования используется блок
        elsif conversion_rules[key].is_a?(Proc)
          i[key] = conversion_rules[key].call(i[key])
        else # Если преобразование по методу
          i[key] = i[key].send(conversion_rules[key])
        end
      end
    end
  end

  def cr
    puts @@conversion_rules
  end
end

class Transactions < Storage
  attrb :uid
  attrb :sum, :to_f
  attrb :timestamp do |value| 
    Time.parse(value)
  end

  def sum
    self.inject(0){ |result, i| result + i[:sum] }
  end
end

transactions = Transactions.new([
  {uid: 'HT150', sum: '50.25', timestamp: '2014-04-04 05:50'},
  {uid: 'HT151', sum: '119.63', timestamp: '2014-04-04 06:18'}
])

puts transactions.to_a
# {:uid=>"HT150", :sum=>50.25, :timestamp=>2014-04-04 05:50:00 +0600}
# {:uid=>"HT151", :sum=>119.63, :timestamp=>2014-04-04 06:18:00 +0600}
puts ''
puts transactions.first
# {:uid=>"HT150", :sum=>50.25, :timestamp=>2014-04-04 05:50:00 +0600}
puts ''
puts transactions.select { |tx| tx[:sum] > 100 }
# {:uid=>"HT151", :sum=>119.63, :timestamp=>2014-04-04 06:18:00 +0600}
puts ''
puts transactions.sum
# 169.88

class People < Storage
  attrb :name
  attrb :height, :to_i
  attrb :birthday do |value|
    Date.parse(value).strftime("%a, %d %b %Y")
  end
end

ppl = People.new([{name: 'Vlas', height: '205', birthday: '1990-08-08'}])

puts ''
puts ppl.first
# {:name=>"Vlas", :height=>205, :birthday=>"Wed, 08 Aug 1990"}

puts ''
puts ppl.cr