require 'spec_helper'

describe Job do

  it { should belong_to(:job_template) }
  it { should have_many(:steps) }
  it { should respond_to?(:status) }
  it { should respond_to?(:environment) }

  fixtures :jobs, :job_templates, :job_steps

  describe 'validations' do
    it 'can be valid' do
      subject.environment = [{ 'variable' => 'foo', 'value' => 'bar' }]
      expect(subject.valid?).to be_truthy
      expect(subject.errors).to be_empty
    end

    it 'validates environment variables have values' do
      subject.environment = [{ 'variable' => 'foo', 'value' => '' }]
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:environment]).to eq ["environment variable values can't be blank"]
    end
  end

  describe '.with_templates' do
    context 'when querying by job status' do
      let(:fake_dray) do
        double(:fake_dray,
               get_job: { 'status' => 'success' }
              )
      end

      before do
        allow(PanamaxAgent).to receive(:dray_client).and_return(fake_dray)
      end

      it 'returns all ClusterJobTemplates jobs without a limit parameter ' do
        results = described_class.with_templates(nil, nil)
        expect(results.map(&:key)).to eq(['1234-1234-abcd'])
      end

      it 'allows a type parameter to limit the jobs returned in the response to those with a particular template type' do
        results = described_class.with_templates('FooJobTemplate', nil)
        expect(results.map(&:key)).to eq(['111-111-abc'])
      end

      it 'includes the jobs with the given status' do
        results = described_class.with_templates(nil, 'success')
        expect(results.map { |j| j['key'] }).to eq(['1234-1234-abcd'])
      end

      context 'when limited by a status that none of the jobs posess' do
        it 'returns no jobs ' do
          results = described_class.with_templates(nil, 'bla')
          expect(results.length).to eql(0)
        end
      end
    end
  end

  describe '#destroy' do
    subject { described_class.first }

    before do
      allow(subject).to receive(:destroy_job)
    end

    it 'destroys the job steps' do
      subject.destroy
      expect(JobStep.where(job: subject)).to be_empty
    end

    it 'calls #destroy_job after the model is destroyed' do
      expect(subject).to receive(:destroy_job)
      subject.destroy
    end
  end

end
