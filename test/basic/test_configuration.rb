require_relative 'test_helper'


module Sandbox
  ConfigurationData = Data.define(:foo, :bar) do
    def initialize(foo: 'foo', bar: 'bar')
      super
    end
  end

  class Configuration1 < ::Basic::Configuration
    manage ConfigurationData
  end
  
  class Configuration2 < ::Basic::Configuration
    manage ConfigurationData, target_file: 'dummy.yml'
  end
end

describe ::Basic::Configuration do
  

  let(:config1) { Sandbox::Configuration1.instance }
  let(:config2) { Sandbox::Configuration2.instance }

  it 'must provide file_name' do
    assert_equal 'sandbox.yml', config1.class.target_file
    pp config1
  end

  it 'must provide managed properties' do
    assert_respond_to config1, :foo
    assert_respond_to config1, :bar
  end
end
