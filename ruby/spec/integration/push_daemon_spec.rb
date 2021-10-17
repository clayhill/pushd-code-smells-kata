describe 'Push Daemon' do
  let(:push_daemon) { TestDaemon.new(6889) }

  before do
    push_daemon.start

    eventually do
      expect(push_daemon).to be_ready
    end
  end

  describe 'commands' do
    describe 'PING' do
      it 'responds with PONG' do
        push_daemon.send('PING')

        eventually do
          expect(push_daemon.last_response).to eq('PONG')
        end
      end
    end

    describe 'SEND' do
      it 'delivers the message to the Google Cloud Messaging API' do
        stub_request(:post, "https://android.googleapis.com/gcm/send").
          with(
            body: "{\"registration_ids\":[\"t0k3n\"],\"data\":{\"alert\":\"Steve: What is up?\"}}",
            headers: {
              'Accept' => '*/*',
              'Authorization' => 'key=AIzaSyCABSTd47XeIH',
              'Content-Type' => 'application/json',
              'Date' => /.*/,
              'User-Agent' => 'HTTPClient/1.0 (2.8.3, ruby 3.0.2 (2021-07-07))'
            }).
          to_return(status: 200, body: "", headers: {})

        push_daemon.send('SEND t0k3n "Steve: What is up?"')

        eventually do
          sleep 0.001 # sleep is needed to get the worker thread to work
          assert_requested :post, 'https://android.googleapis.com/gcm/send', {
            headers: {
              'Authorization' => 'key=AIzaSyCABSTd47XeIH',
              'Content-Type' => 'application/json'
            },
            body: {
              'registration_ids' => ['t0k3n'],
              'data' => {
                'alert' => 'Steve: What is up?'
              }
            }.to_json
          }
        end
      end
    end
  end
end
