files=%w[README.md
book.rb
bin/book
bin/jnotes_migrate
bin/lock_safe
lib/editor.rb
lib/booker.rb
lib/string64.rb
book.gemspec
]
Gem::Specification.new do |s|
  s.name = 'book'
  s.version = '0.0.1'
  s.date = '2021-12-03'
  s.summary = "Book - a CLI (markdown) journal"
  s.authors = ["xxanon"]
  s.email = "ironald@gmail.com"
  s.files = files
  s.executables += %w[book jnotes_migrate lock_safe]
  s.homepage = "https://github.com/nonnax/book.git"
  s.license = "GPL-3.0"
end
