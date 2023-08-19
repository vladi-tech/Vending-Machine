defmodule VendingMachineApp.Building do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def init(_) do
    children = [
      {VendingMachineApp.FloorSupervisor, [:floor_1]},
      {VendingMachineApp.FloorSupervisor, [:floor_2]},
      {VendingMachineApp.FloorSupervisor, [:floor_3]},
      {VendingMachineApp.Client, []}
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_floor_supervisor_pid(floor_name) do
    {:ok, pid} = Supervisor.which_children(__MODULE__)

    Enum.find(pid, fn
      {_, VendingMachineApp.FloorSupervisor, [:floor_name]} -> true
      _ -> false
    end)
  end


end
