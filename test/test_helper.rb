# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.temporary_fixtures_directory = Engines::Testing.temporary_fixtures_directory.first if Engines::Testing.temporary_fixtures_directory.is_a? Array
Engines::Testing.set_fixture_path
