class ClosureContext

  attr_reader :closure
  attr_reader :ip
  attr_reader :frame

  def initialize(closure, ip, frame)
    @closure, @ip, @frame = closure, ip, frame
  end
  
  def inspect
    "context"
  end

end
