module Pechkin # :nodoc:
  describe Substitute do
    context 'when key not found' do
      it 'keeps text unchanged' do
        expect(Substitute.new({}).process('${omg}')).to eq('${omg}')
      end
    end

    it 'replaces pattern with hash value to_s' do
      values = { 'a' => 'foo', 'b' => 42, 'c' => 3.2512144 }
      expect(Substitute.new(values).process('${a}')).to eq('foo')
      expect(Substitute.new(values).process('${b}')).to eq('42')
      expect(Substitute.new(values).process('${c}')).to eq('3.2512144')
    end

    context 'when key is a symbol' do
      it { expect(Substitute.new(foo: 42).process('${foo}')).to eq('42') }
    end

    context 'when substitution contains spaces' do
      it do
        expect(Substitute.new('foo ololo' => 42).process('${foo ololo}'))
          .to eq('${foo ololo}')
      end
    end

    context 'when mappings contains both string and symbol key' do
      it do
        expect(Substitute.new(:a => 42, 'a' => 99).process('${a}')).to eq('99')
      end
    end
  end
end
