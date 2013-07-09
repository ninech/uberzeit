shared_examples :correct_calculations do
  describe 'work during non bonus times' do
    let(:starts) { '2013-02-28 13:00'.to_time }
    let(:ends) { '2013-02-28 14:00'.to_time }

    its(:result) { should eq(0) }
  end

  describe 'work started during bonus times in the morning' do
    let(:starts) { '2013-02-28 2:30'.to_time }
    let(:ends) { '2013-02-28 3:30'.to_time }

    its(:result) { should eq(factor*60.minutes) }
  end

  describe 'work started during bonus times in the evening' do
    let(:starts) { '2013-02-28 23:30'.to_time }
    let(:ends) { '2013-02-28 23:45'.to_time }

    its(:result) { should eq(factor*15.minutes) }
  end

  describe 'work spanning the bonus time start time' do
    let(:starts) { '2013-02-28 22:30'.to_time }
    let(:ends) { '2013-02-28 23:30'.to_time }

    its(:result) { should eq(factor*30.minutes) }
  end

  describe 'work over midnight' do
    let(:starts) { '2013-08-01 23:30'.to_time }
    let(:ends) { '2013-08-02 1:30'.to_time }

    its(:result) { should eq(factor*120.minutes) }
  end
end

