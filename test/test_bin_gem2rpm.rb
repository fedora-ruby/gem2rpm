require 'helper'

class TestBinGem2Rpm < Minitest::Test
  GEM_PATTERN = '*.gem'
  SRC_RPM_PATTERN = '*.src.rpm'

  def setup
    super
    tmp_dir = tmp_test_name_dir
    FileUtils.rm_rf(tmp_dir) if File.exist?(tmp_dir)
    FileUtils.mkdir_p(tmp_dir)
    @prev_dir = Dir.pwd
    Dir.chdir(tmp_dir)
  end

  def teardown
    tmp_dir = tmp_test_name_dir
    Dir.chdir(@prev_dir)
    FileUtils.rm_rf(tmp_dir)
    super
  end

  def test_help
    out, err = assert_gem2rpm_command('--help')
    assert_match(/^Usage/, out)
    assert_empty(err)
  end

  def test_vesion
    out, err = assert_gem2rpm_command('-v')
    assert_match(/^\d/, out)
    assert_empty(err)
  end

  def test_no_argument
    out, err = refute_gem2rpm_command
    assert_empty(out)
    assert_match(/^Missing GEMFILE/, err)
  end

  def test_gem_file
    prepare_testing_gem_file

    out, err = assert_gem2rpm_command(gem_file_name)
    assert_match(/^# Generated/, out)
    assert_empty(err)
  end

  def test_templates
    out, err = assert_gem2rpm_command('--templates')
    assert_match(/^Available templates/, out)
    assert_empty(err)
  end

  def test_template
    prepare_testing_gem_file

    out, err = assert_gem2rpm_command("-t fedora-21-rawhide #{gem_file_name}")
    assert_match(/^# Generated/, out)
    # This test is to check the condition without -l option
    # and the gem file package does not exist in the network.
    assert_match(/\nSource0: %{gem_name}-%{version}.gem\n/, out)
    # This test is to check the condition without --no-doc option.
    assert_match(/\n%package doc\n/, out)
    assert_empty(err)
  end

  def test_unknown_template
    prepare_testing_gem_file

    out, err = refute_gem2rpm_command("-t foo #{gem_file_name}")
    assert_empty(out)
    assert_match(/^Could not locate template/, err)
  end

  def test_template_unknown_gem_file
    out, err = refute_gem2rpm_command('-t fedora foo')
    assert_empty(out)
    assert_match(/^Invalid GEMFILE/, err)
  end

  def test_print_current_template
    out, err = assert_gem2rpm_command('-T')
    assert_match(/^# Generated/, out)
    assert_empty(err)
  end

  def test_fetch
    skip_if_offline

    out, err = assert_gem2rpm_command('--fetch gem2rpm')
    assert_match(/^# Generated/, out)
    # This test is to check the condition without -l option
    # and the gem file package exists in the network.
    assert_match(/\nSource0: http.*?%{gem_name}-%{version}.gem\n/, out)
    assert_empty(err)

    gem_matches = Dir.glob(GEM_PATTERN)
    assert_equal(1, gem_matches.length)
  end

  def test_fetch_unknown_gem_name
    skip_if_offline

    # Throw OpenURI::HTTPError with --fetch no_existed_gem_name.
    # https://github.com/fedora-ruby/gem2rpm/issues/66
    skip('Skip for the bug of --fetch no_existed_gem_name')
  end

  def test_fetch_srpm
    skip_if_offline

    out, err = assert_gem2rpm_command('--fetch -s gem2rpm')
    assert_match(/^Wrote:/, out)
    assert_empty(err)

    gem_matches = Dir.glob(GEM_PATTERN)
    assert_equal(1, gem_matches.length)

    src_rpm_matches = Dir.glob(SRC_RPM_PATTERN)
    assert_equal(1, src_rpm_matches.length)
  end

  def test_srpm
    prepare_testing_gem_file

    out, err = assert_gem2rpm_command("-s #{gem_file_name}")
    assert_match(/^Wrote:/, out)
    assert_empty(err)

    src_rpm_matches = Dir.glob(SRC_RPM_PATTERN)
    assert_equal(1, src_rpm_matches.length)
  end

  def test_srpm_for_error_gem_file
    prepare_testing_error_gem_file

    out, err = refute_gem2rpm_command("-s #{error_gem_file_name}")
    assert_empty(out)
    assert_match(/Command failed:/, err)

    src_rpm_matches = Dir.glob(SRC_RPM_PATTERN)
    assert_equal(0, src_rpm_matches.length)
  end


  def test_srpm_unknown_gem_file
    prepare_testing_gem_file

    out, err = refute_gem2rpm_command('-s foo')
    assert_empty(out)
    assert_match(/^Invalid GEMFILE/, err)
  end

  def test_output_file
    prepare_testing_gem_file
    spec_file = 'spec_file.txt'

    out, err = assert_gem2rpm_command("-o #{spec_file} #{gem_file_name}")
    assert_empty(out)
    assert_empty(err)

    assert(File.exist?(spec_file))
    content = File.open(spec_file, &:read)
    assert_match(/^# Generated/, content)
  end

  def test_srpm_output_file
    prepare_testing_gem_file
    spec_file = 'spec_file.txt'

    out, err = assert_gem2rpm_command("-s -o #{spec_file} #{gem_file_name}")
    assert_match(/^Wrote:/, out)
    assert_empty(err)

    assert(File.exist?(spec_file))
    content = File.open(spec_file, &:read)
    assert_match(/^# Generated/, content)
  end

  def test_srpm_change_directory
    prepare_testing_gem_file
    dir_name = 'foo'
    Dir.mkdir(dir_name)

    out, err = assert_gem2rpm_command("-s -C #{dir_name} #{gem_file_name}")
    assert_match(/^Wrote:/, out)
    assert_empty(err)

    src_rpm_pattern = File.join(dir_name, SRC_RPM_PATTERN)
    src_rpm_matches = Dir.glob(src_rpm_pattern)
    assert_equal(1, src_rpm_matches.length)
  end

  def test_fetch_srpm_change_directory
    skip_if_offline

    dir_name = 'foo'
    Dir.mkdir(dir_name)

    out, err = assert_gem2rpm_command("--fetch -s -C #{dir_name} gem2rpm")
    assert_match(/^Wrote:/, out)
    assert_empty(err)

    gem_pattern = File.join(dir_name, GEM_PATTERN)
    gem_matches = Dir.glob(gem_pattern)
    assert_equal(1, gem_matches.length)

    src_rpm_pattern = File.join(dir_name, SRC_RPM_PATTERN)
    src_rpm_matches = Dir.glob(src_rpm_pattern)
    assert_equal(1, src_rpm_matches.length)
  end

  def test_nongem
    prepare_testing_gem_file

    options_string = "-t fedora -n #{gem_file_name}"
    out, err = assert_gem2rpm_command(options_string)
    # nongem variable is used to control the non-gem use condition
    # in the template file.
    assert_match(/%global ruby_sitelib/, out)
    assert_empty(err)
  end

  def test_local
    prepare_testing_gem_file

    options_string = "-t fedora-21-rawhide -l #{gem_file_name}"
    out, err = assert_gem2rpm_command(options_string)
    # download_path variable is used to control the gem path in the template.
    # download_path variable is empty without local option.
    assert_match(/\nSource0: %{gem_name}-%{version}.gem\n/, out)
    assert_empty(err)
  end

  def test_no_doc_subpackage
    prepare_testing_gem_file

    options_string = "-t fedora-21-rawhide --no-doc #{gem_file_name}"
    out, err = assert_gem2rpm_command(options_string)
    # doc_subpackage variable is used to control the no doc condition
    # in the template file.
    refute_match(/\n%package doc\n/, out)
    assert_empty(err)
  end

  def test_print_dependencies
    prepare_testing_gem_file

    out, err = assert_gem2rpm_command("-d #{gem_file_name}")
    assert_match(/^rubygem/, out)
    assert_empty(err)
  end

  private

  # Use a unique directory for each test case,
  # to run the case in parallel.
  def tmp_test_name_dir
    # self.name: test method name
    name =
      if self.respond_to?(:name)
        self.name
      else
        ''
      end
    File.join(testing_tmp_dir, name)
  end

  def prepare_testing_gem_file
    FileUtils.cp(gem_path, tmp_test_name_dir)
  end

  def prepare_testing_error_gem_file
    FileUtils.cp(error_gem_path, tmp_test_name_dir)
  end

  def get_gem2rpm_command(options_string = '')
    "#{bin_gem2rpm_path} #{options_string}"
  end

  def run_gem2rpm_command(options_string = '')
    command = get_gem2rpm_command(options_string)
    is_success = false

    unless self.respond_to?(:capture_subprocess_io)
      skip('Skip because capture_subprocess_io is not supported.')
    end
    out, err = capture_subprocess_io do
      is_success = system(command)
    end

    message = "Command: #{command}\nout: #{out}\nerr: #{err}"
    yield(is_success, message)
    [out, err]
  end

  def assert_gem2rpm_command(options_string = '')
    run_gem2rpm_command(options_string) do |is_success, message|
      assert(is_success, message)
    end
  end

  def refute_gem2rpm_command(options_string = '')
    run_gem2rpm_command(options_string) do |is_success, message|
      refute(is_success, message)
    end
  end
end
