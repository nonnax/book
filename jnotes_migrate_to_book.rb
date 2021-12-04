#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-04 22:59:31 +0800
require 'fileutils'

f = ARGV.first

book=[]
tags='general'
file_date=Time.now
File.read(f).split(/(?=^\d{2}-(?:[^>])+>)+/).each_with_index do |note, i|
  date, post = note.split(/\s*>\s*/, 2)
  tags = File.dirname(f)
  tags = 'general' if tags.match(/^\./)
  file_date = date = File.open(f).mtime if i.zero?
  doc = <<~__
    ---
    time: #{date}
    tags: #{tags}
    ---
    #{post}

  __
  book<<doc
end

folder=tags
subfolder=file_date.year
p dir="book/#{folder}/#{subfolder}"
FileUtils.mkdir_p(dir) unless Dir.exists?(dir)

new_f=[File.basename(f, '.*'), '.md'].join
p path=[dir, new_f].join('/')
# 
File.open(path, 'w') do |f|
  f.puts book.join("\n")
end

