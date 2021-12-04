#!/usr/bin/env ruby
# Id$ nonnax 2021-10-02 17:23:14 +0800
class IO
  def self.editor(text="", editor: ENV['EDITOR'])
    IO.popen(editor, 'w+') do |io|
      io.puts text
      io.close_write
      io.read
    end
  end
end
