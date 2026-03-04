require "spec_helper"

require "active_record"
require "active_record/turntable/active_record_ext/fixtures"

describe ActiveRecord::TestFixtures do
  before do
    test_fixture_class.fixture_paths = fixtures_root
  end

  let(:fixtures_root) { File.join(File.dirname(__FILE__), "../../../fixtures") }
  let(:fixture_file) { File.join(fixtures_root, "items.yml") }
  let(:test_fixture_class) { Class.new(ActiveSupport::TestCase) { include ActiveRecord::TestFixtures } }
  let(:test_fixture) { test_fixture_class.new("test") }
  # items.yml has no YAML anchors/aliases; aliases: true is not needed.
  # Removed for Ruby 3.0 (Psych 3.x) compatibility (aliases: was added in Psych 4.0).
  let(:items) { YAML.load(ERB.new(IO.read(fixture_file)).result) }

  describe "#setup_fixtures" do
    after do
      test_fixture.teardown_fixtures
    end

    subject { test_fixture.setup_fixtures }
    it { expect { subject }.not_to raise_error }
  end
end
