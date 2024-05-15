require './skyscrapers'

all_possible_combinations = Skyscrapers.new(clues: [7,0,0,0,2,2,3, 0,0,3,0,0,0,0, 3,0,3,0,0,5,0, 0,0,0,0,5,0,4]).all_possible_combinations

RSpec.describe Skyscrapers do
  let(:instance) { described_class.new(clues: clues, grid: grid, all_possible_combinations: all_possible_combinations) }
  let(:clues) do
    [
      7,0,0,0,2,2,3,
      0,0,3,0,0,0,0,
      3,0,3,0,0,5,0,
      0,0,0,0,5,0,4
    ]
  end
  let(:grid) { nil }

  describe '#cross_check' do
    subject { instance.cross_check(first_combinations, second_combinations) }

    let(:first_combinations) do
      [
        [
          [1, 5, 6, 7, 4, 3, 2],
          [5, 6, 7, 4, 3, 2, 1],
        ],
        [
          [2, 7, 4, 5, 3, 1, 6],
          [7, 4, 5, 3, 1, 6, 2],
        ],
        [
          [3, 4, 5, 6, 7, 2, 1],
          [4, 5, 6, 7, 2, 1, 3],
        ],
        [
          [4, 6, 3, 1, 2, 7, 5],
          [6, 3, 1, 2, 7, 5, 4],
        ],
        [
          [5, 3, 1, 2, 6, 4, 7],
          [3, 1, 2, 6, 4, 7, 5],
        ],
        [
          [6, 2, 7, 3, 1, 5, 4],
          [2, 7, 3, 1, 5, 4, 6],
        ],
        [
          [7, 1, 2, 4, 5, 6, 3],
          [1, 2, 4, 5, 6, 3, 7]
        ]
      ]
    end

    let(:second_combinations) do
      [
        [
          [1, 2, 3, 4, 5, 6, 7],
          [7, 6, 5, 3, 4, 2, 1]
        ],
        [
          [5, 7, 4, 6, 3, 2, 1],
          [7, 6, 5, 4, 2, 1, 3]
        ],
        [
          [6, 4, 5, 3, 1, 7, 2],
          [4, 5, 3, 1, 7, 2, 6]
        ],
        [
          [7, 5, 6, 1, 2, 3, 4],
          [5, 6, 1, 2, 3, 4, 7]
        ],
        [
          [4, 3, 7, 2, 6, 1, 5],
          [3, 7, 2, 6, 1, 5, 4]
        ],
        [
          [3, 1, 2, 7, 4, 5, 6],
          [1, 2, 7, 4, 5, 6, 3]
        ],
        [
          [2, 6, 1, 5, 7, 4, 3],
          [6, 1, 5, 7, 4, 3, 2]
        ]
      ]
    end

    let(:expected) do
      [
        [
          [1, 5, 6, 7, 4, 3, 2],
        ],
        [
          [2, 7, 4, 5, 3, 1, 6],
        ],
        [
          [3, 4, 5, 6, 7, 2, 1],
        ],
        [
          [4, 6, 3, 1, 2, 7, 5],
        ],
        [
          [5, 3, 1, 2, 6, 4, 7],
        ],
        [
          [6, 2, 7, 3, 1, 5, 4],
        ],
        [
          [7, 1, 2, 4, 5, 6, 3],
        ],
      ]
    end

    it 'returns correct value' do
      expect(subject).to eq(expected)
    end
  end

  describe '#find_possible_combinations' do
    subject { instance.find_possible_combinations(clue_first, clue_last) }

    context 'when clues are 1 and 7' do
      let(:clue_first) { 1 }
      let(:clue_last) { 7 }
      let(:expected) do
        [
          [7, 6, 5, 4, 3, 2, 1]
        ]
      end

      it { expect(subject).to eq expected }
    end

    context 'when clues are 7 and 1' do
      let(:clue_first) { 7 }
      let(:clue_last) { 1 }
      let(:expected) do
        [
          [1, 2, 3, 4, 5, 6, 7]
        ]
      end

      it { expect(subject).to eq expected }
    end

    context 'when clues are 1 and 0' do
      let(:clue_first) { 1 }
      let(:clue_last) { 0 }

      it { expect(subject.count).to eq 720 }
      it { expect(subject.uniq.count).to eq 720 }
      it { expect(subject.map(&:first).uniq).to eq [7] }
    end

    context 'when clues are 0 and 1' do
      let(:clue_first) { 0 }
      let(:clue_last) { 1 }

      it { expect(subject.count).to eq 720 }
      it { expect(subject.uniq.count).to eq 720 }
      it { expect(subject.map(&:last).uniq).to eq [7] }
    end
  end
end
