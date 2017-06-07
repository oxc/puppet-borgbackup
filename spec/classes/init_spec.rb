require 'spec_helper'
describe 'rspamd' do
  context 'with default values for all parameters' do
    it { should contain_class('rspamd') }
  end
end
