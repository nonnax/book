#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-03 20:08:27 +0800
# query with: 
# $ book <starts-with> 
# ex. book ruby
#
require 'fileutils'
require_relative 'lib/editor'

YTD = Time.now.strftime('%Y')

BOOK_ROOT = File.expand_path("~/.book")
# FileUtils.mkdir_p   BOOK_ROOT unless Dir.exist?(BOOK_ROOT)

BOOK_DATETIME = '%Y-%m-%d %H:%M'
BOOK_DATE = '%Y-%m-%d'
BOOK_TIME = '%H:%M'
ERR_MSG = 'Wo0ps! post format error. Try again :-)'
NO_FILE_FLAG = '__no_file__'

@tagdir='general'

def get(text)
  IO.editor text
end

def book_sections(f)
  docs = File.open(f) do |f|
    f.flock(File::LOCK_EX)
    f.read.split(/(?=-{3}\ntime: )/)
  end
end

def book_file
  return NO_FILE_FLAG unless @book_file
  @book_file
end

def create_book_path
  # yield and delete a @book_file name
  # retain @book_dir for later notification 
  raise [__method__, ERR_MSG].join(':') unless @tagdir
  @book_dir=[BOOK_ROOT, @tagdir, YTD].join('/')
  FileUtils.mkdir_p @book_dir unless Dir.exist?(@book_dir)

  @book_file = [@book_dir, "#{default_date}.md"].join('/')
  FileUtils.cp @book_file, "#{@book_file}.bak" if File.exists?(@book_file)
  yield @book_file
  @book_file=nil
end

def default_date
  @default_date ||= Time.now.strftime(BOOK_DATE)
end

def default_time_header
  # a new book begins with a datetime header
  # subsequent posts use time headers
  File.exist?(book_file) ? Time.now.strftime(BOOK_TIME) : Time.now.strftime(BOOK_DATETIME)
end

def book_hash_check(text)
  # check valid post
  _, header, post = text.split(/-{3,}\n/, 3)
  h = header.split(/\n/).inject({}) do |hsh, r|
    hsh.merge! [r.split(/:\s*/, 2)].to_h
  end
  h.merge!(post: post)
  h.transform_keys!(&:to_sym)

  raise RuntimeError if [:time, :post].any?{|e| h[e].nil? || h[e].strip.empty? }

  h
end

def book_save(text)
  create_book_path do |temp_book_file|
    File.open(temp_book_file, 'a+') do |f|
      f.flock(File::LOCK_EX)
      f.puts(text)
      f.flush
    end
  end
  text
end

def to_book(h)
  time, tags, post = h.values_at(*%i[time tags post])
  @tagdir=tags.split(/\s/).first
  <<~DOC
    ---
    time: #{time}
    tags: #{tags}
    ---
    #{post}
  DOC
end

def dump(q)
  # query a book folder
  books = Dir[[BOOK_ROOT, "**/#{q}*/**/*.md"].join('/')]
  books.each_with_index do |book, i|
    puts ['Book', i, File.basename(book)].join(':')
    book_sections(book).each do |page|
      puts page
      puts
    end
  end
end

def run
  template = <<~DOC
    ---
    time: #{default_time_header}
    tags: ruby ffmpeg
    ---
  DOC

  text = %i[get book_hash_check to_book book_save].inject(template) do |t, m|
    # str->hash->str->str
    send(m, t)
  end

  puts "posted to: #{@book_dir}"
rescue StandardError => e
  puts ERR_MSG
  exit
end

unless ARGV.empty?
  ARGV.each{|q| dump(q)}
else
  run
end
