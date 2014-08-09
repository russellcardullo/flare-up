describe FlareUp::CopyCommand do

  subject do
    FlareUp::CopyCommand.new('TEST_TABLE_NAME', 'TEST_DATA_SOURCE', 'TEST_ACCESS_KEY', 'TEST_SECRET_KEY')
  end

  its(:table_name) { should == 'TEST_TABLE_NAME' }
  its(:data_source) { should == 'TEST_DATA_SOURCE' }
  its(:aws_access_key_id) { should == 'TEST_ACCESS_KEY' }
  its(:aws_secret_access_key) { should == 'TEST_SECRET_KEY' }
  its(:columns) { should == [] }
  its(:options) { should == '' }

  describe '#get_command' do
    context 'when no optional fields are provided' do
      it 'should return a basic COPY command' do
        expect(subject.get_command).to eq("COPY TEST_TABLE_NAME  FROM 'TEST_DATA_SOURCE' CREDENTIALS 'aws_access_key_id=TEST_ACCESS_KEY;aws_secret_access_key=TEST_SECRET_KEY' ")
      end
    end

    context 'when column names are provided' do
      before do
        subject.columns = %w(column_name1 column_name2)
      end
      it 'should include the column names in the command' do
        expect(subject.get_command).to start_with('COPY TEST_TABLE_NAME (column_name1, column_name2) FROM')
      end
    end

    context 'when options are provided' do
      before do
        subject.options = 'OPTION1 OPTION2'
      end
      it 'should include the options in the command' do
        expect(subject.get_command).to end_with(' OPTION1 OPTION2')
      end
    end
  end

  describe '#columns=' do
    context 'when an array' do
      it 'should assign the property' do
        subject.columns = %w(column_name1 column_name2)
        expect(subject.columns).to eq(%w(column_name1 column_name2))
      end
    end

    context 'when not an array' do
      it 'should not assign the property and be an error' do
        subject.columns = %w(column_name1)
        expect {
          subject.columns = '_'
        }.to raise_error(ArgumentError)
        expect(subject.columns).to eq(%w(column_name1))
      end
    end
  end

  describe '#execute' do

    context 'when successful' do
      it 'should do something'
    end

    context 'when unsuccessful' do

      let(:conn) { instance_double('FlareUp::Connection') }
      before do
        expect(conn).to receive(:execute).and_raise(PG::ConnectionBad, message)
      end

      context 'when there was an error loading' do
        let(:message) { "Check 'stl_load_errors' system table for details" }
        before do
          allow(subject).to receive(:fetch_load_errors).and_return(['error1'])
        end
        it 'should respond with a list of errors' do
          expect(subject.execute(conn)).to eq(['error1'])
        end
      end

      context 'when there was another type of error' do
        let(:message) { '_' }
        it 'should do something' do
          expect { subject.execute(conn) }.to raise_error(PG::ConnectionBad, '_')
        end
      end

    end

  end

end