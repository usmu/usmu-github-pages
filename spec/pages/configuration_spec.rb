require 'usmu/github/pages/configuration'
require 'ostruct'

RSpec.describe Usmu::Github::Pages::Configuration do
  context '#initialize' do
    it 'indexes the configuration parameter' do
      values = {foo: 'bar'}
      conf = described_class.new(values)
      expect(conf[:foo]).to eq('bar')
    end
  end
end
