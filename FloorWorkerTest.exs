defmodule VendingMachineApp.FloorWorkerTest do
  use ExUnit.Case

  test "handle restock request" do
    {:ok, pid} = VendingMachineApp.FloorWorker.start_link([])
    assert_receive {:restock, _floor_name, _machine_id, _restock_order} = fn
      _ -> :ok
    end
  end
end
