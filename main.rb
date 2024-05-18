# input /ab/



class StateMachine
  attr_accessor :stack, :orders, :cursor, :input_cursor
  def initialize(orders)
    pp "initializing state machine"
    @stack = []
    @orders = orders
    @cursor = 0
    @input_cursor = 0
  end

  def match(input)
    p @orders
    while @cursor < @orders.length
      order = @orders[@cursor]

      # pp "processing order #{order.order} with state #{self.inspect}"
      # p "########################"
      result = order.process(self, input)
      @cursor += 1
      return true if order.order.class == Match && result
      next if result
      return false if @stack.empty?

      @cursor, @input_cursor = @stack.pop
    end
  end
end

class Order 
  attr_accessor :order, :operand
  def initialize(order, operand)
    @order = order
    @operand = operand
  end

  def length
    1
  end

  def process(s, input)
    @order.process(s, @operand, input)
  end
end

class Push
  def process(s, operand, input)
    s.stack.push([operand, s.input_cursor])
    return true

  end
end

class Char
  def process(s, operand, input)
      p "comparing #{input[s.input_cursor]} with #{operand}, input cursor #{s.input_cursor}"
    if input[s.input_cursor] == operand
      s.input_cursor += 1
      return true
    else
      return false
    end
  end
end

class Jump
  def process(s, operand, input)
    s.cursor = operand-1
    return true
  end
end

class Match
  def process(s, operand, input)
    p "input cursor #{s.input_cursor}"
    if s.input_cursor == input.length
      return true
    else
      return false
    end
  end
end


class Parser
  def self.parse(input)
    ast=[]
    ast=self.parse1(input,0,0)
  end

  def self.parse1(input, cursor, input_cursor)
    ret=[]
    (0..input.length-1).each do |ch|
      case input[ch]
      when "*"
        # cursor-lengthの場所にPush cursor+2, cursor+=1
        ret  = ret[0..cursor-ret[-1].length-1]+[Order.new(Push.new, cursor+2)]+ret[cursor-ret[-1].length..-1]+[Order.new(Jump.new, cursor-1)]
        cursor+=2
        input_cursor+=1
      else
        ret.push(Order.new(Char.new, input[input_cursor]))
        input_cursor+=1
        cursor+=1
      end
    end
    ret.push(Order.new(Match.new, nil))
    return ret
  end
end

p "正規表現入力(対応記号、*のみ)"
order = gets.chomp
pp Parser.parse(order)

while true
  sm = StateMachine.new(Parser.parse(order))

  input = gets.chomp
  p sm.match(input)
end
