#!/usr/bin/env ruby
# Id$ nonnax 2021-12-05 00:18:07 +0800
require 'base64'
require 'fileutils'

PAGE_SPLIT_RE=/-{3}\n/
PAGE_DELIMETER_RE=/(?=-{3}\ntime:)/

def book_sections(f)
  File.open(f) do |f|
    f.flock(File::LOCK_EX)
    f.read.split(PAGE_DELIMETER_RE)
  end
end

def pack(header, post)
  post=Base64.encode64(post) 
  <<~__
    ---
    #{header.strip}
    ---
    #{post.strip}
  __
end

f=ARGV.first
book_sections(f).each do |page|
  begin
    _, header, post=page.split(PAGE_SPLIT_RE,3)
    p 'invalid book page' if [header, post].any?{|e| e.to_s.size.zero? }
    # simple test if already locked
    break unless post && post.scan(/\w+/).first.size<20
    if header[/safe/]
      p 'locking...'
      f_basename=File.basename(f, '.*')
      FileUtils.cp( f, "#{f_basename}.bak" )
      File.write( f, pack( header, post ) )
    end
  rescue=>e
    p e
  end
end
