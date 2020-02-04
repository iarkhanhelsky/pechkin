module Pechkin
  describe MessageMatcher do
    let(:matcher) { MessageMatcher.new }

    context 'when message config does not contain any rules' do
      it { expect(matcher.matches?({}, {})).to be(true) }
    end

    context 'when message config contains both allow and forbid rules' do
      it do
        message_config = { 'allow' => [], 'forbid' => [] }
        expect { matcher.matches?(message_config, {}) }
          .to raise_error(MessageMatchError)
      end
    end
  end
end
