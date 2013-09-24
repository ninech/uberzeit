require 'spec_helper'

describe TimeSpan do
  subject { TimeSpan.new }

  describe '#duration=' do
    it 'calculates duration_days' do
      expect { subject.duration = 1.5.days }.to change { subject.duration_days }
    end
  end

end
