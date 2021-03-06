defmodule Dogma.Rules.PredicateNameTest do
  use ShouldI

  alias Dogma.Rules.PredicateName
  alias Dogma.Script
  alias Dogma.Error

  defp test(source) do
    source |> Script.parse!( "foo.ex" ) |> PredicateName.test
  end


  should "not error for predicates without the `is_` prefix" do
    errors = """
    def nice?(arg) do
      true
    end
    defp is_nice() do
      true
    end
    """ |> test
    assert [] == errors
  end

  should "error for predicates with the `is_` prefix" do
    errors = """
    def is_naughty?(arg) do
      true
    end
    defp is_bad?() do
      true
    end
    """ |> test
    expected_errors = [
      %Error{
        rule: PredicateName,
        message: "Favour `bad?` over `is_bad?`",
        line: 4,
      },
      %Error{
        rule: PredicateName,
        message: "Favour `naughty?` over `is_naughty?`",
        line: 1,
      },
    ]
    assert expected_errors == errors
  end
end
