source 'https://rubygems.org'

# Specify your gem's dependencies in ostatus.gemspec
gemspec

group :test do
  gem "rake"              # rakefile
  gem "minitest", "4.7.0" # test framework (specified here for prior rubies)
  gem "ansi"              # minitest colors
  gem "turn"              # minitest output
  gem "mocha"             # stubs
end

platforms :rbx do
  gem "json"
  gem "racc"
  gem "rubysl"
end

gem "nelumba-i18n", :git => "git://github.com/hotsh/nelumba-i18n.git"
