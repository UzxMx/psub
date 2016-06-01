Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'psub'
  s.version     = '0.1'
  s.summary     = 'Publish and subscribe utility.'
  s.description = 'Publish and subscribe utility.'

  s.license = 'MIT'

  s.author   = 'Xue Mingxiang'
  s.email    = '327110424@163.com'

  s.files        = Dir['CHANGELOG.md', 'README.rdoc', 'MIT-LICENSE', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'activesupport'
end
