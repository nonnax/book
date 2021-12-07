#!/usr/bin/env ruby
# Id$ nonnax 2021-12-07 17:12:55 +0800
require 'base64'

class String
  # encoding with non-repeat op check 
  def base64?
    Base64.encode64(Base64.decode64(self)) == self
  end
  def lock
    s=self
    s=Base64.encode64(self) unless base64?
    s
  end
  def unlock
    s=self
    s=Base64.decode64(self) if base64?
    s
  end
end
