# input /ab/
#
#
#


def main
end


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

while true
  order = [Order.new(Char.new, "a"), Order.new(Push.new, 4),Order.new(Char.new, "b"), Order.new(Jump.new, 1), Order.new(Push.new, 7), Order.new(Char.new, "c"),Order.new(Jump.new, 8),Order.new(Char.new, "d"),  Order.new(Match.new, nil)]
  sm = StateMachine.new(order)

  input = gets.chomp
  p sm.match(input)
end
