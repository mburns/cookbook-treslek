require 'chefspec'
require_relative 'spec_helper'

describe 'foobar::default' do
  before { stub_resources }

  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'creates group' do
    expect(chef_run).to create_group('treslek')
  end

  it 'creates directory' do
    expect(chef_run).to create_directory('/usr/local/treslek')
  end

  it 'creates config file' do
    expect(chef_run).to create_template('/etc/treslek/config.json')
  end

  it 'creates config file' do
    expect(chef_run).to create_template('/usr/local/treslek//plugins/treslek-gh-issue-search/config.json')
  end
end
