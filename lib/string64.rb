#!/usr/bin/env ruby
# Id$ nonnax 2021-12-07 17:12:55 +0800
require 'base64'

class String
  def base64?
    Base64.encode64(Base64.decode64(self)) == self
  end
  def lock
    Base64.encode64(self)
  end
  def unlock
    Base64.decode64(self)
  end
end
