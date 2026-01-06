source "https://www.rubygems.org"

group :development do
  gem 'minitest', '> 5.0'
  # MT6 restricts supported versions, therefore older Rubies sticks with MT5,
  # which includes `minitest/mock`
  if RUBY_VERSION >= "3.2"
    gem 'minitest-mock'
  else
  end
  gem 'rake', '>= 12', '< 14'
end
