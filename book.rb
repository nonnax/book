#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-12-03 20:08:27 +0800
# query with:
# $ book <starts-with>
# ex. book ruby
#
require './lib/booker'
require 'optparse'
@options = {}

OptionParser.new do |opts|
  opts.on('-l', '--list', 'List books')
  opts.on('-a', '--all', 'Show all books to stdout')
  opts.on('-v[INPUT]', '--view=[INPUT]', 'View contents of book(s)', Array)
end.parse!(into: @options)

if @options.empty?
  run
elsif @options[:dump]
  dump('?')
elsif @options[:list]
  puts Dir[[BOOK_ROOT, '*/'].join('/')]
    .map { |e| File.basename(e) }
    .sort
    .uniq
    .join("\n")
elsif @options[:view]
  @options[:view].each do |q|
    dump(q)
  end
end
