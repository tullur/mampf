require 'rails_helper'

RSpec.describe Term, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:term)).to be_valid
  end
  it 'is invalid without a type' do
    term = FactoryGirl.build(:term, type: nil)
    expect(term).to be_invalid
  end
  it 'is invalid without a year' do
    term = FactoryGirl.build(:term, year: nil)
    expect(term).to be_invalid
  end
  it 'is invalid if type is not SummerTerm or WinterTerm' do
    term = FactoryGirl.build(:term, type: 'SpringTerm')
    expect(term).to be_invalid
  end
  it 'is invalid if year is not a number' do
    term = FactoryGirl.build(:term, year: 'hello')
    expect(term).to be_invalid
  end
  it 'is invalid if year is not an integer' do
    term = FactoryGirl.build(:term, year: 2017.25)
    expect(term).to be_invalid
  end
  it 'is invalid if year is lower than 2000' do
    term = FactoryGirl.build(:term, year: 1999)
    expect(term).to be_invalid
  end
  it 'is invalid if year is higher than 2200' do
    term = FactoryGirl.build(:term, year: 2201)
    expect(term).to be_invalid
  end
  it 'is invalid with duplicate type and year' do
    FactoryGirl.create(:term, type: 'SummerTerm', year: 2017)
    term = FactoryGirl.build(:term, type: 'SummerTerm', year: 2017)
    expect(term).to be_invalid
  end
  describe '#begin_date' do
    context 'if the term is a winter term' do
      it 'returns the correct begin date' do
        term = FactoryGirl.build(:term, type: 'WinterTerm', year: 2017)
        expect(term.begin_date).to eq Date.new(2017, 10, 1)
      end
    end
    context 'if the term is a summer term' do
      it 'returns the correct begin date' do
        term = FactoryGirl.build(:term, type: 'SummerTerm', year: 2017)
        expect(term.begin_date).to eq Date.new(2017, 4, 1)
      end
    end
  end
  describe '#end_date' do
    context 'if the term is a winter term' do
      it 'returns the correct end date' do
        term = FactoryGirl.build(:term, type: 'WinterTerm', year: 2017)
        expect(term.end_date).to eq Date.new(2018, 3, 31)
      end
    end
    context 'if the term is a summer term' do
      it 'returns the correct end date' do
        term = FactoryGirl.build(:term, type: 'SummerTerm', year: 2017)
        expect(term.end_date).to eq Date.new(2017, 9, 30)
      end
    end
  end
end
