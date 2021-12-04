#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-03 20:08:27 +0800
# query with: book <begins-with query of a date>
#   i.e. book 2021; shows contents of all books of that year
#
require 'fileutils'
require_relative 'lib/editor'

YTD = Time.now.strftime('%Y')

BOOK_DIR = File.expand_path("~/.book/#{YTD}")
FileUtils.mkdir_p BOOK_DIR unless Dir.exist?(BOOK_DIR)

BOOK_DATETIME = '%Y-%m-%d %H:%M'
BOOK_DATE = '%Y-%m-%d'
BOOK_TIME = '%H:%M'
ERR_MSG = 'Wo0ps! post format error. Try again :-)'

def get(text)
  IO.editor text
end

def book_sections(f)
  _, *docs = File.open(f) do |f|
    f.flock(File::LOCK_EX)
    f.read.split(/(?=-{3}\ntime: )/)
  end
  docs
end

def book_file
  [BOOK_DIR, "#{default_date}.md"].join('/')
end

def default_date
  @default_date ||= Time.now.strftime(BOOK_DATE)
end

def default_time_header
  # a new book begins with a datetime header
  # subsequent posts use time headers
  File.exist?(book_file) ? Time.now.strftime(BOOK_TIME) : Time.now.strftime(BOOK_DATETIME)
end

def post_to_hash(text)
  # checks post text format
  _, header, post = text.split(/-{3,}\n/, 3)
  h = header.split(/\n/).inject({}) do |hsh, r|
    hsh.merge! [r.split(/:\s*/, 2)].to_h
  end
  h.merge!(post: post)
  h.transform_keys!(&:to_sym)
  raise ERR_MSG if h[:time].nil? || h[:post].nil? || h[:post].strip.empty?

  h
rescue StandardError => e
  raise ERR_MSG
end

def save_page(text)
  f = [BOOK_DIR, "#{default_date}.md"].join('/')
  FileUtils.cp f, "#{f}.bak"
  File.open(f, 'a+') do |f|
    f.flock(File::LOCK_EX)
    f.puts(text)
    f.flush
  end
  text
end

def to_book(h)
  time, tags, post = h.values_at(*%i[time tags post])
  <<~DOC
    ---
    time: #{time}
    tags: #{tags}
    ---
    #{post}
  DOC
end

def list(q)
  # query with <starts with>
  books = Dir[[BOOK_DIR, "#{q}*.md"].join('/')]
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

  text = %i[get post_to_hash to_book save_page].inject(template) do |t, m|
    # str->hash->str->str
    send(m, t)
  end

  puts "posted to: #{book_file}"
rescue StandardError
  puts ERR_MSG
  exit
end

if ARGV.size.positive?
  list ARGV.first
else
  run
end
