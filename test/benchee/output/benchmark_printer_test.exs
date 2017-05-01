defmodule Benchee.Output.BenchmarkPrintertest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  import Benchee.Output.BenchmarkPrinter

  test ".duplicate_benchmark_warning" do
    output = capture_io fn ->
      duplicate_benchmark_warning("Something")
    end

    assert output =~ "same name"
    assert output =~ "Something"
  end

  describe ".configuration_information" do
    test "sys information" do
      output = capture_io fn ->
        %{
          configuration: %{parallel: 2, time: 10_000, warmup: 0, inputs: nil},
          jobs: %{"one" => nil, "two" => nil},
          system: %{elixir: "1.4", erlang: "19.2"}
        }
        |> configuration_information
      end

      assert output =~ "Erlang 19.2"
      assert output =~ "Elixir 1.4"
      assert output =~ ~r/following configuration/i
      assert output =~ "warmup: 0.0s"
      assert output =~ "time: 0.01s"
      assert output =~ "parallel: 2"
      assert output =~ "Estimated total run time: 0.02s"
    end

    @inputs %{"Arg 1" => "Argument 1", "Arg 2" => "Argument 2"}
    test "multiple inputs" do
      output = capture_io fn ->
        %{
          configuration: %{parallel: 2, time: 10_000, warmup: 0, inputs: @inputs},
          jobs: %{"one" => nil, "two" => nil},
          system: %{elixir: "1.4", erlang: "19.2"}
        }
        |> configuration_information
      end

      assert output =~ "time: 0.01s"
      assert output =~ "parallel: 2"
      assert output =~ "inputs: Arg 1, Arg 2"
      assert output =~ "Estimated total run time: 0.04s"
    end

    test "does not print if disabled" do
      output = capture_io fn ->
        %{configuration: %{print: %{configuration: false}}}
        |> configuration_information
      end

      assert output == ""
    end
  end

  describe ".benchmarking" do
    test "prints information that it's currently benchmarking" do
      output = capture_io fn ->
        benchmarking("Something", %{})
      end

      assert output =~ ~r/Benchmarking.+Something/i
    end

    test "doesn't print if it's deactivated" do
      output = capture_io fn ->
        benchmarking "A", %{print: %{benchmarking: false}}
      end

      assert output == ""
    end
  end

  describe ".input_information" do
    test "notifies of the input being used" do
      output = capture_io fn ->
        input_information("Big List", %{})
      end

      assert output =~ ~r/with input Big List/i
    end

    test "does nothing when it's the no input marker" do
      marker = Benchee.Benchmark.no_input
      output = capture_io fn ->
        input_information marker, %{}
      end

      assert output == ""
    end

    test "does not print if disabled" do
      output = capture_io fn ->
        input_information("Big List", %{print: %{benchmarking: false}})
      end

      assert output == ""
    end
  end

  test ".fast_warning warns with reference to more information" do
    output = capture_io fn ->
      fast_warning()
    end

    assert output =~ ~r/fast/i
    assert output =~ ~r/unreliable/i
    assert output =~ "benchee/wiki"

  end
end
