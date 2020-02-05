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

    context 'when allow contains single rule. array test' do
      let(:message_config) do
        YAML.safe_load <<~MESSAGE
                         allow:
                           - branches: ['default']
                        MESSAGE
      end

      it do
        data = { 'branches' => ['default'] }
        expect(matcher.matches?(message_config, data)).to be(true)
      end

      it do
        data = { 'branches' => ['feature/12345-do-stuff'] }
        expect(matcher.matches?(message_config, data)).to be(false)
      end
    end

    context 'when allow contains single rule. top-level array' do
      let(:message_config) do
        YAML.safe_load <<~MESSAGE
                       allow:
                        - [1, 2, 3]
                       MESSAGE
      end

      it do
        data = [1, 2, 3]
        expect(matcher.matches?(message_config, data)).to be(true)
      end

      it do
        data = [3, 2, 1]
        expect(matcher.matches?(message_config, data)).to be(false)
      end

      it do
        data = {}
        expect(matcher.matches?(message_config, data)).to be(false)
      end
    end

    context 'forbid rules' do
    end
  end
end
