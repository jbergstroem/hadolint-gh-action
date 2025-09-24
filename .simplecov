# frozen_string_literal: true

SimpleCov.start do
  add_filter "/.git/"
  add_filter "/.github/"
  add_filter "install.sh"
  add_filter "/test/"
end
