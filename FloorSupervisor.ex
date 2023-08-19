defmodule VendingMachineApp.FloorSupervisor do
  use Supervisor

  def start_link(floor_name) do
    Supervisor.start_link(__MODULE__, floor_name, name: {:local, floor_name})
  end

  def init(floor_name) do
    workers = [
      {VendingMachineApp.FloorWorker, []},
      {VendingMachineApp.VendingMachine, [floor_name: floor_name, machine_id: "machine_1"]},
      {VendingMachineApp.VendingMachine, [floor_name: floor_name, machine_id: "machine_2"]},
      {VendingMachineApp.VendingMachine, [floor_name: floor_name, machine_id: "machine_3"]}
    ]

    children = workers
    Supervisor.init(children, strategy: :one_for_one)
  end

  def restock_machine(floor_name, machine_id, restock_order) do
    case Poolboy.checkout(:floor_worker_pool) do
      {:ok, worker_pid} ->
        GenServer.cast(worker_pid, {:restock, floor_name, machine_id, restock_order})
        Poolboy.checkin(:floor_worker_pool, worker_pid)
        {:ok, "Restock request sent to floor worker for machine #{machine_id}"}

      {:error, :timeout} ->
        {:error, "Timed out while checking out floor worker"}
    end
  end
end
