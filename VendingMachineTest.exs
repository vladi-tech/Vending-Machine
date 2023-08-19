defmodule VendingMachineApp.VendingMachineTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = VendingMachineApp.VendingMachine.start_link(%{floor_name: "floor_1", machine_id: "machine_1"})
    {:ok, pid: pid}
  end

  test "process order" do
    order = [%{["Chocolate",2],["Water", 1]}]
    assert {:ok, _} = VendingMachineApp.VendingMachine.process_order(@pid, order)
  end

  test "get recommendation" do
    recommendation = VendingMachineApp.VendingMachine.get_recommendation(@pid, "Sweet")
    assert length(recommendation) > 0
  end
end
