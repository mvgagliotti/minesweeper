lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "minesweeper"
  spec.version       = '1.0'
  spec.authors       = ["MV Gagliotti"]
  spec.email         = ["mvgagliotti@gmail.com"]
  spec.summary       = %q{Jogo Campo Minado - teste técnico para o processo da Quero Educação}
  spec.description   = %q{Longer description of your project.}
  spec.homepage      = "http://domainforproject.com/"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*'] + %w(README.md Rakefile minesweeper.gemspec)
  spec.executables   = ['minesweeper']
  spec.test_files    = ['tests/minesweeper_test.rb', 'tests/cell_test.rb']
  spec.require_paths = ["lib"]
end
