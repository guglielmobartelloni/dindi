defmodule Dindi.ImporterTest do
  use ExUnit.Case

  alias Dindi.Transactions.Importer

  test "get token from gocardless" do
    assert byte_size(Importer.get_token()) == 300
  end

  test "list institutions" do
    assert length(Importer.new() |> Importer.list_banks()) > 0
  end

  test "get link" do
    assert %{"id" => _} =
             Importer.new()
             |> Importer.create_link("http://google.it", "BCC_DI_ANAGNI_CCRTIT2TN00")
             |> IO.inspect()
 end

end
