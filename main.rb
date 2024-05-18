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
    pp @orders
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
    pp "push #{operand}, #{s.input_cursor}"
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
  def self.add_star(ret, input, cursor, input_cursor, base)
        pp ret
        ret  = ret[0..-2]+[Order.new(Push.new, cursor+2+base)]+[ret[-1]]+[Order.new(Jump.new, cursor-ret[-1].length+base)]
      [ret, input_cursor+1, cursor+1]
  end

  def self.add_char(ret, input, cursor, input_cursor, base)
    ret.push(Order.new(Char.new, input[input_cursor]))
    [ret,input_cursor+1,cursor+1]
  end

  def self.parse(input)
    ast=[]
    ast,_,_=self.parse1(input,0,0)
    ast
  end

  def self.parse1(input, cursor, input_cursor, base=0)
    ret=[]
    while input_cursor<input.length 
      case input[input_cursor]
      when "*"
        ret, input_cursor, cursor = self.add_star(ret, input, cursor, input_cursor, base)
      when "+"
        ret, input_cursor, cursor = self.add_char(ret, input, cursor, input_cursor-1, base)
        input_cursor-=1
        ret, input_cursor, cursor = self.add_star(ret, input, cursor, input_cursor, base)
        input_cursor+=1
      when "("
        tmp_ret, cursor, input_cursor = self.parse1(input, 0, input_cursor+1, base=cursor)
        ret+=[tmp_ret]
      when ")"
        return ret, cursor, input_cursor+1
      else
        ret, input_cursor, cursor = self.add_char(ret, input, cursor, input_cursor, base)
      end
    end
    ret.push(Order.new(Match.new, nil))
    return ret.flatten, cursor ,input_cursor
  end
end

p "正規表現入力(対応記号、+*)"
order = gets.chomp
pp Parser.parse(order)

while true
  sm = StateMachine.new(Parser.parse(order))

  input = gets.chomp
  if sm.match(input)
    p "マッチしました"
  else
    p "マッチしませんでした"
  end
end
