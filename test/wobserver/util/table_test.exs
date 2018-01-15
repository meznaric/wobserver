defmodule Wobserver.Util.TableTest do
  use ExUnit.Case

  alias Wobserver.Table

  setup _context do
    [tid: :ets.new(:blah, [:set, :private])]
  end

  describe "sanitize" do
    test "with integer" do
      assert Table.sanitize(1) == 1
    end

    test "with integer as string" do
      assert Table.sanitize("1") == 1
    end

    test "with atom" do
      assert Table.sanitize(:code) == :code
    end

    test "with atom as string" do
      assert Table.sanitize("code") == :code
    end
  end

  describe "list" do
    test "returns a list" do
      assert is_list(Table.list)
    end

    test "returns a list of maps" do
      assert is_map(List.first(Table.list))
    end

    test "returns a list of table information" do
      assert %{
        id: _,
        name: _,
        type: _,
        size: _,
        memory: _,
        owner: _,
        protection: _,
        meta: %{
          read_concurrency: _,
          write_concurrency: _,
          compressed: _,
        }
      } = List.first(Table.list)
    end
  end


  describe "info" do
    test "returns table information with defaults", %{tid: tid} do
      assert %{
        id: ^tid,
        name: :blah,
        type: :set,
        size: _,
        memory: _,
        owner: _,
        protection: :private,
        meta: %{
          read_concurrency: false,
          write_concurrency: false,
          compressed: false,
        }
      } = Table.info(tid)
    end

    test "returns table information without table, when set to false", %{tid: tid} do
      assert_raise MatchError, fn -> %{data: _} = Table.info(tid) end
    end

    test "returns table information with table, when set to true", %{tid: tid} do
      assert %{
        data: _
      } = Table.info(tid, true)
    end

    test "returns empty data, when set to true, but protection private", %{tid: tid} do
      assert %{
        protection: :private,
        data: []
      } = Table.info(tid, true)
    end

    test "returns non empty data, when set to true, but protection protected" do
      assert %{
        protection: :protected,
        data: data
      } = Table.info(:cowboy_clock, true)

      refute data == []
    end

    test "returns non empty data, when set to true, but protection public" do
      assert %{
        protection: :public,
        data: data
      } = Table.info(:hex_version, true)

      refute data == []
    end
  end
end
