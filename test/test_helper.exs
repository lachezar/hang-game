Dynamo.under_test(HangGame.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule HangGame.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
