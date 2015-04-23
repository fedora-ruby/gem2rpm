require 'helper'

class TestSpecification < Minitest::Test

  def setup
    @gemspec = Gem::Specification.new
    @spec = Gem2Rpm::Specification.new @gemspec
  end

  def test_ruby_version
    @gemspec.required_ruby_version = '>= 1.8'
    assert_equal([">= 1.8"], @spec.required_ruby_version)
  end

  def test_default_ruby_version
    assert_equal([''], @spec.required_ruby_version)
  end

  def test_dependencies
    @gemspec.add_runtime_dependency 'foo', '> 1.0'
    assert_equal(1, @spec.dependencies.size)
    assert_equal('foo', @spec.dependencies.first.name)
    assert_equal(['> 1.0'], @spec.dependencies.first.requirement)
  end

  def test_description_empty
    assert_equal "\n", @spec.description
  end

  def test_description_add_dot_when_missing
    @gemspec.description = "description"
    assert_equal "description.\n", @spec.description

    @gemspec.description = "description."
    assert_equal "description.\n", @spec.description
  end

  def test_description_use_summary_when_empty
    assert_empty @spec.description.strip

    @gemspec.summary = "summary"
    assert_equal "summary.\n", @spec.description
  end

end
