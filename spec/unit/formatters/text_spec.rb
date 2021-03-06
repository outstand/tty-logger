# frozen_string_literal: true

RSpec.describe TTY::Logger::Formatters::Text, "#dump" do

  [
    {key: "k", value: "v", want: "k=v"},
    {key: "k", value: '\n', want: "k=\\n"},
    {key: "k", value: '\r', want: "k=\\r"},
    {key: "k", value: '\t', want: "k=\\t"},
    {key: "k", value: nil, want: "k=nil"},
    {key: "k", value: "nil", want: "k=\"nil\""},
    {key: "k", value: "", want: "k="},
    {key: "k", value: true, want: "k=true"},
    {key: "k", value: "true", want: "k=\"true\""},
    {key: "k", value: "false", want: "k=\"false\""},
    {key: "k", value: 1, want: "k=1"},
    {key: "k", value: 1.035, want: "k=1.035"},
    {key: "k", value: 1e-5, want: "k=0.00001"},
    {key: "k", value: Complex(2,1), want: "k=(2+1i)"},
    {key: "k", value: "1", want: "k=\"1\""},
    {key: "k", value: "1.035", want: "k=\"1.035\""},
    {key: "k", value: "1e-5", want: "k=\"1e-5\""},
    {key: "k", value: "v v", want: "k=\"v v\""},
    {key: "k", value: " ", want: 'k=" "'},
    {key: "k", value: '"', want: 'k="\""'},
    {key: "k", value: '=', want: 'k="="'},
    {key: "k", value: "\\", want: "k=\\"},
    {key: "k", value: "=\\", want: "k=\"=\\\\\""},
    {key: "k", value: "\\\"", want: "k=\"\\\\\\\"\""},
    {key: "", value: "", want: "="},
    {key: '"', value: "v", want: '"\""=v'},
    {key: "k", value: Time.new(2019, 7, 7, 12, 21, 35, "+02:00"), want: "k=2019-07-07T12:21:35+02:00"},
    {key: "k", value: {a: 1}, want: "k={a=1}"},
    {key: "k", value: {a: 1, b: 2}, want: "k={a=1 b=2}"},
    {key: "k", value: {a: {b: 2}}, want: "k={a={b=2}}"},
    {key: "k", value: ["a", 1], want: "k=[a 1]"},
    {key: "k", value: ["a", ["b", 2], 1], want: "k=[a [b 2] 1]"},
  ].each do |data|
    it "dumps {#{data[:key].inspect} => #{data[:value].inspect}} as #{data[:want].inspect}" do
      formatter = described_class.new
      expect(formatter.dump({data[:key] => data[:value]})).to eq(data[:want])
    end
  end

  [
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 24, want: "a=aaaaa b=bbbbb c=ccccc"},
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 20, want: "a=aaaaa b=bbbbb ..."},
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 15, want: "a=aaaaa ..."},
    {obj: {a: "aaaaa", b: "bbbbb", c: "ccccc"}, bytes: 7, want: "..."},
  ].each do |data|
    it "truncates #{data[:obj].inspect} to #{data[:want].inspect} of #{data[:bytes]} bytes" do
      formatter = described_class.new
      expect(formatter.dump(data[:obj], max_bytes: data[:bytes])).to eq(data[:want])
    end
  end

  [
    {obj: {a: {b: {c: "ccccc"}}}, depth: 1, want: "a={...}"},
    {obj: {a: {b: {c: "ccccc"}}}, depth: 2, want: "a={b={...}}"},
    {obj: {a: {b: {c: "ccccc"}}}, depth: 3, want: "a={b={c=ccccc}}"},
    {obj: {a: ["b", {c: "ccccc"}]}, depth: 1, want: "a=[...]"},
    {obj: {a: ["b", {c: "ccccc"}]}, depth: 2, want: "a=[b {...}]"},
    {obj: {a: ["b", {c: "ccccc"}]}, depth: 3, want: "a=[b {c=ccccc}]"},
  ].each do |data|
    it "truncates nested object #{data[:obj].inspect} to #{data[:want].inspect}" do
      formatter = described_class.new
      expect(formatter.dump(data[:obj], max_depth: data[:depth])).to eq(data[:want])
    end
  end

  it "dumps a log line" do
    formatter = described_class.new
    data = {
      app: "myapp",
      env: "prod",
      sql: "SELECT * FROM admins",
      at: Time.at(123456).utc
    }

    expect(formatter.dump(data)).to eq("app=myapp env=prod sql=\"SELECT * FROM admins\" at=1970-01-02T10:17:36+00:00")
  end
end
