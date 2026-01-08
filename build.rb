#!/usr/bin/env ruby

require "erb"
require "fileutils"
require "./lib/bindicator"
require "./lib/config"
require "./lib/restaurants"
require "./lib/shows"

def include_erb(path, b = binding)
  ERB.new(File.read(path), trim_mode: "-").result(b)
end

puts "Building site..."

@config = Config.new('config.yml')
@bindicator = Bindicator.new(@config)
@restaurants = Restaurants.new(@config)
@shows = Shows.new(@config)

template = File.read("templates/index.html.erb")
html = ERB.new(template).result(binding)

FileUtils.mkdir_p("dist")
File.write("dist/index.html", html)
puts "Wrote dist/index.html"

FileUtils.mkdir_p("dist/images")
FileUtils.cp_r("images/.", "dist/images")
puts "Copied images to dist/images"
puts "Done."
puts